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
import MaterialIcons

open class StepProcessPagingMenuViewController: BaseParentPagingMenuViewController, StepProcessPagingMenuViewDelegate {
    open lazy var automaticallyPageToNextStep: Bool = false
    open lazy var stepModels: [StepProcessMenuStepViewModel] = {
        assertionFailure(String(describing: self) + " is abstract. You must implement " + #function)
        return []
    }()

    // PagingMenuControllerDelegate
    override open func createPagingMenuView() -> PagingMenuView {
        return StepProcessPagingMenuView(delegate: self, options: self.pagingMenuViewOptions)
    }

    override open var pagingMenuViewOptions: PagingMenuViewOptions {
        let menuHeight: CGFloat = 75.0
        return PagingMenuViewOptions(layout: .horizontal(height: menuHeight),
                                     itemSizingBehavior: .spanWidthCollectivelyUnlessExceeding(numberOfCells: 4.5, height: menuHeight),
                                     scrollBehavior: .scrolls)
    }

    override open func pagingMenuItemCellClasses(for menuView: PagingMenuView) -> [PagingMenuItemCell<UIView>.Type] {
        return [StepProcessPagingMenuItemCell.self]
    }

    override open func pagingMenuItemCell(for menuView: PagingMenuView, at index: Int) -> PagingMenuItemCell<UIView> {
        let cell: StepProcessPagingMenuItemCell = menuView.pagingMenuCollectionView.dequeueReusableCell(for: index)
        self.configure(cell: cell, at: index)
        switch index {
        case 0:
            cell.stepLinkVisibility = [.next]
        case pagingMenuNumberOfItems(for: menuView) - 1:
            cell.stepLinkVisibility = [.previous]
        default:
            cell.stepLinkVisibility = [.previousAndNext]
        }
        self.configure(cell: cell, at: index)

        return cell
    }

    open func configure(cell: StepProcessPagingMenuItemCell, at index: Int) {
        cell.menuItemButton.titleLabel.wrapWords()
        cell.display(object: self.stepModels[index])
    }

    open func completeStep(at index: Int, isComplete complete: Bool = true) {
        self.stepModels[index].complete = complete
        self.pagingMenuView.pagingMenuCollectionView.reloadData { [weak self] in
            guard let self = self else { return }
            if complete, self.automaticallyPageToNextStep, let nextStepIndex = self.nextAvailbleStepIndex(after: index) ?? self.nextAvailbleStepIndex() {
                self.transitionToPage(at: nextStepIndex)
            }
        }
    }

    open func nextAvailbleStepIndex(after index: Int = -1) -> Int? {
        guard let step = nextAvailableStep(after: index) else { return nil }
        return self.stepModels.firstIndex(of: step)
    }

    open func nextAvailableStep(after index: Int = -1) -> StepProcessMenuStepViewModel? {
        let nextIndex = index + 1
        guard nextIndex <= self.stepModels.lastIndex else { return nil }
        return self.stepModels[nextIndex...].first { stepModel -> Bool in
            !stepModel.complete && stepModel.unfulfilledPrerequisites.count == 0
        }
    }

    override open func pagingMenuView(menuView: PagingMenuView, canSelectItemAtIndex index: Int) -> Bool {
        let unfulfilledPrerequisites = self.stepModels[index].unfulfilledPrerequisites
        guard unfulfilledPrerequisites.count == 0 else {
            self.hintUncompletedSteps(steps: unfulfilledPrerequisites)
            return false
        }
        return super.pagingMenuView(menuView: menuView, canSelectItemAtIndex: index)
    }

    open func hintUncompletedSteps(steps: [StepProcessMenuStepViewModel]? = nil) {
        let steps = steps ?? self.stepModels.filter { !$0.complete }
        steps.forEach { step in
            guard let index = stepModels.firstIndex(where: { $0 === step })?.indexPath,
                  let cell = pagingMenuView.pagingMenuCollectionView.cellForItem(at: index) as? StepProcessPagingMenuItemCell
            else {
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
        self.complete = completed
        self.prerequisiteSteps = prerequisiteSteps
    }

    public var unfulfilledPrerequisites: [StepProcessMenuStepViewModel] {
        return self.prerequisiteSteps.filter { !$0.complete }
    }
}

open class StepProcessPagingMenuView: PagingMenuView {
    override open func createSelectionIndicatorView() -> UIView? {
        return BaseView()
    }

    override open func initProperties() {
        super.initProperties()
        selectionIndicatorAnimation = StepProcessBallMenuSelectionIndicatorAnimation()
    }

    override open func style() {
        super.style()
        pagingMenuCollectionView.backgroundColor = .primaryDark

        selectionIndicatorView?.apply(viewStyle: ViewStyle(backgroundColor: .primaryContrast, shape: .rounded))
    }

    open func updateLayoutOfSelectionIndicator(view: UIView, transition: IndexPathTransition) {
        guard let selectedCell = selectedMenuItemCell as? StepProcessPagingMenuItemCell else {
            view.frame = .zero
            return
        }

        view.frame.size = selectedCell.menuItemButton.imageView.frame.size * 0.7
        view.center = selectedCell.menuItemButton.imageView.frameConvertedToCoordinateSpace(of: view).center
    }

    override open func viewForSelectedCollectioMenuItem() -> UIView? {
        guard let selectedCell = selectedMenuItemCell as? StepProcessPagingMenuItemCell else {
            return nil
        }
        return selectedCell.menuItemButton.imageView
    }
}

public class StepProcessBallMenuSelectionIndicatorAnimation: CollectionMenuSelectionIndicatorAnimation {
    override open func finalFrameForSelectionIndicator(view: UIView, whenAnimatedTo selectedView: UIView) -> CGRect {
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

    open var previousStepLinkView = UIView()
    open var nextStepLinkView = UIView()
    open var stepLinkVisibility: Set<StepProcessLinkVisibility> = [.none] {
        didSet {
            self.previousStepLinkView.isVisible = self.stepLinkVisibility.contains(.previous) || self.stepLinkVisibility.contains(.previousAndNext)
            self.nextStepLinkView.isVisible = self.stepLinkVisibility.contains(.next) || self.stepLinkVisibility.contains(.previousAndNext)
        }
    }

    public func display(object: StepProcessMenuStepViewModel) {
        menuItemButton.setTitle(object.stepTitle)
        switch object.complete {
        case true:
            self.markAsCompleted(title: object.completedStepTitleBuilder?() ?? object.stepTitle)
        case false:
            self.markAsIncomplete()
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

    override open func createSubviews() {
        super.createSubviews()
        mainLayoutView.addSubviews(self.previousStepLinkView, self.nextStepLinkView)
        menuItemButton.moveToFront()
    }

    override open func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        [self.previousStepLinkView, self.nextStepLinkView].forEach { view in
            view.height.equal(to: menuItemButton.imageView.height.times(0.25))
            view.centerY.equal(to: menuItemButton.imageView.centerY)
        }
        self.previousStepLinkView.trailing.equal(to: menuItemButton.imageView.centerX)
        self.previousStepLinkView.leading.equalToSuperview()
        self.nextStepLinkView.leading.equal(to: menuItemButton.imageView.centerX)
        self.nextStepLinkView.trailing.equalToSuperview()
    }

    override open func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        menuItemButton.tintsImagesToMatchTextColor = true
    }

    override open func menuItemButtonLayout() -> ButtonLayout {
        let insets = LayoutPadding(horizontal: 0, vertical: 10)
        let imageInsets = LayoutPadding(horizontal: 0, vertical: 5)
        return ButtonLayout(layoutType: .centerTitleUnderImage(padding: 5.0), marginInsets: insets, imageInsets: imageInsets)
    }

    override open func style() {
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
        self.nextStepLinkView.apply(viewStyle: pathStyle)
        self.previousStepLinkView.apply(viewStyle: pathStyle)
        let imageViewStyle = ViewStyle(backgroundColor: .primary, shape: .rounded)
        menuItemButton.imageView.apply(viewStyle: imageViewStyle)
        apply(viewStyle: .clear)
    }
}
