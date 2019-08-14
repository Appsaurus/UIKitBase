//
//  DiffableDataSource.swift
//  Pods
//
//  Created by Brian Strobach on 2/7/17.
//
//

import DiffableDataSources
import Swiftest
import UIKitExtensions


/// Simplified TableViewDiffableDatasource that assumes a single section
open class TableViewDatasource<ItemIdentifierType: Hashable>: TableViewDiffableDataSource<String, ItemIdentifierType> {
    public var usesSectionsAsHeaderTitles: Bool = false

    public override init(tableView: UITableView,
                         cellProvider: @escaping TableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    @objc   public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard usesSectionsAsHeaderTitles else { return nil }
        return snapshot().sectionIdentifiers[section]
    }

}

/// Simplified TableViewDiffableDatasource that assumes a single section
open class CollectionViewDataSource<ItemIdentifierType: Hashable>: CollectionViewDiffableDataSource<String, ItemIdentifierType> {
    public override init(collectionView: UICollectionView,
                         cellProvider: @escaping CollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }
}

public protocol DiffableDatasource {
    typealias Snapshot = DiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
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
    subscript(row: Int) -> ItemIdentifierType {
        return itemIdentifier(for: row.indexPath)!
    }

    subscript(indexPath: IndexPath) -> ItemIdentifierType {
        return itemIdentifier(for: indexPath)!
    }

    subscript(safe row: Int) -> ItemIdentifierType? {
        return itemIdentifier(for: row.indexPath)
    }

    subscript(safe indexPath: IndexPath) -> ItemIdentifierType? {
        return itemIdentifier(for: indexPath)
    }

    func clearData(animated: Bool = true,
                   completion: @escaping VoidClosure = {}){
        apply(Snapshot(), animatingDifferences: animated, completion: completion)
    }

    func load(_ sectionedItems: [SectionIdentifierType: [ItemIdentifierType]],
              animated: Bool = true,
              completion: @escaping VoidClosure = {}){
        append(sectionedItems, to: Snapshot(), animated: animated, completion: completion)
    }

    func append(_ sectionedItems: [SectionIdentifierType: [ItemIdentifierType]],
                animated: Bool = true,
                completion: @escaping VoidClosure = {}) {
        append(sectionedItems, to: self.snapshot(), animated: animated, completion: completion)
    }

    private func append(_ sectionedItems: [SectionIdentifierType: [ItemIdentifierType]],
                        to snapshot: Snapshot,
                        animated: Bool = true,
                        completion: @escaping VoidClosure = {}) {
        snapshot.appendSections(Array(sectionedItems.keys))
        for itemSection in sectionedItems {
            snapshot.appendItems(itemSection.value, toSection: itemSection.key)
        }
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }



    func load(_ items: [ItemIdentifierType],
              into section: SectionIdentifierType? = nil,
              animated: Bool = true,
              completion: @escaping VoidClosure = {}){
        append(items, to: section, using: Snapshot(), animated: animated, completion: completion)
    }

    func append(_ items: [ItemIdentifierType],
                to section: SectionIdentifierType? = nil,
                animated: Bool = true,
                completion: @escaping VoidClosure = {}) {
        append(items, to: section, using: self.snapshot(), animated: animated, completion: completion)
    }

    private func append(_ items: [ItemIdentifierType],
                to section: SectionIdentifierType? = nil,
                using snapshot: Snapshot,
                animated: Bool = true,
                completion: @escaping VoidClosure = {}) {
        snapshot.append(section: section, fallback: defaultSection())
            .appendItems(items, toSection: section ?? defaultSection())

        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    func apply(_ snapshot: Snapshot, animatingDifferences: Bool = true, completion: @escaping VoidClosure) {

        UIView.animate(withDuration: 0, animations: {
            self.apply(snapshot, animatingDifferences: animatingDifferences)
        }, completion: { _ in completion() })
    }

//    func append(sections: [SectionIdentifierType], animated: Bool = true, completion: @escaping VoidClosure = {}) {
//        let snapshot = self.snapshot()
//        snapshot.appendSections(sections)
////        UIView.animate(withDuration: 0, animations: {
//            self.apply(snapshot, animatingDifferences: animated)
////        }, completion: { _ in completion() })
//        completion()
//    }



    func defaultSection() -> SectionIdentifierType? {
        return "DefaultSection" as? SectionIdentifierType ?? 0 as? SectionIdentifierType
    }

//    func numberOfSections() -> Int {
//        return snapshot().sectionIdentifiers.count
//    }

    func numberOfItems(inSection section: Int) -> Int {
        let snapshot = self.snapshot()
        return snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[section]).count
    }
}

public extension DiffableDatasource {

    func load(_ items: ItemIdentifierType...,
              into section: SectionIdentifierType? = nil,
              animated: Bool = true){
        append(items, to: section, using: Snapshot(), animated: animated)
    }

    func append(_ items: ItemIdentifierType...,
                to section: SectionIdentifierType? = nil,
                animated: Bool = true) {
        append(items, to: section, using: self.snapshot(), animated: animated)
    }
}

public extension DiffableDataSourceSnapshot {
    @discardableResult
    func append(section: SectionIdentifierType?, fallback: SectionIdentifierType?) -> Self {
        if let section = section {
            append(section: section)
        }
        else if let defaultSection = fallback {
            addDefaultSectionIfNeeded(section: defaultSection)
        }
        return self
    }

    @discardableResult
    func append(section: SectionIdentifierType?) -> Self {
        if let section = section, !sectionIdentifiers.contains(section) {
            appendSections([section])
        }
        return self
    }
    @discardableResult
    func addDefaultSectionIfNeeded(section: SectionIdentifierType?) -> Self {
        if sectionIdentifiers.count == 0, let section = section {
            appendSections([section])
        }
        return self
    }

    @discardableResult
    /// Deletes the all sections in the snapshot.
    public func deleteAllSections() -> Self {
        deleteSections(sectionIdentifiers)
        return self
    }

    /// Deletes the all data in the snapshot.
    public func deleteAllData() -> Self {
        deleteAllItems()
        deleteAllSections()
        return self
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
