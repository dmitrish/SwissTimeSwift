import SwiftUI
import UIKit
import Combine

// MARK: - Zoom State Manager
class WatchZoomState: ObservableObject {
    @Published var isZoomed: Bool = false
}

// MARK: - Zoomable Watch View
struct ZoomableWatchView: View {
    let watch: WatchInfo
    let size: CGFloat
    @ObservedObject var zoomState: WatchZoomState
    
    var body: some View {
        ZStack {
            // Invisible placeholder that maintains layout space
            WatchFaceView(
                watch: watch,
                timeZone: .current,
                size: size
            )
            .opacity(0)
            
            // Actual watch that scales - won't affect layout!
            WatchFaceView(
                watch: watch,
                timeZone: .current,
                size: size
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .scaleEffect(zoomState.isZoomed ? 1.4 : 1.0, anchor: .center)
            .animation(.spring(duration: 0.3, bounce: 0.3), value: zoomState.isZoomed)
        }
    }
}

// MARK: - SwiftUI Wrapper
struct WatchPagerView: View {
    let watches: [WatchInfo]
    @Binding var currentIndex: Int
    let geometry: GeometryProxy
    @Binding var isZoomed: Bool
    
    var body: some View {
        WatchCarouselRepresentable(
            watches: watches,
            currentIndex: $currentIndex,
            geometry: geometry,
            isZoomed: $isZoomed
        )
        .frame(height: 260)  // Increased to accommodate 1.3x base scale + 1.4x zoom
    }
}

// MARK: - UIViewRepresentable
struct WatchCarouselRepresentable: UIViewRepresentable {
    let watches: [WatchInfo]
    @Binding var currentIndex: Int
    let geometry: GeometryProxy
    @Binding var isZoomed: Bool
    
    func makeUIView(context: Context) -> UIView {
        let carousel = WatchCarouselView(
            watches: watches,
            geometry: geometry,
            initialIndex: currentIndex,
            onIndexChanged: { newIndex in
                DispatchQueue.main.async {
                    currentIndex = newIndex
                }
            },
            onWatchTapped: {
                DispatchQueue.main.async {
                    isZoomed.toggle()
                }
            }
        )
        context.coordinator.carousel = carousel
        context.coordinator.isFirstUpdate = true
        return carousel
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let carousel = uiView as? WatchCarouselView else { return }
        
        if context.coordinator.isFirstUpdate {
            context.coordinator.isFirstUpdate = false
            carousel.updateZoomState(isZoomed)
            return
        }
        
        if carousel.getCurrentIndex() != currentIndex {
            carousel.scrollToIndex(currentIndex, animated: true)
        }
        
        carousel.updateZoomState(isZoomed)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        weak var carousel: WatchCarouselView?
        var isFirstUpdate = false
    }
}

// MARK: - UIKit Carousel View
class WatchCarouselView: UIView {
    private let watches: [WatchInfo]
    private let geometry: GeometryProxy
    private let onIndexChanged: (Int) -> Void
    private let onWatchTapped: () -> Void
    
    private let watchSize: CGFloat = 125
    private let overlapFactor: CGFloat = 2/3
    
    private var collectionView: UICollectionView!
    private var internalCurrentIndex: Int
    private var isInitializing = true
    private let horizontalPadding: CGFloat
    private var hasPerformedInitialScroll = false
    
    init(watches: [WatchInfo],
         geometry: GeometryProxy,
         initialIndex: Int,
         onIndexChanged: @escaping (Int) -> Void,
         onWatchTapped: @escaping () -> Void) {
        self.watches = watches
        self.geometry = geometry
        self.internalCurrentIndex = initialIndex
        self.onIndexChanged = onIndexChanged
        self.onWatchTapped = onWatchTapped
        
        self.horizontalPadding = (geometry.size.width - watchSize) / 2
        
        super.init(frame: .zero)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        let layout = WatchCarouselLayout(
            watchItemSize: CGSize(width: watchSize * overlapFactor, height: watchSize + 40),
            overlapFactor: overlapFactor,
            watchSize: watchSize
        )
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WatchCell.self, forCellWithReuseIdentifier: "WatchCell")
        
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding
        )
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func scrollToIndex(_ index: Int, animated: Bool, silent: Bool = false) {
        guard index >= 0 && index < watches.count else { return }
        
        if index != internalCurrentIndex {
            internalCurrentIndex = index
            if !silent {
                onIndexChanged(index)
            }
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }
    
    func getCurrentIndex() -> Int {
        return internalCurrentIndex
    }
    
    func updateZoomState(_ isZoomed: Bool) {
        for cell in collectionView.visibleCells {
            guard let watchCell = cell as? WatchCell,
                  let indexPath = collectionView.indexPath(for: cell) else { continue }
            
            let shouldBeZoomed = indexPath.item == internalCurrentIndex && isZoomed
            watchCell.setZoomed(shouldBeZoomed)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension WatchCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchCell", for: indexPath) as! WatchCell
        cell.configure(with: watches[indexPath.item], size: watchSize)
        cell.setZoomed(false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !hasPerformedInitialScroll {
            hasPerformedInitialScroll = true
            
            collectionView.scrollToItem(
                at: IndexPath(item: internalCurrentIndex, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
            
            // Force immediate layout update and cell reload to apply transforms
            DispatchQueue.main.async {
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.layoutIfNeeded()
                // Reload visible cells to apply transforms
                if let visibleIndexPaths = collectionView.indexPathsForVisibleItems as? [IndexPath] {
                    collectionView.reloadItems(at: visibleIndexPaths)
                }
                self.isInitializing = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == internalCurrentIndex {
            onWatchTapped()
        } else {
            scrollToIndex(indexPath.item, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? WatchCarouselLayout else { return }
        
        // This triggers layout invalidation which applies the scale transforms
        layout.updateScales()
        
        if isInitializing {
            return
        }
        
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        guard let attributes = layout.layoutAttributesForElements(in: scrollView.bounds) else { return }
        
        var closestIndex = internalCurrentIndex
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for attr in attributes {
            let distance = abs(attr.center.x - centerX)
            if distance < minDistance {
                minDistance = distance
                closestIndex = attr.indexPath.item
            }
        }
        
        if closestIndex != internalCurrentIndex {
            internalCurrentIndex = closestIndex
            onIndexChanged(closestIndex)
        }
    }
}

// MARK: - Custom Layout
class WatchCarouselLayout: UICollectionViewFlowLayout {
    private let watchItemSize: CGSize
    private let overlapFactor: CGFloat
    private let watchSize: CGFloat
    
    init(watchItemSize: CGSize, overlapFactor: CGFloat, watchSize: CGFloat) {
        self.watchItemSize = watchItemSize
        self.overlapFactor = overlapFactor
        self.watchSize = watchSize
        super.init()
        
        self.scrollDirection = .horizontal
        self.itemSize = watchItemSize
        self.minimumLineSpacing = -(watchSize * (1 - overlapFactor))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard let collectionView = collectionView else { return attributes }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        return attributes.compactMap { attr in
            guard let newAttr = attr.copy() as? UICollectionViewLayoutAttributes else { return nil }
            
            let distance = abs(newAttr.center.x - centerX)
            // Use item width as maxDistance for controlled scaling
            let itemWidth = watchSize * overlapFactor
            let maxDistance = itemWidth * 1.85  // More gradual drop-off
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Scale: 1.3 at center, 1.0 at edges
            let scale = 1.0 + (0.3 * (1.0 - normalizedDistance))
            newAttr.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let isLeftOfCenter = newAttr.center.x < centerX
            if isLeftOfCenter {
                newAttr.zIndex = newAttr.indexPath.item
            } else {
                newAttr.zIndex = 10000 - newAttr.indexPath.item
            }
            
            return newAttr
        }
    }
    
    // CRITICAL: Must override this too!
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        guard let collectionView = collectionView else { return attributes }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        let distance = abs(attributes.center.x - centerX)
        let itemWidth = watchSize * overlapFactor
        let maxDistance = itemWidth * 1.85
        let normalizedDistance = min(distance / maxDistance, 1.0)
        
        let scale = 1.0 + (0.3 * (1.0 - normalizedDistance))
        attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        let isLeftOfCenter = attributes.center.x < centerX
        if isLeftOfCenter {
            attributes.zIndex = attributes.indexPath.item
        } else {
            attributes.zIndex = 10000 - attributes.indexPath.item
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func updateScales() {
        invalidateLayout()
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: 0,
            width: collectionView.bounds.width,
            height: collectionView.bounds.height
        )
        
        guard let layoutAttributes = super.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }
        
        let centerX = proposedContentOffset.x + collectionView.bounds.width / 2
        
        var closestAttribute: UICollectionViewLayoutAttributes?
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for attribute in layoutAttributes {
            let distance = abs(attribute.center.x - centerX)
            if distance < minDistance {
                minDistance = distance
                closestAttribute = attribute
            }
        }
        
        guard let closest = closestAttribute else { return proposedContentOffset }
        
        return CGPoint(
            x: closest.center.x - collectionView.bounds.width / 2,
            y: proposedContentOffset.y
        )
    }
}

// MARK: - Watch Cell
class WatchCell: UICollectionViewCell {
    private var hostingController: UIHostingController<AnyView>?
    private var zoomState: WatchZoomState?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with watch: WatchInfo, size: CGFloat) {
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        
        let state = WatchZoomState()
        zoomState = state
        
        let watchView = ZoomableWatchView(
            watch: watch,
            size: size,
            zoomState: state
        )
        
        let hosting = UIHostingController(rootView: AnyView(watchView))
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hosting.view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hosting.view.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            hosting.view.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
        hostingController = hosting
    }
    
    func setZoomed(_ zoomed: Bool) {
        zoomState?.isZoomed = zoomed
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        zoomState = nil
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
    
    // This is key - apply the transform from layout attributes
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        // Don't apply to cell layer - SwiftUI content ignores it
        // Instead apply directly to the hosting controller's view
        hostingController?.view.layer.transform = CATransform3DMakeAffineTransform(layoutAttributes.transform)
    }
}
