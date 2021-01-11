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
    open var titledUrls = SortedDictionary<String, URL>()

    public required init(titledUrlStrings: SortedDictionary<String, String>) {
        for titledUrlString in titledUrlStrings {
            guard let url = titledUrlString.value?.toURL else {
                continue
            }
            self.titledUrls.insert(value: url, for: titledUrlString.key)
        }
        super.init(callInitLifecycle: true)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func createPagingMenuView() -> PagingMenuView {
        return WebViewPagingMenuView(delegate: self, options: self.pagingMenuViewOptions)
    }

    override open func createPagedViewControllers() -> [UIViewController] {
        var vcs: [UIViewController] = []
        for titledUrl in self.titledUrls {
            guard let url = try? titledUrl.value?.assertURLPrefixingHTTPSchemeIfNeeded() else { continue }
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

    override open var pagingMenuViewOptions: PagingMenuViewOptions {
        let menuHeight: CGFloat = 50.0
        let sizing: PagingeMenuViewItemSizingBehavior = .spanWidthCollectivelyUnlessExceeding(numberOfCells: 3.5, height: menuHeight * 0.75)
        return PagingMenuViewOptions(layout: .horizontal(height: menuHeight), itemSizingBehavior: sizing, scrollBehavior: .scrolls)
    }

    override open func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return [WebViewPagingMenuItemCell.self]
    }

    override open func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize {
        let cell = WebViewPagingMenuItemCell()
        configure(cell: cell, at: index)
        return cell.calculateDynamicSize(fixedDimension: .height(size: menuView.frame.h))
    }

    override open func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        let cell: WebViewPagingMenuItemCell = menuView.pagingMenuCollectionView.dequeueReusableCell(for: index)
        self.configure(cell: cell, at: index)
        return cell
    }

    open func configure(cell: WebViewPagingMenuItemCell, at index: Int) {
        cell.menuItemButton.setTitle(self.titledUrls[index].key)
        cell.menuItemButton.buttonLayout = cell.menuItemButtonLayout()
        cell.forceAutolayoutPass()
    }

    open override func willPage(from page: Int?, to nextPage: Int?) {
        super.willPage(from: page, to: nextPage)
        guard let nextPage = nextPage, let vc: UIViewController = self.pagedViewControllers[safe: nextPage], let webView: WKWebView = vc.view as? WKWebView, let url = webView.url else { return }
        webView.load(URLRequest(url: url))
    }
}


open class WebViewPagingMenuView: PagingMenuView {
    override open func createSelectionIndicatorView() -> UIView? {
        return UIView()
    }

    override open func style() {
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
    override open func menuItemButtonLayout() -> ButtonLayout {
        let insets = LayoutPadding(10)
        return ButtonLayout(layoutType: .titleCentered, marginInsets: insets)
    }

    override open func style() {
        super.style()
        let viewStyle = ViewStyle(backgroundColor: .clear)

        let fontSize: CGFloat = 12.0.scaledForDevice(option: .upOnly)
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
