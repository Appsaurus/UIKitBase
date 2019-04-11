////
////  CollectionDataSource.swift
////  Pods
////
////  Created by Brian Strobach on 2/7/17.
////
////
//
// import Layman
// import Swiftest
// import UIKitExtensions
// import UIKitTheme
//
// open class CollectionDataSource<Value: Equatable>: SectionedCollectionDataSource<String, Value> {
//    open override func group(values: [Value]) -> [String: [Value]] {
//        return ["": values] // Defaults to single section collection
//    }
// }
//
// open class SectionedCollectionDataSource<SectionKey: Hashable, Value: Equatable> {
//    public init() {}
//
//    open class Section<SectionKey, Value> {}
//
//    open var searchQuery: String?
//    open var filterApplied: Bool {
//        return searchQuery != nil
//    }
//
//    open var rawModels: [Value] = []
//
//    open var models: [SectionKey: [Value]] = [:]
//    open var sections: [SectionKey] = []
//
//    open var filteredModels: [SectionKey: [Value]] = [:]
//    open var filteredSections: [SectionKey] = []
//
//    open var currentModels: [SectionKey: [Value]] {
//        return filterApplied ? filteredModels : models
//    }
//
//    open var currentSections: [SectionKey] {
//        return filterApplied ? filteredSections : sections
//    }
//
//    open var sectionCount: Int {
//        return currentSections.count
//    }
//
//    open func numberOfItems(section: Int) -> Int {
//        return items(in: section)?.count ?? 0
//    }
//
//    open func replaceModels(models: [Value]) {
//        rawModels = models
//        reindex()
//    }
//
//    @discardableResult
//    open func prepend(models: [Value]) -> [IndexPath] { // TODO: Optimize this with a diff library or algorithm
//        rawModels.prepend(contentsOf: models)
//        reindex()
//        var indices: [IndexPath] = []
//        for model in models {
//            if let indexPath: IndexPath = indexPath(of: model) {
//                indices.append(indexPath)
//            }
//        }
//        return indices
//    }
//
//    @discardableResult
//    open func add(models: [Value]) -> [IndexPath] { // TODO: Optimize this with a diff library or algorithm
//        rawModels.append(contentsOf: models)
//        reindex()
//        var indices: [IndexPath] = []
//        for model in models {
//            if let indexPath: IndexPath = indexPath(of: model) {
//                indices.append(indexPath)
//            }
//        }
//        return indices
//    }
//
//    open func removeAndReturnIndexes(models: [Value]) -> [IndexPath] { // TODO: Optimize this with a diff library or algorithm
//        var indexPathsRemoved: [IndexPath] = []
//        for model in models {
//            if let indexPath = self.indexPath(of: model) {
//                indexPathsRemoved.append(indexPath)
//            }
//        }
//        remove(models: models)
//        //        self.rawModels =  try self.rawModels.filter({ (model: Model) -> Bool in
//        //            return !models.contains(model)
//        //        })
//        //        reindex()
//        return indexPathsRemoved
//    }
//
//    open func remove(models: [Value]) {
//        rawModels = rawModels.filter { (model: Value) -> Bool in
//            !models.contains(model)
//        }
//        reindex()
//    }
//
//    open func reindex() {
//        reindexModels(models: rawModels)
//        if let query = searchQuery {
//            filterData(searchQuery: query)
//        }
//    }
//
//    private func reindexModels(models: [Value]) {
//        let indexData = indexModels(models: models)
//        self.models = indexData.0
//        sections = indexData.1
//    }
//
//    private func reindexFilteredModels(models: [Value]) {
//        let indexData = indexModels(models: models)
//        filteredModels = indexData.0
//        filteredSections = indexData.1
//    }
//
//    open func indexModels(models: [Value]) -> ([SectionKey: [Value]], sectionKeys: [SectionKey]) {
//        var sectionedValues: [SectionKey: [Value]] = group(values: models)
//        for (key, values) in sectionedValues {
//            sectionedValues[key] = sort(values: values, in: key)
//        }
//        let sections: [SectionKey] = sort(sections: Array(sectionedValues.keys))
//        return (sectionedValues, sections)
//    }
//
//    public typealias SectionSorter = (SectionKey, SectionKey) -> Bool
//    public typealias ValueSorter = (Value, Value) -> Bool
//
//    open var valueSorter: ValueSorter?
//    open var sectionSorter: SectionSorter?
//
//    open func sort(sections: [SectionKey]) -> [SectionKey] {
//        guard let sectionSorter = sectionSorter else { return sections }
//        return sections.sorted(by: sectionSorter)
//    }
//
//    open func sort(values: [Value], in section: SectionKey) -> [Value] {
//        guard let valueSorter = valueSorter else { return values }
//        return values.sorted(by: valueSorter)
//    }
//
//    open func group(values: [Value]) -> [SectionKey: [Value]] {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        return [:]
//    }
//
//    open func items(in section: Int) -> [Value]? {
//        guard sectionCount > 0 else { return nil }
//        if searchQuery == nil {
//            let sectionKey = sections[section]
//            return models[sectionKey]
//        } else {
//            let sectionKey = filteredSections[section]
//            return filteredModels[sectionKey]
//        }
//    }
//
//    // Assumes single section datasource
//    open subscript(row: Int) -> Value? {
//        let items = self.items(in: 0)
//        return items?[row]
//    }
//
//    open subscript(indexPath: IndexPath) -> Value? {
//        let items = self.items(in: indexPath.section)
//        return items?[indexPath.row]
//    }
//
//    open func indexPath(of model: Value) -> IndexPath? {
//        var emptySectionCount = 0
//        for (sectionIndex, sectionKey) in currentSections.enumerated() {
//            if currentModels[sectionKey]?.count == 0 {
//                emptySectionCount += 1 // Need to adjust for empty sections
//            }
//            if let models = currentModels[sectionKey]?.enumerated() {
//                for (modelIndex, modelToCheck) in models where modelToCheck == model {
//                    let indexPath = IndexPath(item: modelIndex, section: sectionIndex - emptySectionCount)
//                    return indexPath
//                }
//            }
//        }
//
//        return nil
//    }
//
//    open subscript(model: Value) -> IndexPath? {
//        return indexPath(of: model)
//    }
//
//    open func removeFilter() {
//        resetFilteredData()
//    }
//
//    open func filterData(searchQuery: String) {
//        self.searchQuery = searchQuery
//        let filtered: [Value] = filterModels(models: rawModels, searchQuery: searchQuery)
//        reindexFilteredModels(models: filtered)
//    }
//
//    open func filterModels(models: [Value], searchQuery: String) -> [Value] {
//        assertionFailure("You must implement search filtering")
//        return []
//    }
//
//    open func reset() {
//        rawModels = []
//        models = [:]
//        reindexModels(models: [])
//        resetFilteredData()
//    }
//
//    open func resetFilteredData() {
//        searchQuery = nil
//        filteredModels = [:]
//        filteredSections = []
//    }
// }
//
// open class DatasourceManagedTableViewController<ModelType: Equatable>: BaseTableViewController, AsyncDatasourceChangeManager {
//    // AsyncStateManagementQueue
//    public var asyncDatasourceChangeQueue: [AsyncDatasourceChange] = []
//    public var uponQueueCompletion: VoidClosure?
//
//    open var dependencyEntityId: String?
//
//    open lazy var dataSource: CollectionDataSource<ModelType> = CollectionDataSource<ModelType>()
//
//    open override func createStatefulViews() -> StatefulViewMap {
//        return .default
//    }
//
//    open func reloadWithModels(models: [ModelType]? = nil) {
//        enqueue { [weak self] complete in
//            guard let self = self else { return }
//            if let models = models {
//                self.dataSource.replaceModels(models: models)
//            }
//            self.reloadTableView(completion: complete)
//        }
//    }
//
//    open func reloadTableView(completion: @escaping VoidClosure, updateState: Bool = true) {
//        transition(to: .loading)
//        tableView.reloadData { [weak self] in
//            guard let self = self else { return }
//            if updateState {
//                self.updateCurrentStateBasedOnDatasource(completion: completion)
//            } else {
//                completion()
//            }
//        }
//    }
//
//    func updateCurrentStateBasedOnDatasource(completion: @escaping VoidClosure) {
//        switch dataSource.rawModels.count {
//        case 0:
//            transition(to: .empty, completion: completion)
//            return
//        default:
//            transition(to: .loaded, completion: completion)
//        }
//    }
//
//    // MARK: UITableViewControllerDelegate/Datasource
//
//    open override func numberOfSections(in tableView: UITableView) -> Int {
//        return dataSource.sectionCount
//    }
//
//    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.numberOfItems(section: section)
//    }
//
//    open func removeCells(whereModels test: (ModelType) -> Bool) {
//        let models = dataSource.rawModels.filter(test)
//        removeCells(boundTo: models)
//    }
//
//    open func removeCells(boundTo models: [ModelType], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
//        let models = models.filter { dataSource.rawModels.contains($0) }
//        dataSource.remove(models: models)
//        tableView.reloadData()
//        if dataSource.rawModels.count == 0 {
//            transition(to: .empty)
//        }
//    }
//
//    open func insertCells(boundTo models: [ModelType], withAnimation rowAnimation: UITableView.RowAnimation = .automatic) {
//        let models = models.filter { dataSource.rawModels.contains($0) == false }
//        /* let indices =*/ dataSource.add(models: models)
//        tableView.reloadData()
//        if currentState != .loaded, dataSource.rawModels.count > 0 {
//            transition(to: .loaded)
//        }
//    }
// }
//
// open class DatasourceManagedCollectionViewController<ModelType: Equatable>: BaseCollectionViewController {
//    open lazy var dataSource: CollectionDataSource<ModelType> = CollectionDataSource<ModelType>()
//
//    open override func createStatefulViews() -> StatefulViewMap {
//        return .default
//    }
//
//    // MARK: UICollectionViewControllerDelegate/Datasource
//
//    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return dataSource.sectionCount
//    }
//
//    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource.numberOfItems(section: section)
//    }
// }
