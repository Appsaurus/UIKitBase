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
    public weak var secondaryDatasource: UITableViewDataSource?

    public override init(tableView: UITableView,
                         cellProvider: @escaping TableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    @objc open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard usesSectionsAsHeaderTitles else {
            return secondaryDatasource?.tableView?(tableView, titleForHeaderInSection: section)
        }

        guard numberOfItems(inSection: section) > 0 else { return nil }
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
               animatingDifferences: Bool,
               completion: (() -> Void)?)

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

    func sectionIdentifier(_ section: Int) -> SectionIdentifierType? {
        return snapshot().sectionIdentifiers[safe: section]
    }

    func clearData(animated: Bool = false,
                   completion: @escaping VoidClosure = {}) {
        apply(Snapshot(), animatingDifferences: animated, completion: completion)
    }

    func load(_ sectionedItems: KeyValuePairs<SectionIdentifierType, [ItemIdentifierType]>,
              animated: Bool = false,
              completion: @escaping VoidClosure = {}) {
        append(sectionedItems, to: Snapshot(), animated: animated, completion: completion)
    }

    func append(_ sectionedItems: KeyValuePairs<SectionIdentifierType, [ItemIdentifierType]>,
                animated: Bool = false,
                completion: @escaping VoidClosure = {}) {
        append(sectionedItems, to: snapshot(), animated: animated, completion: completion)
    }

    private func append(_ sectionedItems: KeyValuePairs<SectionIdentifierType, [ItemIdentifierType]>,
                        to snapshot: Snapshot,
                        animated: Bool = false,
                        completion: @escaping VoidClosure = {}) {
        var snapshot = snapshot
        for itemSection in sectionedItems {
            snapshot.appendSections([itemSection.key])
            snapshot.appendItems(itemSection.value, toSection: itemSection.key)
        }
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    func load(_ items: [ItemIdentifierType],
              into section: SectionIdentifierType? = nil,
              animated: Bool = false,
              completion: @escaping VoidClosure = {}) {
        append(items, to: section, using: Snapshot(), animated: animated, completion: completion)
    }

    func append(_ items: [ItemIdentifierType],
                to section: SectionIdentifierType? = nil,
                animated: Bool = false,
                completion: @escaping VoidClosure = {}) {
        append(items, to: section, using: snapshot(), animated: animated, completion: completion)
    }

    private func append(_ items: [ItemIdentifierType],
                        to section: SectionIdentifierType? = nil,
                        using snapshot: Snapshot,
                        animated: Bool = false,
                        completion: @escaping VoidClosure = {}) {
        var snapshot = snapshot
        snapshot.append(section: section, fallback: defaultSection())
        snapshot.appendItems(items, toSection: section ?? defaultSection())
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    // MARK: Removing items

    func remove(_ items: ItemIdentifierType...,
                animated: Bool = false,
                completion: @escaping VoidClosure = {}) {
        remove(items, animated: animated, completion: completion)
    }

    func remove(_ items: [ItemIdentifierType],
                animated: Bool = false,
                completion: @escaping VoidClosure = {}) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(items)
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    // MARK: Inserting items

    /// Inserts the given item identifiers before the specified item.
    ///
    /// - Parameters:
    ///   - identifiers: The item identifiers to be inserted.
    ///   - beforeIdentifier: An identifier of item.
    func insertItems(_ identifiers: [ItemIdentifierType],
                     beforeItem beforeIdentifier: ItemIdentifierType,
                     animated: Bool = false,
                     completion: @escaping VoidClosure = {}) {
        var snapshot = self.snapshot()
        snapshot.insertItems(identifiers, beforeItem: beforeIdentifier)
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    /// Inserts the given item identifiers after the specified item.
    ///
    /// - Parameters:
    ///   - identifiers: The item identifiers to be inserted.
    ///   - afterIdentifier: An identifier of item.
    func insertItems(_ identifiers: [ItemIdentifierType],
                     afterItem afterIdentifier: ItemIdentifierType,
                     animated: Bool = false,
                     completion: @escaping VoidClosure = {}) {
        var snapshot = self.snapshot()
        snapshot.insertItems(identifiers, afterItem: afterIdentifier)
        apply(snapshot, animatingDifferences: animated, completion: completion)
    }

    func insertItem(_ identifier: ItemIdentifierType,
                    at indexPath: IndexPath,
                    animated: Bool = false,
                    completion: @escaping VoidClosure = {}) {
        var snapshot = self.snapshot()
        if snapshot.insert(identifier, at: indexPath) {
            apply(snapshot, animatingDifferences: animated, completion: completion)
            return
        }

        guard let sectionIdentifier = sectionIdentifier(indexPath.section) else {
            return
        }

        append([identifier], to: sectionIdentifier, animated: animated, completion: completion)
    }

//    func apply(_ snapshot: Snapshot, animatingDifferences: Bool = true, completion: @escaping VoidClosure = {}) {
//
//        self.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
//    }

//    func append(sections: [SectionIdentifierType], animated: Bool = false, completion: @escaping VoidClosure = {}) {
//        let snapshot = self.snapshot()
//        snapshot.appendSections(sections)
    /// /        UIView.animate(withDuration: 0, animations: {
//            self.apply(snapshot, animatingDifferences: animated)
    /// /        }, completion: { _ in completion() })
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
              animated: Bool = false) {
        append(items, to: section, using: Snapshot(), animated: animated)
    }

    func append(_ items: ItemIdentifierType...,
                to section: SectionIdentifierType? = nil,
                animated: Bool = false) {
        append(items, to: section, using: snapshot(), animated: animated)
    }
}

public extension DiffableDataSourceSnapshot {
    @discardableResult
    mutating func append(section: SectionIdentifierType?, fallback: SectionIdentifierType?) -> DiffableDataSourceSnapshot {
        if let section = section {
            append(section: section)
        } else if let defaultSection = fallback {
            addDefaultSectionIfNeeded(section: defaultSection)
        }
        return self
    }

    @discardableResult
    mutating func append(section: SectionIdentifierType?) -> DiffableDataSourceSnapshot {
        if let section = section, !sectionIdentifiers.contains(section) {
            appendSections([section])
        }
        return self
    }

    // MARK: Snapshot Insert

    @discardableResult
    mutating func insert(_ identifier: ItemIdentifierType,
                         at indexPath: IndexPath) -> Bool {
        guard let section = sectionIdentifiers[safe: indexPath.section] else { return false }
        let sectionItems = itemIdentifiers(inSection: section)

        if let currentItem = sectionItems[safe: indexPath.item] {
            insertItems([identifier], beforeItem: currentItem)
            return true
        }

        if let previousItem = sectionItems[safe: indexPath.item - 1] {
            insertItems([identifier], afterItem: previousItem)
            return true
        }

        return false
    }

    @discardableResult
    mutating func addDefaultSectionIfNeeded(section: SectionIdentifierType?) -> DiffableDataSourceSnapshot {
        if sectionIdentifiers.count == 0, let section = section {
            appendSections([section])
        }
        return self
    }

    @discardableResult
    /// Deletes the all sections in the snapshot.
    mutating func deleteAllSections() -> DiffableDataSourceSnapshot {
        deleteSections(sectionIdentifiers)
        return self
    }

    /// Deletes the all data in the snapshot.
    mutating func deleteAllData() -> DiffableDataSourceSnapshot {
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
