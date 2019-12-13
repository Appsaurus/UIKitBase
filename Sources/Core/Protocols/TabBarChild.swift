//
//  TabBarChildViewControllerProtocol.swift
//  Pods
//
//  Created by Brian Strobach on 1/15/17.
//
//

import Foundation
import Swiftest
import UIKit

public protocol Refreshable {
    func refresh()
}

public extension Refreshable where Self: PaginationManaged & ScrollViewReferencing {
    func refresh() {
        if paginationConfig.refreshable {
            scrollView.beginRefreshing()
        }
    }
}

public protocol TabBarChild {
    // Must be called by TabBarController at proper times
    func tabBarChildDidAppear()
    func tabItemWasTappedWhileActive()
}

// Forwards protocol calls to vc at end of navigation stack by default
public extension TabBarChild where Self: UINavigationController {
    private var stackedChild: TabBarChild? {
        return viewControllers.last as? TabBarChild
    }
    func tabItemWasTappedWhileActive() {
        stackedChild?.tabItemWasTappedWhileActive()
    }
    func tabBarChildDidAppear() {
        stackedChild?.tabBarChildDidAppear()
    }
}

// Scroll to top, then reload by default
public extension TabBarChild where Self: ScrollViewReferencing {
    func tabItemWasTappedWhileActive() {
        guard scrollView.hasReachedTopOfContent else {
            scrollView.scrollToTop()
            return
        }

        (self as? Refreshable)?.refresh()
    }

    func tabBarChildDidAppear() {}
}

// Forwards protocol calls to paged vc by default
public extension TabBarChild where Self: BaseParentPagingViewController {

    private var pagedChild: TabBarChild? {
        return currentPagedViewController as? TabBarChild
    }
    func tabItemWasTappedWhileActive() {
        pagedChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        pagedChild?.tabBarChildDidAppear()
    }
}

public extension TabBarChild where Self: BaseScrollviewParentViewController {
    private var contentChild: TabBarChild? {
        return self.children.first as? TabBarChild
    }

    func tabItemWasTappedWhileActive() {        
        guard scrollView.hasReachedTopOfContent else {
            scrollView.scrollToTop()
            return
        }
        contentChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        contentChild?.tabBarChildDidAppear()
    }
}

public extension TabBarChild where Self: BaseParentViewController {
    private var contentChild: TabBarChild? {
        return self.children.first as? TabBarChild
    }

    func tabItemWasTappedWhileActive() {
        contentChild?.tabItemWasTappedWhileActive()
    }

    func tabBarChildDidAppear() {
        contentChild?.tabBarChildDidAppear()
    }
}
