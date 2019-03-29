//
//  ImageSliderViewController.swift
//  Pods
//
//  Created by Brian Strobach on 7/17/17.
//
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

open class ImageScrollingCollectionViewController: PaginatableCollectionViewController<String>, UICollectionViewDelegateFlowLayout {

    open var imageAspectRatio: LayoutAspectRatio = .square
    open var imageShape: ViewShape = .roundedRect
    
    public required override init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(collectionViewLayout: layout)
        collectionView?.setCollectionViewLayout(layout, animated: false)
        collectionView?.allowsSelection = true
        collectionView?.allowsMultipleSelection = false
		if #available(iOS 11.0, *) {
			collectionView?.contentInsetAdjustmentBehavior = .never
			collectionView?.contentInset = .zero
		}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    open func registerReusables() {
        collectionView?.registerReusable(cellClass: BaseImageCollectionViewCell.self)
    }
    
    // MARK: CollectionView Delegate/Datasource
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BaseImageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if let url = dataSource[indexPath] {
            cell.imageView.tag = indexPath.row
            do {
                try cell.imageView.loadImage(with: url)
            } catch {
                cell.imageView.display(image: nil)
            }

        }
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch imageAspectRatio {
        case .square:
            return CGSize(side: collectionView.frame.h)
        default:
            assertionFailure("Still need to implement other aspect ratios")
            return .zero
        }
    }

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    // MARK: Flow layout delegate
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
