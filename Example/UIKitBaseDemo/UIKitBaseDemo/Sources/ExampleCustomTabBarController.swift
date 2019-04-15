//
//  ExampleCustomTabBarController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 2/15/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKitTheme
import UIKitBase
import UIFontIcons
import UIKitBase

public class ExampleCustomTabBarController: CustomTabBarController {

	let vc1: ExamplePaginatableTableViewController = ExamplePaginatableTableViewController().then { (vc) in
		vc.tabBarItem = UITabBarItem.item(withIcon: Feather.Airplay, title: "TAB 1")
	}

	let vc2: ExamplePaginatableTableViewController = ExamplePaginatableTableViewController().then { (vc) in
		vc.tabBarItem  = UITabBarItem.item(withIcon: Feather.BarChart2, title: "TAB 2")
	}

	let vc3: ExamplePagingMenuViewController = ExamplePagingMenuViewController().then { (vc) in
		vc.tabBarItem = UITabBarItem.item(withIcon: MaterialIcons.Ac_Unit, title: "TAB 3")
		vc.transitionToPage(at: 4)
	}

	let vc4: ExamplePaginatableTableViewController = ExamplePaginatableTableViewController().then { (vc) in
		vc.tabBarItem = UITabBarItem.item(withIcon: MaterialIcons.Account_Box, selectedIcon: MaterialIcons.Account_Balance, title: "TAB 4")
	}

	let vc5: ExamplePaginatableTableViewController = ExamplePaginatableTableViewController().then { (vc) in
		vc.tabBarItem = UITabBarItem.item(withIcon: MaterialIcons.Airline_Seat_Flat, selectedIcon: MaterialIcons.Airline_Seat_Flat_Angled, title: "TAB 5")
	}

    open override func initProperties() {
        super.initProperties()
        initialViewControllers = [vc1, vc2, vc3, vc4, vc5]
        customTabBar = ExampleCustomTabBar(datasource: self, delegate: self)
        initialSelectedIndex = 2
    }

//	open override lazy var tabBarLayout: CustomTabBarLayout = CustomTabBarLayout.left(width: 50.0)

	public override func tabBarItemViewForItem(at index: Int) -> CustomTabBarItemView {
		let item = ExampleCustomTabBarItemView(tabBarItem: self.viewControllers![index].tabBarItem)
		switch index {
		case 0:
			item.badgeView.state = .read
		case 1:
			item.badgeView.state = .redeemed
		default:
			item.badgeView.state = .unread

		}
		return item

	}
//	public override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		selectedIndex = 3
//	}

}

public class ExampleCustomTabBar: CustomTabBar{
    open override func initProperties() {
        super.initProperties()
        selectionIndicatorView = PassThroughView().then { (v) in
            v.backgroundColor = .clear
            v.borderColor = .black
            v.borderWidth = 4.0
        }
    }
}

public class ExampleCustomTabBarItemView: CustomTabBarItemView{
	open lazy var badgeView = {
		return ExampleCornerBadgeView(position: .topRightInside, badgeHeight: 20, state: .unread, viewStyleMap: [
			.unread: ViewStyle(backgroundColor: .primary),
			.read: ViewStyle(borderStyle: BorderStyle(borderColor: .primary, borderWidth: 5.0))
			]
		)
	}()

	open override func style() {
		super.style()
		styleMap.forEach { (k, v) in
			v.viewStyle.borderStyle = BorderStyle(borderColor: .textMedium, borderWidth: 4.0)
		}
	}

	public override func createSubviews() {
		super.createSubviews()

		badgeView.attachTo(view: self)
	}

}

public enum ExampleCornerBadgeViewState: State{
	case unread
	case read
	case redeemed
}
public class ExampleCornerBadgeView: CornerBadgeView<ExampleCornerBadgeViewState>{
	
}
