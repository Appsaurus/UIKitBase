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
	public override func didInit() {
		super.didInit()
	}
    override public func viewDidLoad() {
        super.viewDidLoad()
        addRow(title: "Tableview with header", createDestinationVC: TableViewHeaderExampleViewController())
        addRow(title: "Tableview with header & subheader", createDestinationVC: TableViewSubheaderExampleViewController())
        addRow(title: "Nested scrollviews with header", createDestinationVC: ScrollViewParentHeaderExampleViewController())
        addRow(title: "Nested scrollviews with header & subheader", createDestinationVC: ScrollViewParentHeaderExampleViewController(includeSubheader: true))
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
