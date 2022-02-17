//
//  ScrollViewHeader.swift
//  UIKitBase
//
//  Created by Brian Strobach on 9/2/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIKitBase

public class ScrollViewHeaderExamplesViewController: NavigationalMenuTableViewController{

    override public func viewDidLoad() {
        super.viewDidLoad()
        addRow(title: "Tableview with header", createDestinationVC: TableViewHeaderExampleViewController())
        addRow(title: "Tableview with header & subheader", createDestinationVC: TableViewSubheaderExampleViewController())
        addRow(title: "Nested scrollviews with header", createDestinationVC: ScrollViewParentHeaderExampleViewController())
        addRow(title: "Nested scrollviews with header & subheader", createDestinationVC: ScrollViewParentHeaderExampleViewController(includeSubheader: true))
        addRow(title: "Nested PagingMenuViewController with header", createDestinationVC: ScrollViewParentHeaderWithPagerExampleViewController())
        addRow(title: "Nested PagingMenuViewController with header & subheader", createDestinationVC: ScrollViewParentHeaderWithPagerExampleViewController(includeSubheader: true))
        addRow(title: "Nested inside tableviews", createDestinationVC: ScrollViewParentHeaderWithPagerExampleViewController(includeSubheader: true))
        addRow(title: "Nested inside UITabViewController", createDestinationVC: MainNavigationTabBarController(), presentModally: true)


    }
}

extension ScrollViewHeaderAdornable where Self: UIViewController{
    public typealias SVH = ScrollViewHeader
    
    public func displayScrollViewHeaderExampleContent(){
        guard let scrollViewHeader = scrollViewHeader else { return }
        let backgroundImageUrl = "http://www.heavymetal.com/wp-content/uploads/2015/06/big-trouble-in-little-china.jpg"
        do {
            try scrollViewHeader.headerBackgroundImageView.loadImage(with: backgroundImageUrl)
        }
        catch{

        }
        guard let subheader = scrollViewHeader.subheaderView as? ExampleSubheaderView else { return }
        subheader.dynamicHeightLabel.text = "lorem ipsum".repeated(count: 20)
    }
    
    public func createExampleScrollViewHeader(subheaderView: UIView? = nil) -> ScrollViewHeader {
        let expandedHeaderHeight: CGFloat = self.view.bounds.size.width/1.5
        let behaviors = [
            ScrollViewHeaderParallaxBehavior(),
            ScrollViewHeaderStretchBehavior(),
            ScrollViewHeaderFillColorBehavior(fillColor: .primary),
            ScrollViewVisualEffectBehavior(visualEffect: UIBlurEffect(style: .extraLight))
        ]
        return ScrollViewHeader(expandedHeaderHeight: expandedHeaderHeight,
                                collapsedHeaderHeight: navigationController!.navigationBar.frame.h + UIApplication.shared.statusBarFrame.h,
                                subheaderView: subheaderView,
                                behaviors: behaviors)
    }
    
    public func createExampleSubheaderView() -> UIView{
        return ExampleSubheaderView()
    }
}

public class ExampleSubheaderView: BaseView{
    let dynamicHeightLabel = UILabel().then { (label) in
        label.wrapWords()
    }
    open override func createSubviews() {
        super.createSubviews()
        addSubview(dynamicHeightLabel)
        
    }
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        dynamicHeightLabel.forceSuperviewToMatchContentSize()
        dynamicHeightLabel.forceAutolayoutPass()
        forceAutolayoutPass()
        backgroundColor = .yellow
        
    }
}

public class TabBarRootNavigationController: BaseNavigationController, TabBarChild {
    public override func initProperties() {
        super.initProperties()
        extendViewUnderNavigationBar()
    }

}

public class MainNavigationTabBarController: BaseTabBarController {

    lazy var vc1 = TableViewSubheaderExampleViewController()
    lazy var vc2 = ScrollViewParentHeaderExampleViewController()
    lazy var vc3 = ScrollViewParentHeaderExampleViewController(includeSubheader: true)
    lazy var vc4 = ScrollViewParentHeaderWithPagerExampleViewController()
    lazy var vc5 = ScrollViewParentHeaderWithPagerExampleViewController(includeSubheader: true)

    // MARK: NavigationControllers

    lazy var nav1 = TabBarRootNavigationController(rootViewController: self.vc1)
    lazy var nav2 = TabBarRootNavigationController(rootViewController: self.vc2)
    lazy var nav3 = TabBarRootNavigationController(rootViewController: self.vc3)
    lazy var nav4 = TabBarRootNavigationController(rootViewController: self.vc4)
    lazy var nav5 = TabBarRootNavigationController(rootViewController: self.vc5)


    lazy var initialViewControllers = [
        nav1,
        nav2,
        nav3,
        nav4,
        nav5
    ]


    public override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers(initialViewControllers, animated: false)
    }


}
