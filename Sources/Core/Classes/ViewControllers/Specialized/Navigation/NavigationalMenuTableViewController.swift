//
//  NavigationalMenuTableViewController.swift
//  Pods
//
//  Created by Brian Strobach on 9/1/17.
//
//

import Layman
import Swiftest
import UIKitTheme

open class NavigationalMenuTableViewController: BaseTableViewController {

    open override func initProperties() {
        super.initProperties()
        self.navigationBarStyle = .primary
    }
    open var cells: [NavigationalMenuTableViewCellDatasource] = []
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cellData = cells[indexPath.row]
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        cell.textLabel?.font = .regular(15.0)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.textLabel?.text = cellData.title
        cell.imageView?.image = cellData.leftImage
        return cell
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = cells[indexPath.row]

        if !cellData.presentModally, let navVC = self.navigationController {
            navVC.pushViewController(cellData.createDestinationVC(), animated: true)
        } else {
            let destinationVC = cellData.createDestinationVC()
            destinationVC.modalPresentationStyle = .fullScreen
            present(destinationVC, animated: true, completion: nil)
        }
    }

    open func addRow(leftImage: UIImage? = nil, title: String, createDestinationVC: @escaping @autoclosure () -> UIViewController, presentModally: Bool = false) {
        cells.append(NavigationalMenuTableViewCellDatasource(leftImage: leftImage, title: title, createDestinationVC: createDestinationVC, presentModally: presentModally))
    }
}

public struct NavigationalMenuTableViewCellDatasource {
    var leftImage: UIImage?
    var title: String
    var createDestinationVC: () -> UIViewController
    var presentModally: Bool = false
}
