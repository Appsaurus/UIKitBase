//
//  GridLayout.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import Foundation
import UIKit

open class GridLayout: UICollectionViewFlowLayout {
    open var numberOfColumns: Int = 3

    public init(numberOfColumns: Int) {
        super.init()
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
        self.numberOfColumns = numberOfColumns
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var itemSize: CGSize {
        get {
            if let collectionView = collectionView {
                let itemWidth: CGFloat = (collectionView.frame.width / CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                return CGSize(width: itemWidth, height: itemWidth)
            }

            // Default fallback
            return CGSize(width: 100, height: 100)
        }
        set {
            super.itemSize = newValue
        }
    }

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let collectionView = collectionView {
            return collectionView.contentOffset
        }
        return CGPoint.zero
    }

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
