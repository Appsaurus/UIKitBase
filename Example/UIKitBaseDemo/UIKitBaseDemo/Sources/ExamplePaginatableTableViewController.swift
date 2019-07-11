//
//  ExamplePaginatableTableViewController.swift
//  UIKitBaseExample
//
//  Created by Brian Strobach on 10/29/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKitBase
import Swiftest
import UIKitBase
import UIKitMixinable

open class ExamplePaginatableTableViewController: PaginatableTableViewController, SearchResultsDisplaying, DismissButtonManaged {

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [PaginationManagedMixin(self)]
    }

    public var paginator: Paginator<ItemIdentifierType> = ExampleQueryPaginator()

    public lazy var datasource = TableViewDatasource<ExampleObject>(tableView: tableView) { tableView, indexPath, model in
        let cell: ExampleStackTableViewCell = tableView.dequeueReusableCell(indexPath)

        cell.leftImageView.loadImage(with: "https://media.licdn.com/dms/image/C4D0BAQFxm_sSPnumoQ/company-logo_200_200/0?e=2159024400&v=beta&t=QWLPDxc-GV-8jBpr0-VKCTcnLhHYg12d9aBK4ZYTcgU",
                                     errorImage: nil)
        cell.mainLabel.text = "\(indexPath.row) " + model.name
        cell.detailLabel.text = model.company
        return cell
    }


    open override func createStatefulViews() -> StatefulViewMap {
        return .default
    }

    open func registerReusables() {
        tableView.register(ExampleStackTableViewCell.self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.automaticallySizeCellHeights(100)
    }

}

open class ExampleStackTableViewCell: SimpleTableViewCell{}

//open class ExampleCollectionDatasource: CollectionDataSource<ExampleObject>{
//    open override func filterModels(models: [ExampleObject], searchQuery: String) -> [ExampleObject] {
//        return models.filter({ (object) -> Bool in
//            object.name.contains(searchQuery)
//        })
//    }
//}
open class ExampleQueryPaginator: CursorPaginator<ExampleObject>{
    
    open var pageCount: Int = 5
    open var currentPage: Int = 1

    
    open override func fetchNextPage(success: @escaping ((items: [ExampleObject], isLastPage: Bool)) -> Void, failure: @escaping ErrorClosure) {
//        MockableNetwork.makeFakeNetworkCall(delay: 1, chanceOfSuccess: 100, success: { [weak self] in
//            guard let `self` = self else { return }
            self.pageCount += 1
            var objs: [ExampleObject] = []
            20.times {
                objs.append(ExampleObject())
            }
            success((objs, false))
//        }) {
//            failure(BasicError.error)
//        }
    }
}
