//
//  PagingMenuView.swift
//  Pods
//
//  Created by Brian Strobach on 7/8/17.
//
//

import Swiftest
import UIKitExtensions
import UIKitTheme

public protocol PagingMenuViewDelegate: AnyObject {
    func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type]
    func pagingMenuView(menuView: PagingMenuView, didSelectMenuItemCell: PagingMenuItemCell<UIView>, at index: Int)
    func pagingMenuView(menuView: PagingMenuView, didReselectCurrentMenuItemCell: PagingMenuItemCell<UIView>, at index: Int)
    func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView>
    func pagingMenuNumberOfItems(for menuView: PagingMenuView) -> Int
    func pagingMenuView(menuView: PagingMenuView, canSelectItemAtIndex index: Int) -> Bool
    func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize // Manually size cells when PagingMenuItemSizingBehavior is set to delegateSizing
}

extension PagingMenuViewDelegate {
    public func defaultMenuItemCellClasses() -> [PagingMenuItemCell<UIView>.Type] {
        return []
    }

    public func pagingMenuView(menuView: PagingMenuView, sizeForItemAt index: Int) -> CGSize {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return .zero
    }
}

public enum PagingMenuViewOrientation {
    case vertical(width: CGFloat)
    case horizontal(height: CGFloat)
    public var fixedDimensionValue: CGFloat {
        switch self {
        case let .horizontal(height):
            return height
        case let .vertical(width):
            return width
        }
    }
}

public class PagingMenuViewOptions {
    public var layout: PagingMenuViewOrientation
    public var itemSizingBehavior: PagingeMenuViewItemSizingBehavior
    public var animatesSelectionChanges: Bool
    public var scrollBehavior: PagingeMenuViewScrollBehavior

    public init(layout: PagingMenuViewOrientation = .horizontal(height: 30.0),
                itemSizingBehavior: PagingeMenuViewItemSizingBehavior = .spanWidthCollectively(height: 30.0),
                scrollBehavior: PagingeMenuViewScrollBehavior = .tabBar,
                animatesSelectionChanges: Bool = true) {
        self.layout = layout
        self.itemSizingBehavior = itemSizingBehavior
        self.scrollBehavior = scrollBehavior
        self.animatesSelectionChanges = animatesSelectionChanges
    }
}

public func == (l: PagingeMenuViewItemSizingBehavior, r: PagingeMenuViewItemSizingBehavior) -> Bool {
    switch (l, r) {
    case (.equal, .equal), // For comparison matters, we don't care about size
         (.spanWidthCollectively, .spanWidthCollectively),
         (.spanWidth, .spanWidth),
         (.delegateSizing, .delegateSizing):
        return true
    default:
        return false
    }
}

public enum PagingeMenuViewItemSizingBehavior: Equatable {
    case equal(size: CGSize)
    case spanWidthCollectively(height: CGFloat) // For tab bar like behavior, disables scroll
    case spanWidth(numberOfCells: Float, height: CGFloat) // For tab bar like behavior, disables scroll
    case spanWidthCollectivelyUnlessExceeding(numberOfCells: Float, height: CGFloat)
    case delegateSizing
    case spanWidthProportionately(height: CGFloat) // Only works with PagingMenuButtonCell or PagingMenuLabelCells
}

public enum PagingeMenuViewScrollBehavior {
    case tabBar
    case scrolls
    case infiniteLoop
}

open class PagingMenuView: BaseView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CollectionMenuSelectionAnimator {
    public var initialSelectedMenuIndexPath: IndexPath? = 0
    public var selectedMenuIndexPath: IndexPath?
    public var hasLoadedInitialState: Bool = false
    internal weak var delegate: PagingMenuViewDelegate!
    internal var options: PagingMenuViewOptions

    public var selectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation = .slidingUnderline
    open lazy var selectionIndicatorView: UIView? = {
        let indicator = self.createSelectionIndicatorView()
        indicator?.isUserInteractionEnabled = false
        return indicator
    }()

    open func createSelectionIndicatorView() -> UIView? {
        return nil
    }

    open override func style() {
        super.style()
        pagingMenuCollectionView.backgroundColor = .primaryContrast
    }

    public init(delegate: PagingMenuViewDelegate, options: PagingMenuViewOptions) {
        self.delegate = delegate
        self.options = options
        super.init(frame: .zero)
    }

    open override func initProperties() {
        super.initProperties()
        delegate.pagingMenuItemCellClasses(for: self).forEach { cellClass in
            pagingMenuCollectionView.register(cellClass)
        }
    }

    open override func createSubviews() {
        super.createSubviews()
        addSubview(pagingMenuCollectionView)
        guard let indicator = selectionIndicatorView else { return }
        pagingMenuCollectionView.addSubview(indicator)
    }

    //	open override func willMove(toWindow newWindow: UIWindow?) {
    //		super.willMove(toWindow: newWindow)
    //		if let index = selectedMenuIndexPath{
    //			pagingMenuCollectionView.selectItem(at: index.indexPath, animated: false, scrollPosition: [])
    //		}
    //	}

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        pagingMenuCollectionView.pinToSuperview()
        switch options.layout {
        case let .horizontal(height):
            self.height.equal(to: height)
        case let .vertical(width):
            assertionFailure("Unimplemented")
            self.width.equal(to: width)
        }
    }

    open func invalidateLayout() {
        pagingMenuCollectionView.collectionViewLayout.invalidateLayout()
        guard let index = selectedMenuIndexPath else { return }
        renderCollectionMenuItemSelectionIndicator(transition: IndexPathTransition(from: index, to: index))
    }

    open func reloadItems(selectedIndex: IndexPath?, animated: Bool = false, completion: VoidClosure? = nil) {
        DispatchQueue.main.async {
            self.pagingMenuCollectionView.reloadData { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    guard let index = selectedIndex ?? self.initialSelectedMenuIndexPath ?? self.selectedMenuIndexPath else { return }
                    self.selectItemProgramtically(at: index, animated: animated)
                    completion?()
                }
            }
        }
    }

    public func selectItemProgramtically(at index: IndexPath?, animated: Bool = false) {
        guard let index = index else { return }
        guard numberOfSections(in: pagingMenuCollectionView) >= index.section,
            collectionView(pagingMenuCollectionView, numberOfItemsInSection: index.section) >= index.row else { return }
        selectCollectionMenuItem(at: index, animated: animated)
        pagingMenuCollectionView.selectItem(at: index, animated: animated, scrollPosition: [])
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public lazy var pagingMenuCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //        if self.options.itemSizingBehavior == PagingeMenuViewItemSizingBehavior.delegateSizing{
        //            layout.estimatedItemSize = CGSize(width: 1, height: self.options.menuHeight)
        //        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setController(self)
        return collectionView
    }()

    // MARK: CollectionView Delegate/Datasource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard delegate != nil else { return 0 }
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.scrollBehavior == .infiniteLoop ? Int.max : delegate!.pagingMenuNumberOfItems(for: self)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        if options.scrollBehavior == .infiniteLoop {
            index = indexPath.row % delegate.pagingMenuNumberOfItems(for: self)
        }

        let cell = delegate.pagingMenuItemCell(for: self, at: index)
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true, !cell.isSelected {
            selectCollectionMenuItem(at: indexPath, animated: false)
        }

        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize: CGSize!
        let cellCount = self.collectionView(collectionView, numberOfItemsInSection: 0)

        switch options.itemSizingBehavior {
        case let .spanWidthCollectivelyUnlessExceeding(maxNumberOfCells, height):
            let width = cellCount.float > maxNumberOfCells ? frame.w / maxNumberOfCells.cgFloat : frame.w / cellCount.cgFloat
            cellSize = CGSize(width: width, height: height)
        case let .equal(size):
            cellSize = size
        case let .spanWidthCollectively(height):
            let width = frame.w / cellCount.cgFloat
            cellSize = CGSize(width: width, height: height)
        case let .spanWidth(numberOfCells, height):
            let width = frame.w / numberOfCells.cgFloat
            cellSize = CGSize(width: width, height: height)
        case .delegateSizing:
            cellSize = delegate.pagingMenuView(menuView: self, sizeForItemAt: indexPath.row)
        case let .spanWidthProportionately(height):
            var totalContentSize: CGFloat = 0.0
            var thisCellContentSize: CGFloat = 0.0
            for idx in 0 ... cellCount {
                let cellSize = self.collectionView(collectionView, cellForItemAt: idx.indexPath).intrinsicContentSize.width
                totalContentSize += cellSize
                if idx == indexPath.row { thisCellContentSize = cellSize }
            }
            cellSize = CGSize(width: thisCellContentSize / totalContentSize * collectionView.frame.width, height: height)
        }

        return cellSize
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return delegate?.pagingMenuView(menuView: self, canSelectItemAtIndex: indexPath.row) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    // Don't allow collectionview to deselect current selection (delegate method shouldDeselect does not work)
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //		if indexPath == selectedMenuIndexPath?.indexPath{
        //			collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        //			self.collectionView(pagingMenuCollectionView, didSelectItemAt: indexPath)
        //		}
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userDidSelectCollectionMenuItem(at: indexPath)
        //		if indexPath != selectedMenuIndexPath?.indexPath {
        //			userDidSelectCollectionMenuItem(at: indexPath)
        //		}
    }

    // MARK: Flow layout delegate

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: CollectionMenuSelectionAnimator

    open func userDidReselectCollectionMenuItem(at indexPath: IndexPath) {
        guard let cell: PagingMenuItemCell = pagingMenuCollectionView.cellForItem(at: indexPath) as? PagingMenuItemCell else { return }
        delegate?.pagingMenuView(menuView: self, didReselectCurrentMenuItemCell: cell, at: indexPath.intIndex)
    }

    open func didSelectCollectionMenuItem(at index: IndexPath?) {
        guard let index = index else { return }
        deselectAllOtherIndices(selectedIndex: index)
        guard let cell: PagingMenuItemCell = pagingMenuCollectionView.cellForItem(at: index) as? PagingMenuItemCell else { return }
        delegate?.pagingMenuView(menuView: self, didSelectMenuItemCell: cell, at: index.intIndex)
    }

    open func renderCollectionMenuItemSelection(transition: IndexPathTransition) {
        DispatchQueue.main.async {
            guard let selectedIndex = transition.route.to,
                let cell = self.pagingMenuCollectionView.cellForItem(at: selectedIndex) else {
                return
            }
            if cell.isSelected == false {
                self.pagingMenuCollectionView.selectItem(at: selectedIndex, animated: transition.animated, scrollPosition: [])
            }
            cell.isSelected = true
        }
    }

    public func viewForSelectedCollectioMenuItem() -> UIView? {
        return selectedMenuItemCell
    }

    //		public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //			guard collectionView === pagingMenuCollectionView else { return }
    //			guard indexPath.row == selectedIndex && selectedMenuItemCell !== cell else{
    //				return
    //			}
    //			//   disableAnimationsOnNextSelection = true
    //			pagingMenuCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
//
    //		}
}

extension PagingMenuView {
    open func deselectAllOtherIndices(selectedIndex: IndexPath, animated: Bool = true) {
        if let selectedIndices = pagingMenuCollectionView.indexPathsForSelectedItems {
            for idx in selectedIndices where idx != selectedIndex {
                pagingMenuCollectionView.deselectItem(at: idx, animated: animated)
            }
        }
    }

    open var selectedMenuItemCell: PagingMenuItemCell<UIView>? {
        let numRows = collectionView(pagingMenuCollectionView, numberOfItemsInSection: 0)
        guard let selectedIndexPath = selectedMenuIndexPath else { return nil }
        let selectedIndex = selectedIndexPath.intIndex
        guard selectedIndex >= 0, selectedIndex < numRows else {
            return nil
        }
        return pagingMenuCollectionView.cellForItem(at: selectedIndexPath) as? PagingMenuItemCell
    }
}

open class PagingMenuItemCell<View: UIView>: ViewBasedCollectionViewCell<UIView> {
    open func calculateProportionateSpanWidth(numberOfItems: CGFloat, totalWidth: CGFloat) -> CGFloat {
        return totalWidth / numberOfItems
    }
}

open class PagingMenuButtonCell: PagingMenuItemCell<UIView> {
    open func menuItemButtonLayout() -> ButtonLayout {
        return ButtonLayout(layoutType: .imageLeftTitleCenter)
    }

    open lazy var menuItemButton: BaseButton = {
        let button = BaseButton(buttonLayout: self.menuItemButtonLayout())
        button.isUserInteractionEnabled = false
        return button
    }()

    open override func createMainView() -> UIView {
        return menuItemButton
    }

    open override var isSelected: Bool {
        didSet {
            menuItemButton.state = isSelected ? .selected : .normal
        }
    }

    open override func style() {
        super.style()
        menuItemButton.styleMap = [
            .normal: .flat(textStyle: .regular(color: .deselected)),
            .selected: .flat(textStyle: .regular(color: .selected))
        ]
    }
}
