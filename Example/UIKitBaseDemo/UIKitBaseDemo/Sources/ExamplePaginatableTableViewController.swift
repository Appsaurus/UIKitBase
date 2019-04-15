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
    public typealias PaginatableModel = ExampleObject

    open override func createMixins() -> [LifeCycle] {
        return super.createMixins() + [PaginationManagedMixin(self)]
    }

    open override func initProperties() {
        super.initProperties()
        paginators.paginator = ExampleQueryPaginator()
        dataSource = ExampleCollectionDatasource()
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
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExampleStackTableViewCell = tableView.dequeueReusableCell(indexPath)

        cell.leftImageView.loadImage(with: "https://media.licdn.com/dms/image/C4D0BAQFxm_sSPnumoQ/company-logo_200_200/0?e=2159024400&v=beta&t=QWLPDxc-GV-8jBpr0-VKCTcnLhHYg12d9aBK4ZYTcgU",
                                     errorImage: nil)
        cell.primaryLabel.text = "\(indexPath.row) " + dataSource[indexPath]!.name
        cell.secondaryLabel.text = dataSource[indexPath]?.company
        return cell
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionCount
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(section: section)
    }

}

open class ExampleStackTableViewCell: LabelStackTableViewCell{}

open class ExampleCollectionDatasource: CollectionDataSource<ExampleObject>{
    open override func filterModels(models: [ExampleObject], searchQuery: String) -> [ExampleObject] {
        return models.filter({ (object) -> Bool in
            object.name.contains(searchQuery)
        })
    }
}
open class ExampleQueryPaginator: Paginator<ExampleObject>{
    
    open var pageCount: Int = 5
    open var currentPage: Int = 1
    open override func fetchNextPage(success: @escaping ((items: [ExampleObject], isLastPage: Bool)) -> Void, failure: @escaping ErrorClosure) {
        MockableNetwork.makeFakeNetworkCall(delay: 1, chanceOfSuccess: 100, success: { [weak self] in
            guard let `self` = self else { return }
            self.pageCount += 1
            var objs: [ExampleObject] = []
            20.times {
                objs.append(ExampleObject())
            }
            
            self.nextPageToken = self.currentPage == self.pageCount ? nil : "Token"
            success((objs, self.nextPageToken == nil))
        }) {
            failure(BasicError.error)
        }
        
    }
}
