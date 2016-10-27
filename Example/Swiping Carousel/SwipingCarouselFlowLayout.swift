//
//  SwipingCarouselFlowLayout.swift
//  Swiping Carousel
//
//  Created by Pablo Paciello on 8/20/15.
//  Copyright (c) 2015 Pablo Paciello. All rights reserved.
//

import UIKit

class SwipingCarouselFlowLayout:  UICollectionViewFlowLayout {
    
    // Mark: Constants 
    fileprivate struct Constants {
        static let activeDistance: CGFloat = 200
        static let zoomFactor: CGFloat = 0.3
        static let itemWidth: CGFloat = 210       //Width of the Cell.
        static let itemHeight: CGFloat = 278      //Height of the Cell.
        static let minLineSpacing: CGFloat = 50.0
        
    }
    
    override func prepare() {
        super.prepare()
        
        itemSize = CGSize(width: Constants.itemWidth, height: Constants.itemHeight)
        scrollDirection = .horizontal
        minimumLineSpacing = Constants.minLineSpacing
        //These numbers will depend on the size of your cards you have set in the CardsViewFlowConstants.
        //60 - will let the first and last card of the CollectionView to be centered.
        //100 - will avoid the double rows in the CollectionView
        sectionInset = UIEdgeInsetsMake(100.0, 60.0, 100, 60.0)
        
    }

    // Here is where the magic happens
    // Add zooming to the Layout Attributes.
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let array = super.layoutAttributesForElements(in: rect)
        
        var visibleRect = CGRect()
        visibleRect.origin = collectionView!.contentOffset
        visibleRect.size = collectionView!.bounds.size
        
        for attributes in array! {
            let newAttributes: UICollectionViewLayoutAttributes = attributes 
            if attributes.frame.intersects(rect) {
                let distance = visibleRect.midX - attributes.center.x
                let normalizedDistance = distance / Constants.activeDistance
                if (abs(distance)) < Constants.activeDistance {
                    let zoom = 1 + Constants.zoomFactor*(1 - abs(normalizedDistance))
                    newAttributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    newAttributes.zIndex = 1
                }
            }
        }
        
        return array

    }

    
    //Focus the zoom in the middle Card.
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
               
        var offsetAdjustment:CGFloat = CGFloat(MAXFLOAT)
        let horizontalCenter = proposedContentOffset.x + (collectionView!.bounds.width / 2.0)
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
        
        if let array = super.layoutAttributesForElements(in: targetRect) {
            for layoutAttributes in array {
                let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                if (abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment)) {
                    offsetAdjustment = itemHorizontalCenter - horizontalCenter
                }
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    
    // Invalidate the Layout when the user is scrolling
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}