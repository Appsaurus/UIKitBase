////
////  BaseContainedTableViewController.swift
////  AppsaurusUIKit
////
////  Created by Brian Strobach on 10/20/17.
////
//
//import Foundation
//import UIKitMixinable
//
//open class BaseContainedTableViewController: BaseContainerViewController, ViewRecycler, UITableViewControllerProtocol{
//    open override func createMixins() -> [LifeCycle] {
//        return super.createMixins() + [ViewRecyclerMixin(self)]
//    }
//    open lazy var tableViewStyle: UITableView.Style = .grouped
//    open lazy var tableView: UITableView = UITableView(frame: .zero, style: self.tableViewStyle).then { (tv) in
//        tv.backgroundColor = .clear
//    }
//    open override lazy var containedView: UIView? = tableView
//
//    open override func didInit() {
//        super.didInit()
//        tableView.setController(self)
//    }
//    open func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }
//    
//    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//}
