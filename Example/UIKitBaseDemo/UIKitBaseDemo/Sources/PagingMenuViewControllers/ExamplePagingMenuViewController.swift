//
//  ExamplePagingMenuViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Swiftest
import UIKitBase
import UIKitTheme
import Layman
import UIKitBase

class ExamplePagingMenuViewController: BaseParentPagingMenuViewController {

    override func createPagingMenuView() -> PagingMenuView {
        return ExamplePagingMenuView(delegate: self, options: pagingMenuViewOptions)
    }
    override open func createPagedViewControllers() -> [UIViewController] {
        var pages: [UIViewController] = []
        5.times {
            pages.append(ExamplePaginatableTableViewController())
        }
        return pages
    }

    public override func createStatefulViews() -> StatefulViewMap {
		return .default
	}
    //PagingMenuControllerDelegate
    
    open override var pagingMenuViewOptions: PagingMenuViewOptions{
		let menuHeight: CGFloat = 50.0
//        let sizing: PagingeMenuViewItemSizingBehavior = .delegateSizing
        let sizing: PagingeMenuViewItemSizingBehavior = .spanWidth(numberOfCells: 4.5, height: menuHeight * 0.75)
//        let sizing: PagingeMenuViewItemSizingBehavior = .spanWidthProportionately(height: menuHeight * 0.65)
		return PagingMenuViewOptions(layout: .horizontal(height: menuHeight), itemSizingBehavior: sizing, scrollBehavior: .scrolls)
    }
    
    open override func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return [ExamplePagingMenuItemCell.self]
    }
    
    override func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize {
        let cell: ExamplePagingMenuItemCell = ExamplePagingMenuItemCell()
        configure(cell: cell, at: index)
        return cell.calculateDynamicSize(fixedDimension: .height(size: pagingMenuViewOptions.layout.fixedDimensionValue))
    }

    open override func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        let cell: ExamplePagingMenuItemCell = menuView.pagingMenuCollectionView.dequeueReusableCell(for: index)
        configure(cell: cell, at: index)
        return cell
    }
    
    open func configure(cell: ExamplePagingMenuItemCell, at index: Int){
        cell.display(object: (
            "http://findicons.com/files/icons/2421/symbolicons_drink/512/drink_biggulp.png",
            index.isEven ? "Title \(index)" : "Longer Title \(index)")
        )
        cell.menuItemButton.buttonLayout = cell.menuItemButtonLayout()
        cell.forceAutolayoutPass()
    }

}

open class ExamplePagedViewController: BaseViewController{
    open override func style() {
        super.style()
        view.backgroundColor = .red// UIColor.random()
    }
}

open class ExamplePagingMenuView: PagingMenuView{

    open override func createSelectionIndicatorView() -> UIView? {
        return UIView()
    }
    open override func style() {
        super.style()
        selectionIndicatorView?.backgroundColor = .primary
    }
}


open class ExamplePagingMenuItemCell: PagingMenuButtonCell {
//    open override func mainViewInsets() -> UIEdgeInsets {
//       
//        return UIEdgeInsets(horizontalPadding: 20.0, verticalPadding: 10.0)
//    }

    open var imageUrl: String?{
        didSet{
            
            if let imageUrl = imageUrl{
                menuItemButton.imageUrlMap = [
                    .any : imageUrl,
                ]
            }
            else{
                menuItemButton.imageView.resetImage()
            }
        }
    }
    open override func menuItemButtonLayout() -> ButtonLayout{
        let insets = LayoutPadding(horizontal: 10.0, vertical: 10.0)
        return ButtonLayout(layoutType: .imageAndTitleCentered(padding: 10.0), marginInsets: insets)
//        return imageUrl == nil ? ButtonLayout(layoutType: .titleCentered, marginInsets: insets)
//            : ButtonLayout(layoutType: .imageAndTitleCentered(padding: 10), marginInsets: insets)
    }
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        menuItemButton.tintsImagesToMatchTextColor = true
    }

    open override func style() {
        super.style()
		menuItemButton.styleMap = [
			.normal : .flat(textStyle: .regular(color: .textMedium)),
			.selected : .flat(textStyle: .regular(color: .selected))
		]
    }
}

extension ExamplePagingMenuItemCell: ObjectDisplayable{
    public typealias DisplayableObjectType = (imageUrl: String?, title: String)

    public func display(object: DisplayableObjectType) {
        menuItemButton.setTitle(object.title)
        imageUrl = object.imageUrl
        forceAutolayoutPass()
    }
}
