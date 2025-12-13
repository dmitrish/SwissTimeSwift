//
//  WatchCarouselLayout.swift
//  SwissTimeSwift
//
//  Created by Shpinar Dmitri on 12/12/25.
//

import SwiftUI

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
        
        let modifiedAttributes = attributes.compactMap { attr -> UICollectionViewLayoutAttributes? in
            guard let newAttr = attr.copy() as? UICollectionViewLayoutAttributes else { return nil }
            
            // Calculate distance from center
            let itemCenterX = newAttr.center.x
            let distance = abs(itemCenterX - centerX)
            
            // Use a tighter range for more noticeable scaling
            let maxDistance: CGFloat = 200 // Adjust this to control how far the effect extends
            let normalizedDistance = min(distance / maxDistance, 1.0)
            
            // Scale from 1.2 (center) to 1.0 (edges)
            // Using a smooth curve for better visual effect
            let scale = 1.0 + (0.2 * (1.0 - normalizedDistance))
            newAttr.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Debug: print scale for items near center
            if distance < 100 {
                print("Item \(newAttr.indexPath.item): distance=\(distance), scale=\(scale)")
            }
            
            // Z-index: items to the left get increasing z-index, items to the right get decreasing z-index
            let isLeftOfCenter = itemCenterX < centerX
            if isLeftOfCenter {
                newAttr.zIndex = newAttr.indexPath.item
            } else {
                // Items to the right: closer to center = higher z-index
                newAttr.zIndex = 10000 - newAttr.indexPath.item
            }
            
            return newAttr
        }
        
        return modifiedAttributes
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
