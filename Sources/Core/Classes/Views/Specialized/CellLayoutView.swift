//
//  ModularStackViews.swift
//  Pods
//
//  Created by Brian Strobach on 7/28/17.
//
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

public struct CellLayoutViewConfiguration{
    public var showsLeftImageView: Bool
    public var leftImageViewSize: CGSize
    public var innerPadding: CGFloat
    public var marginInsets: LayoutPadding
    public var optionalRightViewMinimumWidth: CGFloat
    public var mainLayoutViewInsets: LayoutPadding
    public init(showsLeftImageView: Bool = true,
                leftImageViewSize: CGSize = CGSize(side: 45.0),
                innerPadding: CGFloat = 10.0,
                marginInsets: LayoutPadding = LayoutPadding(10.0),
                optionalRightViewMinimumWidth: CGFloat = 90.0,
                mainLayoutViewInsets: LayoutPadding = .zero) {
        self.showsLeftImageView = showsLeftImageView
        self.leftImageViewSize = leftImageViewSize
        self.innerPadding = innerPadding
        self.marginInsets = marginInsets
        self.optionalRightViewMinimumWidth = optionalRightViewMinimumWidth
        self.mainLayoutViewInsets = mainLayoutViewInsets
    }
}
open class CellLayoutView<MV: UIView>: BaseView{
    open var mainLayoutView: UIView = UIView()
    
    open lazy var config: CellLayoutViewConfiguration = CellLayoutViewConfiguration()
    
    open lazy var optionalRightView: UIView? = nil
    
    open lazy var leftImageView: BaseImageView = {
        let iv = BaseImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    open lazy var middleView: MV = {
        return self.createMainView()
    }()
    
    open func createMainView() -> MV{
        return MV()
    }    
    
    //MARK: Initialization
    public required init(config: CellLayoutViewConfiguration? = nil, optionalRightView: UIView? = nil) {
        super.init(callDidInit: false)
        self.optionalRightView = optionalRightView
        if let config = config{
            self.config = config
        }
        didInitProgramatically()
    }
    
    public override init(callDidInit: Bool = true){
        super.init(callDidInit: callDidInit)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //Configuration. TODO: Combine this into single config class.

    
    open override func createSubviews() {
        super.createSubviews()
        addSubview(mainLayoutView)
        
        var views: [UIView] = [middleView]
        if config.showsLeftImageView{
            views.prepend(leftImageView)
        }
        
        if let optionalRightView = optionalRightView{
            views.append(optionalRightView)
        }
        mainLayoutView.addSubviews(views)
        
        views.resistCompression()
    }
    
    open override func createAutoLayoutConstraints() {
        super.createAutoLayoutConstraints()
        mainLayoutView.resistCompression()
        mainLayoutView.edges.equal(to: self.edges.inset(config.mainLayoutViewInsets))
        mainLayoutView.height.greaterThanOrEqual(to: 0.0)
        
        var contentHeightBoundaryViews: [UIView] = [middleView]
        if config.showsLeftImageView{
            
            contentHeightBoundaryViews.append(leftImageView)
            leftImageView.leading.equal(to: mainLayoutView.leading.inset(config.marginInsets.leading))
            leftImageView.size.equal(to: config.leftImageViewSize)
            middleView.leading.equal(to: leftImageView.trailing.plus(config.innerPadding))
        }
        else{
            middleView.leading.equal(to: mainLayoutView.leading.inset(config.marginInsets.leading))
        }
        
        if let optionalRightView = optionalRightView{
            optionalRightView.equal(to: mainLayoutView.edges.excluding(.leading).inset(config.marginInsets))
			optionalRightView.resistCompression()
			optionalRightView.width.greaterThanOrEqual(to: config.optionalRightViewMinimumWidth)
			optionalRightView.height.greaterThanOrEqual(to: 0.0)
            middleView.trailing.equal(to: optionalRightView.leading.inset(config.innerPadding))

			middleView.width.greaterThanOrEqual(to: 0.0 ~ .high) // Give right view's width priority over middle stack
			contentHeightBoundaryViews.append(optionalRightView)
        }
        else{
            middleView.trailing.equal(to: .inset(config.marginInsets.trailing))
        }
        
        middleView.height.greaterThanOrEqual(to: 0.0)
        mainLayoutView.autoExpandHeightToFit(views: contentHeightBoundaryViews)
    }
}

open class ModularStackView<StackedView: UIView>: CellLayoutView<GrowingStackView<StackedView>>{
    
    open lazy var stackView: GrowingStackView<StackedView> = {
        return self.middleView
    }()
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        stackView.apply(stackViewConfiguration: .equalSpacingVertical(spacing: 0.0))
    }
    
    
}

open class DualModularStackview<StackedView: UIView, RightStackedView: UIView>: ModularStackView<StackedView>{
    
    open override func didInit() {
        super.didInit()
        optionalRightView = rightStack
    }
    
    open var rightStack: GrowingStackView<RightStackedView> = GrowingStackView<RightStackedView>()
    
    open override func didFinishCreatingAllViews() {
        super.didFinishCreatingAllViews()
        rightStack.apply(stackViewConfiguration: self.rightStackLayoutStyle)
    }
    
    open var rightStackLayoutStyle: StackViewConfiguration{
        return .equalSpacingVertical(spacing: 3.0)
    }
}

open class ModularLabelStackView: ModularStackView<UILabel> {
    
    open var primaryLabel: UILabel { return self.stackView.stackedView(at: 0)}
    open var secondaryLabel: UILabel { return self.stackView.stackedView(at: 1)}
    open var tertiaryLabel: UILabel { return self.stackView.stackedView(at: 2)}
    
    
    open override func style(){
        super.style()
        primaryLabel.apply(textStyle: .medium(color: .textDark, size: 17.0))
		secondaryLabel.apply(textStyle: .regular(color: .textMedium, size: 14.0))
        tertiaryLabel.apply(textStyle: .regular(color: .textMedium, size: 14.0))
    }
}

open class ModularButtonStackView: ModularStackView<UIButton> {
    
    open var primaryButton: UIButton { return self.stackView.stackedView(at: 0)}
    open var secondaryButton: UIButton { return self.stackView.stackedView(at: 0)}
    open var tertiaryButton: UIButton  { return self.stackView.stackedView(at: 0)}
    
    open override func style(){
        super.style()
		primaryButton.apply(textStyle: .medium(color: .textDark, size: 16.0))
		let lighterStyle: TextStyle = .regular(color: .textMedium, size: 13.0)
		secondaryButton.apply(textStyle: lighterStyle)
        tertiaryButton.apply(textStyle: lighterStyle)
    }
}
