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
        WatchFaceView(
            watch: watch,
            timeZone: .current,
            size: size
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .scaleEffect(zoomState.isZoomed ? 1.4 : 1.0)
        .animation(.spring(duration: 0.3, bounce: 0.3), value: zoomState.isZoomed)
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
        .frame(height: 200)
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
        return carousel
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let carousel = uiView as? WatchCarouselView else { return }
        
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
    private var internalCurrentIndex: Int = 0
    
    init(watches: [WatchInfo],
         geometry: GeometryProxy,
         onIndexChanged: @escaping (Int) -> Void,
         onWatchTapped: @escaping () -> Void) {
        self.watches = watches
        self.geometry = geometry
        self.onIndexChanged = onIndexChanged
        self.onWatchTapped = onWatchTapped
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
        
        let horizontalPadding = (geometry.size.width - watchSize * overlapFactor) / 2
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
        
        DispatchQueue.main.async { [weak self] in
            self?.scrollToIndex(0, animated: false)
        }
    }
    
    func scrollToIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < watches.count else { return }
        
        if index != internalCurrentIndex {
            internalCurrentIndex = index
            onIndexChanged(index)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == internalCurrentIndex {
            onWatchTapped()
        } else {
            scrollToIndex(indexPath.item, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? WatchCarouselLayout else { return }
        
        layout.updateScales()
        
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let itemWidth = watchSize * overlapFactor
        let index = Int(round((centerX - scrollView.contentInset.left) / itemWidth))
        let clampedIndex = max(0, min(watches.count - 1, index))
        
        if clampedIndex != internalCurrentIndex {
            internalCurrentIndex = clampedIndex
            onIndexChanged(clampedIndex)
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
            let maxDistance = collectionView.bounds.width / 2
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            let scale = 1.2 - (normalizedDistance * 0.2)
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
        
        let watchView = VStack(spacing: 16) {
            ZoomableWatchView(
                watch: watch,
                size: size,
                zoomState: state
            )
        }
        
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
}
