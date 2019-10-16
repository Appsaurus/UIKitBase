//
//  PagingWebViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 1/30/18.
//

import Algorithm
import Layman
import SafariServices
import Swiftest
import UIKitExtensions
import UIKitTheme
import WebKit

open class PagingWebViewController: BaseParentPagingMenuViewController, DismissButtonManaged {
    open var titledUrls: SortedDictionary<String, URL> = SortedDictionary<String, URL>()

    public required init(titledUrlStrings: SortedDictionary<String, String>) {
        for titledUrlString in titledUrlStrings {
            guard let url = titledUrlString.value?.toURL else {
                continue
            }
            titledUrls.insert(value: url, for: titledUrlString.key)
        }
        super.init(callInitLifecycle: true)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func createPagingMenuView() -> PagingMenuView {
        return WebViewPagingMenuView(delegate: self, options: pagingMenuViewOptions)
    }

    open override func createPagedViewControllers() -> [UIViewController] {
        var vcs: [UIViewController] = []
        for titledUrl in titledUrls {
            guard let url = titledUrl.value else { continue }
            let vc = UIViewController()
            let webView = WKWebView()
            vc.view = webView
            webView.load(URLRequest(url: url))
            vc.title = titledUrl.key
            vcs.append(vc)
        }
        return vcs
    }

    // MARK: PagingMenuController

    open override var pagingMenuViewOptions: PagingMenuViewOptions {
        let menuHeight: CGFloat = 50.0
        let sizing: PagingeMenuViewItemSizingBehavior = .spanWidthCollectively(height: menuHeight * 0.75)
        return PagingMenuViewOptions(layout: .horizontal(height: menuHeight), itemSizingBehavior: sizing, scrollBehavior: .tabBar)
    }

    open override func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return [WebViewPagingMenuItemCell.self]
    }

    open override func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize {
        let cell: WebViewPagingMenuItemCell = WebViewPagingMenuItemCell()
        configure(cell: cell, at: index)
        return cell.calculateDynamicSize(fixedDimension: .height(size: menuView.frame.h))
    }

    open override func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        let cell: WebViewPagingMenuItemCell = menuView.pagingMenuCollectionView.dequeueReusableCell(for: index)
        configure(cell: cell, at: index)
        return cell
    }

    open func configure(cell: WebViewPagingMenuItemCell, at index: Int) {
        cell.menuItemButton.setTitle(titledUrls[index].key)
        cell.menuItemButton.buttonLayout = cell.menuItemButtonLayout()
        cell.forceAutolayoutPass()
    }
}

open class WebViewPagingMenuView: PagingMenuView {
    open override func createSelectionIndicatorView() -> UIView? {
        return UIView()
    }

    open override func style() {
        super.style()
        selectionIndicatorView?.backgroundColor = .primary
    }

    open func animateLayoutOfSelectionIndicator(layoutUpdate: @escaping VoidClosure) {
        DispatchQueue.main.async {
            self.springAnimate(configuration: SpringAnimationConfiguration(duration: 0.4, springDamping: 0.7), animations: {
                layoutUpdate()
            })
        }
    }
}

open class WebViewPagingMenuItemCell: PagingMenuButtonCell {
    open override func menuItemButtonLayout() -> ButtonLayout {
        let insets = LayoutPadding(10)
        return ButtonLayout(layoutType: .titleCentered, marginInsets: insets)
    }

    open override func style() {
        super.style()
        let viewStyle = ViewStyle(backgroundColor: .clear)

        let fontSize: CGFloat = CGFloat(12.0).scaledForDevice(scaleDownOnly: true)
        let font: UIFont = .regular(fontSize)
        let textStyle = TextStyle(color: .textMedium, font: font)
        let selectedTextStyle = TextStyle(color: .primary, font: font)
        let normalButtonStyle = ButtonStyle(textStyle: textStyle, viewStyle: viewStyle)
        let selectedButtonStyle = ButtonStyle(textStyle: selectedTextStyle, viewStyle: viewStyle)
        menuItemButton.styleMap = [
            .normal: normalButtonStyle,
            .selected: selectedButtonStyle
        ]
    }
}
