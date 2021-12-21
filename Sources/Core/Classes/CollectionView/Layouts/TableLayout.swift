//
//  TableLayout.swift
//  UIKitBase
//
//  Created by Brian Strobach on 12/21/21.
//  Copyright © 2021 Brian Strobach. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class CompositionalTableLayout: UICollectionViewCompositionalLayout {
    public init(estimatedCellHeight: CGFloat) {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(estimatedCellHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 0
        super.init(section: section)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Based on https://stackoverflow.com/questions/44187881/uicollectionview-full-width-cells-allow-autolayout-dynamic-height
class TableLayout: UICollectionViewFlowLayout {
    let sectionSpacing: CGFloat = 1 // Must be non-zero
    override init() {
        super.init()
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize // CGSize(width: 1, height: 1)
        let spacing: CGFloat = 1
        self.minimumInteritemSpacing = spacing
        self.minimumLineSpacing = spacing
        self.sectionInset = UIEdgeInsets(t: self.sectionSpacing, l: self.sectionSpacing, b: self.sectionSpacing, r: self.sectionSpacing)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]
        layoutAttributesObjects?.forEach { layoutAttributes in
            if layoutAttributes.representedElementCategory == .cell {
                if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                    layoutAttributes.frame = newFrame
                }
            }
        }
        return layoutAttributesObjects
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else {
            return nil
        }
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        layoutAttributes.frame.origin.x = sectionInset.left
        if #available(iOS 11.0, *) {
            layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        }

        return layoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
