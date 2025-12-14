import SwiftUI
import UIKit

// MARK: - SwiftUI Wrapper
struct WatchPagerView: View {
    let watches: [WatchInfo]
    @Binding var currentIndex: Int
    let geometry: GeometryProxy
    
    var body: some View {
        WatchCarouselRepresentable(
            watches: watches,
            currentIndex: $currentIndex,
            geometry: geometry
        )
        .frame(height: 150) // Explicit height
    }
}

/*struct WatchPagerView: View {
    let watches: [WatchInfo]
    @Binding var currentIndex: Int
    let geometry: GeometryProxy
    @Binding var isZoomed: Bool
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<watches.count, id: \.self) { index in
                Image(watches[index].imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .tag(index)
                    .onTapGesture {
                        withAnimation {
                            isZoomed.toggle()
                        }
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Hide page indicators
        .frame(height: 250)
        .onChange(of: currentIndex) { _ in
            // Reset zoom when swiping to a different watch
            if isZoomed {
                withAnimation {
                    isZoomed = false
                }
            }
        }
    }
} */

// MARK: - UIViewRepresentable
struct WatchCarouselRepresentable: UIViewRepresentable {
    let watches: [WatchInfo]
    @Binding var currentIndex: Int
    let geometry: GeometryProxy
    
    func makeUIView(context: Context) -> UIView {
        let carousel = WatchCarouselView(
            watches: watches,
            geometry: geometry,
            onIndexChanged: { newIndex in
                DispatchQueue.main.async {
                    currentIndex = newIndex
                }
            }
        )
        return carousel
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let carousel = uiView as? WatchCarouselView else { return }
        
        // Update if current index changed externally
        if carousel.getCurrentIndex() != currentIndex {
            carousel.scrollToIndex(currentIndex, animated: true)
        }
    }
}

// MARK: - UIKit Carousel View
class WatchCarouselView: UIView {
    private let watches: [WatchInfo]
    private let geometry: GeometryProxy
    private let onIndexChanged: (Int) -> Void
    
    private let watchSize: CGFloat = 125
    private let overlapFactor: CGFloat = 2/3
    
    private var collectionView: UICollectionView!
    private var internalCurrentIndex: Int = 0
    
    init(watches: [WatchInfo], geometry: GeometryProxy, onIndexChanged: @escaping (Int) -> Void) {
        self.watches = watches
        self.geometry = geometry
        self.onIndexChanged = onIndexChanged
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
        
        // Debug: Print initial setup
        print("Setup carousel with \(watches.count) watches")
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
}

// MARK: - UICollectionView DataSource & Delegate
extension WatchCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of items: \(watches.count)")
        return watches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Creating cell for index: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchCell", for: indexPath) as! WatchCell
        cell.configure(with: watches[indexPath.item], size: watchSize)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item != internalCurrentIndex {
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
        // Negative spacing creates overlap
        self.minimumLineSpacing = -(watchSize * (1 - overlapFactor))
        
        print("Layout initialized with itemSize: \(watchItemSize), spacing: \(self.minimumLineSpacing)")
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
            
            // Z-index: items to the left get increasing z-index, items to the right get decreasing z-index
            let isLeftOfCenter = newAttr.center.x < centerX
            if isLeftOfCenter {
                newAttr.zIndex = newAttr.indexPath.item
            } else {
                // Items to the right: closer to center = higher z-index
                newAttr.zIndex = 10000 - newAttr.indexPath.item
            }
            
            return newAttr
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func updateScales() {
        // This triggers layout invalidation
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
            hosting.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        hostingController = hosting
        
        print("Configured cell with watch: \(watch.id)")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}
