//
//  DatasourceManaged.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/11/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import DarkMagic
import Swiftest

public protocol DatasourceManaged: AsyncDatasourceChangeManager, StatefulViewController {
    associatedtype DatasourceModel: Paginatable
    associatedtype Datasource: CollectionDataSource<DatasourceModel>
    var dataSource: Datasource { get set }
//    func createDataSource() -> CollectionDataSource<DatasourceModel>
}

public extension DatasourceManaged where Self: UITableViewController {
    func reloadWithModels(models: [DatasourceModel]? = nil) {
        enqueue { [weak self] complete in
            guard let self = self else { return }
            if let models = models {
                self.dataSource.replaceModels(models: models)
            }
            self.reloadTableView(completion: complete)
        }
    }

    func reloadTableView(completion: @escaping VoidClosure, updateState: Bool = true) {
        transition(to: .loading)
        tableView.reloadData { [weak self] in
            guard let self = self else { return }
            if updateState {
                self.updateCurrentStateBasedOnDatasource(completion: completion)
            } else {
                completion()
            }
        }
    }

    func updateCurrentStateBasedOnDatasource(completion: @escaping VoidClosure) {
        switch dataSource.rawModels.count {
        case 0:
            transition(to: .empty, completion: completion)
            return
        default:
            transition(to: .loaded, completion: completion)
        }
    }

    func removeCells(whereModels test: (DatasourceModel) -> Bool) {
        let models = dataSource.rawModels.filter(test)
        removeCells(boundTo: models)
    }

    func removeCells(boundTo models: [DatasourceModel], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
        let models = models.filter { dataSource.rawModels.contains($0) }
        dataSource.remove(models: models)
        tableView.reloadData()
        if dataSource.rawModels.count == 0 {
            transition(to: .empty)
        }
    }

    func insertCells(boundTo models: [DatasourceModel], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
        let models = models.filter { dataSource.rawModels.contains($0) == false }
        /* let indices =*/ dataSource.add(models: models)
        tableView.reloadData()
        if currentState != .loaded, dataSource.rawModels.count > 0 {
            transition(to: .loaded)
        }
    }
}

private extension AssociatedObjectKeys {
    static let asyncDatasourceChangeQueue = AssociatedObjectKey<[AsyncDatasourceChange]>("asyncDatasourceChangeQueue")
    static let uponQueueCompletion = AssociatedObjectKey<VoidClosure?>("uponQueueCompletion")
}

private var dataSourceAssociated: UInt8 = 0

public extension AsyncDatasourceChangeManager where Self: NSObject {
    var asyncDatasourceChangeQueue: [AsyncDatasourceChange] {
        get {
            return self[.asyncDatasourceChangeQueue, []]
        }
        set {
            self[.asyncDatasourceChangeQueue] = newValue
        }
    }

    var uponQueueCompletion: VoidClosure? {
        get {
            return self[.uponQueueCompletion, nil]
        }
        set {
            self[.uponQueueCompletion] = newValue
        }
    }
}

//public extension DatasourceManaged where Self: NSObject {
//    var dataSource: CollectionDataSource<DatasourceModel> {
//        get {
//            // swiftformat:disable:next redundantSelf
//            return getAssociatedObject(for: &dataSourceAssociated, initialValue: self.createDataSource())
//        }
//        set {
//            setAssociatedObject(newValue, for: &dataSourceAssociated)
//        }
//    }
//}
