//
//  CollectionDataSource.swift
//  Pods
//
//  Created by Brian Strobach on 2/7/17.
//
//

import DiffableDataSources
import Swiftest
import UIKitExtensions


/// Simplified TableViewDiffableDatasource that assumes a single section
public class TableViewDatasource<ItemIdentifierType: Hashable>: TableViewDiffableDataSource<String, ItemIdentifierType> {
    public override init(tableView: UITableView,
                         cellProvider: @escaping TableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

}

/// Simplified TableViewDiffableDatasource that assumes a single section
public class CollectionViewDataSource<ItemIdentifierType: Hashable>: CollectionViewDiffableDataSource<String, ItemIdentifierType> {
    public override init(collectionView: UICollectionView,
                         cellProvider: @escaping CollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }
}

public protocol DiffableDatasource {
    associatedtype DatasourceConsumer: UIScrollView
    associatedtype SectionIdentifierType: Hashable
    associatedtype ItemIdentifierType: Hashable
    associatedtype CellType
    associatedtype CellProvider = (DatasourceConsumer, IndexPath, ItemIdentifierType) -> CellType?

    func apply(_ snapshot: DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
               animatingDifferences: Bool)

    func snapshot() -> DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType?

    func indexPath(for itemIdentifier: ItemIdentifierType) -> IndexPath?

//    func numberOfItems(inSection section: Int) -> Int
    //    var datasourceConsumingView: View? { get }
    func defaultSection() -> SectionIdentifierType?
}

public extension DiffableDatasource {
    // Assumes single section datasource
    subscript(row: Int) -> ItemIdentifierType? {
        return itemIdentifier(for: row.indexPath)
    }

    subscript(indexPath: IndexPath) -> ItemIdentifierType? {
        return itemIdentifier(for: indexPath)
    }

    func add(models: ItemIdentifierType..., to section: SectionIdentifierType? = nil,
             animated: Bool = true) {
        add(models: models, to: section, animated: animated)
    }

    func add(sections: SectionIdentifierType..., animated: Bool = true) {
        add(sections: sections, animated: animated)
    }

    func add(models: [ItemIdentifierType],
             to section: SectionIdentifierType? = nil,
             animated: Bool = true) {
        let snapshot = self.snapshot()
        if let section = section ?? (numberOfSections() == 0 ? defaultSection() : nil) {
            snapshot.appendSections([section])
        }
        snapshot.appendItems(models)
        apply(snapshot, animatingDifferences: animated)
    }

    func add(sections: [SectionIdentifierType], animated: Bool = true) {
        let snapshot = self.snapshot()
        snapshot.appendSections(sections)
        apply(snapshot, animatingDifferences: animated)
    }

    func defaultSection() -> SectionIdentifierType? {
        return "" as? SectionIdentifierType ?? 0 as? SectionIdentifierType
    }

    func numberOfSections() -> Int {
        return snapshot().sectionIdentifiers.count
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        let snapshot = self.snapshot()
        return snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[section]).count
    }
}


extension CollectionViewDiffableDataSource: DiffableDatasource {
    //    public var datasourceConsumingView: View? {
    //        return self.collectionView
    //    }

    public typealias DatasourceConsumer = UICollectionView
    public typealias CellType = UICollectionViewCell
}

extension TableViewDiffableDataSource: DiffableDatasource {
    //    public var datasourceConsumingView: View? {
    //        return self.tableView
    //    }

    public typealias DatasourceConsumer = UITableView
    public typealias CellType = UITableViewCell

}

public protocol DatasourceManaged {
    associatedtype Datasource: DiffableDatasource
    var datasource: Datasource { get set }
}
