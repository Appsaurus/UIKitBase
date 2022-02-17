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
        let cell: UserTableViewCell = tableView.dequeueReusableCell(indexPath)
        cell.display(model: UserDTO(id: indexPath.item, username: "Test", name: "test", avatarImage: "https://media.licdn.com/dms/image/C4D0BAQFxm_sSPnumoQ/company-logo_200_200/0?e=2159024400&v=beta&t=QWLPDxc-GV-8jBpr0-VKCTcnLhHYg12d9aBK4ZYTcgU"))
        return cell
    }


    open override func createStatefulViews() -> StatefulViewMap {
        return .default(for: self)
    }

    open override func registerReusables() {
        tableView.register(UserTableViewCell.self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.automaticallySizeCellHeights(100)
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DID SELECT")
    }

    deinit {
        print("DId init")
    }

}

//open class ExampleCollectionDatasource: CollectionDataSource<ExampleObject>{
//    open override func filterModels(models: [ExampleObject], searchQuery: String) -> [ExampleObject] {
//        return models.filter({ (object) -> Bool in
//            object.name.contains(searchQuery)
//        })
//    }
//}

public class UserPreviewCellView: CellLayoutView<UserBasicInfoView>  {

    public func display(model: UserDTO) {
        leftImageView.loadImage(with: model.avatarImage)
        middleView.display(model: model)
    }

    public override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        leftImageView.rounded = true
    }
}

public class UserBasicInfoView: BaseView {

    var stackView = VerticalLabelStackView()
    open lazy var nameLabel: UILabel = {return self.stackView.stackedView(at: 0)}()
    open lazy var usernameLabel: UILabel = {return self.stackView.stackedView(at: 1)}()

    private lazy var labels: [UILabel] = [nameLabel, usernameLabel]
    public override func createSubviews() {
        super.createSubviews()
        addSubview(stackView)
        stackView.addArrangedSubviews(labels)

    }

    public override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        stackView.forceSuperviewToMatchContentSize()
    }

    public func display(model: UserDTO) {
        nameLabel.text = model.name
        usernameLabel.text = model.username
    }

    public override func style() {
        super.style()
        nameLabel.apply(textStyle: .callout())
        usernameLabel.apply(textStyle: .caption1())
    }

}
open class ExampleQueryPaginator: CursorPaginator<ExampleObject>{
    
    open var pageCount: Int = 5
    open var currentPage: Int = 1

    
    open override func fetchNextPage(success: @escaping ((items: [ExampleObject], isLastPage: Bool)) -> Void, failure: @escaping ErrorClosure) {
        MockableNetwork.makeFakeNetworkCall(delay: 1, chanceOfSuccess: 100, success: { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                self.pageCount += 1
                var objs: [ExampleObject] = []
                20.times {
                    objs.append(ExampleObject())
                }
                success((objs, false))
            }
        }) {
            failure(BasicError.error)
        }
    }
}



public final class UserDTO: Codable, Identifiable {
    public var id: Int
    public var username: String
    public var name: String
    public var avatarImage: URL

    public init(id: Int,
                username: String,
                name: String,
                avatarImage: URL) {
        self.id = id
        self.username = username
        self.name = name
        self.avatarImage = avatarImage
    }
}

open class UserTableViewCell: ViewBasedTableViewCell<UserPreviewCellView>{

    public typealias Model = UserDTO

    open lazy var seguesToProfileViewController: Bool = true

    public func display(model: UserDTO) {
        view.display(model: model)
    }

    open override func style() {
        super.style()

    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        view.middleView.enforceContentSize()

    }
}
