//
//  DatasourceManagedCollectionViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 4/12/19.
//  Copyright © 2019 Brian Strobach. All rights reserved.
//

import Swiftest

//open class DatasourceManagedCollectionViewController<DatasourceModel: Paginatable>: BaseCollectionViewController, DatasourceManaged {
//    open override func createStatefulViews() -> StatefulViewMap {
//        return .default
//    }
//
//    open func createDataSource() -> CollectionDataSource<DatasourceModel> {
//        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
//        return CollectionDataSource<DatasourceModel>()
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
//}
