import SwiftUI
import UIKit

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
        .frame(height: 200) // Increased height to accommodate zoom
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
            },
            isZoomed: isZoomed
        )
        return carousel
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let carousel = uiView as? WatchCarouselView else { return }
        
        // Update if current index changed externally
        if carousel.getCurrentIndex() != currentIndex {
            carousel.scrollToIndex(currentIndex, animated: true)
        }
        
        // Update zoom state
        carousel.updateZoomState(isZoomed)
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
    private var isZoomed: Bool = false
    
    init(watches: [WatchInfo],
         geometry: GeometryProxy,
         onIndexChanged: @escaping (Int) -> Void,
         onWatchTapped: @escaping () -> Void,
         isZoomed: Bool) {
        self.watches = watches
        self.geometry = geometry
        self.onIndexChanged = onIndexChanged
        self.onWatchTapped = onWatchTapped
        self.isZoomed = isZoomed
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
        
        // Add padding for centering
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
    }
    
    func scrollToIndex(_ index: Int, animated: Bool) {
        guard index >= 0 && index < watches.count else { return }
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }
    
    func getCurrentIndex() -> Int {
        return internalCurrentIndex
    }
    
    func updateZoomState(_ zoomed: Bool) {
        if isZoomed != zoomed {
            isZoomed = zoomed
            // Reload the centered cell to update its zoom state
            let indexPath = IndexPath(item: internalCurrentIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? WatchCell {
                cell.setZoomed(isZoomed, animated: true)
            }
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
        
        // Apply zoom state if this is the centered cell
        if indexPath.item == internalCurrentIndex && isZoomed {
            cell.setZoomed(true, animated: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == internalCurrentIndex {
            // Tapped on centered watch - toggle zoom
            onWatchTapped()
        } else {
            // Tapped on non-centered watch - scroll to it
            scrollToIndex(indexPath.item, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? WatchCarouselLayout else { return }
        
        // Update scales based on scroll position
        layout.updateScales()
        
        // Calculate current centered index
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        let itemWidth = watchSize * overlapFactor
        let index = Int(round((centerX - scrollView.contentInset.left) / itemWidth))
        let clampedIndex = max(0, min(watches.count - 1, index))
        
        if clampedIndex != internalCurrentIndex {
            // Reset zoom when scrolling to a different watch
            if isZoomed {
                if let oldCell = collectionView.cellForItem(at: IndexPath(item: internalCurrentIndex, section: 0)) as? WatchCell {
                    oldCell.setZoomed(false, animated: true)
                }
            }
            
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
            
            // Calculate distance from center
            let distance = abs(newAttr.center.x - centerX)
            let maxDistance = collectionView.bounds.width / 2
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Scale from 1.2 (center) to 1.0 (edges)
            let scale = 1.2 - (normalizedDistance * 0.2)
            newAttr.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Z-index
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
    private var zoomScale: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with watch: WatchInfo, size: CGFloat) {
        // Remove old hosting controller
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create SwiftUI view
        let watchView = VStack(spacing: 16) {
            WatchFaceView(
                watch: watch,
                timeZone: TimeZone.current,
                size: size
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
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
        
        // Apply current zoom if any
        hosting.view.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
    }
    
    func setZoomed(_ zoomed: Bool, animated: Bool) {
        let newScale: CGFloat = zoomed ? 1.4 : 1.0
        zoomScale = newScale
        
        guard let view = hostingController?.view else { return }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut]
            ) {
                view.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            }
        } else {
            view.transform = CGAffineTransform(scaleX: newScale, y: newScale)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        zoomScale = 1.0
        hostingController?.view.transform = .identity
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}
