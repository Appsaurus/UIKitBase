//
//  StepProcessPagingMenuViewController.swift
//  UIKitBase
//
//  Created by Brian Strobach on 2/19/18.
//

import Layman
import Swiftest
import UIFontIcons
import UIKitExtensions
import UIKitTheme

open class StepProcessPagingMenuViewController: BaseParentPagingMenuViewController, StepProcessPagingMenuViewDelegate {
    open lazy var automaticallyPageToNextStep: Bool = false
    open lazy var stepModels: [StepProcessMenuStepViewModel] = {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return []
    }()

    // PagingMenuControllerDelegate
    open override func createPagingMenuView() -> PagingMenuView {
        return StepProcessPagingMenuView(delegate: self, options: pagingMenuViewOptions)
    }

    open override var pagingMenuViewOptions: PagingMenuViewOptions {
        let menuHeight: CGFloat = 75.0
        return PagingMenuViewOptions(layout: .horizontal(height: menuHeight),
                                     itemSizingBehavior: .spanWidthCollectivelyUnlessExceeding(numberOfCells: 4.5, height: menuHeight),
                                     scrollBehavior: .scrolls)
    }

    open override func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return [StepProcessPagingMenuItemCell.self]
    }

    open override func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        let cell: StepProcessPagingMenuItemCell = menuView.pagingMenuCollectionView.dequeueReusableCell(for: index)
        configure(cell: cell, at: index)
        switch index {
        case 0:
            cell.stepLinkVisibility = [.next]
        case pagingMenuNumberOfItems(for: menuView) - 1:
            cell.stepLinkVisibility = [.previous]
        default:
            cell.stepLinkVisibility = [.previousAndNext]
        }
        configure(cell: cell, at: index)

        return cell
    }

    open func configure(cell: StepProcessPagingMenuItemCell, at index: Int) {
        cell.menuItemButton.titleLabel.wrapWords()
        cell.display(object: stepModels[index])
    }

    open func completeStep(at index: Int, isComplete complete: Bool = true) {
        stepModels[index].complete = complete
        pagingMenuView.pagingMenuCollectionView.reloadData { [weak self] in
            guard let self = self else { return }
            if complete, self.automaticallyPageToNextStep, let nextStepIndex = self.nextAvailbleStepIndex(after: index) ?? self.nextAvailbleStepIndex() {
                self.transitionToPage(at: nextStepIndex)
            }
        }
    }

    open func nextAvailbleStepIndex(after index: Int = -1) -> Int? {
        guard let step = nextAvailableStep(after: index) else { return nil }
        return stepModels.index(of: step)
    }

    open func nextAvailableStep(after index: Int = -1) -> StepProcessMenuStepViewModel? {
        let nextIndex = index + 1
        guard nextIndex <= stepModels.lastIndex else { return nil }
        return stepModels[nextIndex...].first { (stepModel) -> Bool in
            !stepModel.complete && stepModel.unfulfilledPrerequisites.count == 0
        }
    }

    open override func pagingMenuView(menuView: PagingMenuView, canSelectItemAtIndex index: Int) -> Bool {
        let unfulfilledPrerequisites = stepModels[index].unfulfilledPrerequisites
        guard unfulfilledPrerequisites.count == 0 else {
            hintUncompletedSteps(steps: unfulfilledPrerequisites)
            return false
        }
        return super.pagingMenuView(menuView: menuView, canSelectItemAtIndex: index)
    }

    open func hintUncompletedSteps(steps: [StepProcessMenuStepViewModel]? = nil) {
        let steps = steps ?? stepModels.filter { !$0.complete }
        steps.forEach { step in
            guard let index = stepModels.index(where: { $0 === step })?.indexPath,
                let cell = pagingMenuView.pagingMenuCollectionView.cellForItem(at: index) as? StepProcessPagingMenuItemCell else {
                return
            }
            DispatchQueue.main.async {
                self.animateHintForUncompleted(step: step, cell: cell)
            }
        }
    }

    open func animateHintForUncompleted(step: StepProcessMenuStepViewModel, cell: StepProcessPagingMenuItemCell) {
        let imageView = cell.menuItemButton.imageView
        //		let titleLabel = cell.menuItemButton.titleLabel
        let bgColor = imageView.backgroundColor

        //		let titleColor = titleLabel.textColor
        let config = AnimationConfiguration(options: [.curveEaseInOut])
        cell.menuItemButton.animate(configuration: config, animations: {
//            titleLabel.textColor = .warning
            imageView.backgroundColor = .warning
        }, completion: {
            imageView.backgroundColor = bgColor
//                titleLabel.textColor = titleColor
        })
    }
}

public protocol StepProcessPagingMenuViewDelegate: PagingMenuViewDelegate {
    func configure(cell: StepProcessPagingMenuItemCell, at index: Int)
}

open class StepProcessMenuStepViewModel: Equatable {
    public static func == (lhs: StepProcessMenuStepViewModel, rhs: StepProcessMenuStepViewModel) -> Bool {
        return lhs.stepTitle == rhs.stepTitle
    }

    open var stepTitle: String
    open var completedStepTitleBuilder: (() -> String?)?
    open var complete: Bool = false
    open var prerequisiteSteps: [StepProcessMenuStepViewModel] = []

    public init(stepTitle: String, completedStepTitleBuilder: (() -> String?)? = nil, completed: Bool = false, prerequisiteSteps: [StepProcessMenuStepViewModel] = []) {
        self.stepTitle = stepTitle
        self.completedStepTitleBuilder = completedStepTitleBuilder
        complete = completed
        self.prerequisiteSteps = prerequisiteSteps
    }

    public var unfulfilledPrerequisites: [StepProcessMenuStepViewModel] {
        return prerequisiteSteps.filter { !$0.complete }
    }
}

open class StepProcessPagingMenuView: PagingMenuView {
    open override func createSelectionIndicatorView() -> UIView? {
        return BaseView()
    }

    open override func initProperties() {
        super.initProperties()
        selectionIndicatorAnimation = StepProcessBallMenuSelectionIndicatorAnimation()
    }

    open override func style() {
        super.style()
        pagingMenuCollectionView.backgroundColor = .primaryDark

        selectionIndicatorView?.apply(viewStyle: ViewStyle(backgroundColor: .primaryContrast, shape: .rounded))
    }

    open func updateLayoutOfSelectionIndicator(view: UIView, transition: IndexPathTransition) {
        guard let selectedCell = self.selectedMenuItemCell as? StepProcessPagingMenuItemCell else {
            view.frame = .zero
            return
        }

        view.frame.size = selectedCell.menuItemButton.imageView.frame.size * 0.7
        view.center = selectedCell.menuItemButton.imageView.frameConvertedToCoordinateSpace(of: view).center
    }

    open override func viewForSelectedCollectioMenuItem() -> UIView? {
        guard let selectedCell = self.selectedMenuItemCell as? StepProcessPagingMenuItemCell else {
            return nil
        }
        return selectedCell.menuItemButton.imageView
    }
}

public class StepProcessBallMenuSelectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation {
    open override func finalFrameForSelectionIndicator(view: UIView, whenAnimatedTo selectedView: UIView) -> CGRect {
        var frame = CGRect()
        frame.size = selectedView.frame.size * 0.7
        let center = selectedView.frameConvertedToCoordinateSpace(of: view).center
        frame.x = center.x - frame.w / 2.0
        frame.y = center.y - frame.h / 2.0
        return frame
    }
}

private extension CGRect { // Disambiguates from Motion. Not sure how else to do this in swift when there is a clash in extensions like that.
    var center: CGPoint {
        return CGPoint(x: x + w / 2, y: y + h / 2)
    }
}

open class StepProcessPagingMenuItemCell: PagingMenuButtonCell, ObjectDisplayable {
    public typealias DisplayableObjectType = StepProcessMenuStepViewModel

    public enum StepProcessLinkVisibility {
        case previous, next, previousAndNext, none
    }

    open var previousStepLinkView: UIView = UIView()
    open var nextStepLinkView: UIView = UIView()
    open var stepLinkVisibility: Set<StepProcessLinkVisibility> = [.none] {
        didSet {
            previousStepLinkView.isVisible = stepLinkVisibility.contains(.previous) || stepLinkVisibility.contains(.previousAndNext)
            nextStepLinkView.isVisible = stepLinkVisibility.contains(.next) || stepLinkVisibility.contains(.previousAndNext)
        }
    }

    public func display(object: StepProcessMenuStepViewModel) {
        menuItemButton.setTitle(object.stepTitle)
        switch object.complete {
        case true:
            markAsCompleted(title: object.completedStepTitleBuilder?() ?? object.stepTitle)
        case false:
            markAsIncomplete()
        }
    }

    open func markAsIncomplete() {
        menuItemButton.imageView.image = nil
        menuItemButton.titleMap[.overrideAll] = nil
        menuItemButton.styleMap[.overrideAll] = nil
    }

    open func markAsCompleted(title: String) {
        menuItemButton.imageView.setFontIconImage(MaterialIcons.Check)
        menuItemButton.titleMap[.overrideAll] = title
        menuItemButton.styleMap[.overrideAll] = menuItemButton.styleMap[.selected]
    }

    open override func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubviews(previousStepLinkView, nextStepLinkView)
        menuItemButton.moveToFront()
    }

    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        [previousStepLinkView, nextStepLinkView].forEach { view in
            view.height.equal(to: menuItemButton.imageView.height.times(0.25))
            view.centerY.equal(to: menuItemButton.imageView.centerY)
        }
        previousStepLinkView.trailing.equal(to: menuItemButton.imageView.centerX)
        previousStepLinkView.leading.equalToSuperview()
        nextStepLinkView.leading.equal(to: menuItemButton.imageView.centerX)
        nextStepLinkView.trailing.equalToSuperview()
    }

    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        menuItemButton.tintsImagesToMatchTextColor = true
    }

    open override func menuItemButtonLayout() -> ButtonLayout {
        let insets = LayoutPadding(horizontal: 0, vertical: 10)
        let imageInsets = LayoutPadding(horizontal: 0, vertical: 5)
        return ButtonLayout(layoutType: .centerTitleUnderImage(padding: 5.0), marginInsets: insets, imageInsets: imageInsets)
    }

    open override func style() {
        super.style()
        let viewStyle = ViewStyle(backgroundColor: .clear)

        let font: UIFont = .heavy(10.scaledForDevice())
        let textStyle = TextStyle(color: .primary, font: font)
        let selectedTextStyle = TextStyle(color: .primaryContrast, font: font)
        let normalButtonStyle = ButtonStyle(textStyle: textStyle, viewStyle: viewStyle)
        let selectedButtonStyle = ButtonStyle(textStyle: selectedTextStyle, viewStyle: viewStyle)
        menuItemButton.styleMap = [
            .normal: normalButtonStyle,
            .selected: selectedButtonStyle
        ]

        let pathStyle = ViewStyle(backgroundColor: .primary)
        nextStepLinkView.apply(viewStyle: pathStyle)
        previousStepLinkView.apply(viewStyle: pathStyle)
        let imageViewStyle = ViewStyle(backgroundColor: .primary, shape: .rounded)
        menuItemButton.imageView.apply(viewStyle: imageViewStyle)
        apply(viewStyle: .clear)
    }
}
