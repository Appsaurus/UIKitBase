//
//  SnakeRefreshAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class SnakeRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    open var color = UIColor.SnakeBlue {
        didSet {
            self.snakeLayer.strokeColor = self.color.cgColor
        }
    }

    var animating = false

    fileprivate var snakeLayer = CAShapeLayer()
    fileprivate var snakeLengthByCycle: CGFloat = 0 // 显示的长度所占周期数
    fileprivate var cycleCount = 1000

    fileprivate var pathLength: CGFloat = 0

    override public init(frame: CGRect) {
        super.init(frame: frame)

        let ovalDiametor = frame.width / 4
        let lineHeight = frame.height - ovalDiametor

        self.snakeLengthByCycle = 2 - (ovalDiametor / 2 * CGFloat(Double.pi)) / ((lineHeight + ovalDiametor / 2 * CGFloat(Double.pi)) * 2)
        self.pathLength = ovalDiametor * 2 * CGFloat(self.cycleCount)

        let snakePath = UIBezierPath()
        snakePath.move(to: CGPoint(x: 0, y: frame.height - ovalDiametor / 2))
        for index in 0 ... self.cycleCount {
            let cycleStartX = CGFloat(index) * ovalDiametor * 2
            snakePath.addLine(to: CGPoint(x: cycleStartX, y: ovalDiametor / 2))
            snakePath.addArc(withCenter: CGPoint(x: cycleStartX + ovalDiametor / 2, y: ovalDiametor / 2),
                             radius: ovalDiametor / 2,
                             startAngle: CGFloat(Double.pi),
                             endAngle: 0,
                             clockwise: true)
            snakePath.addLine(to: CGPoint(x: cycleStartX + ovalDiametor, y: frame.height - ovalDiametor / 2))
            snakePath.addArc(withCenter: CGPoint(x: cycleStartX + ovalDiametor / 2 * 3, y: frame.height - ovalDiametor / 2),
                             radius: ovalDiametor / 2,
                             startAngle: CGFloat(Double.pi),
                             endAngle: 0,
                             clockwise: false)
        }
        self.snakeLayer.path = snakePath.cgPath
        self.snakeLayer.fillColor = nil
        self.snakeLayer.strokeColor = self.color.cgColor
        self.snakeLayer.strokeStart = 0
        self.snakeLayer.strokeEnd = self.snakeLengthByCycle / CGFloat(self.cycleCount)
        self.snakeLayer.lineWidth = 3
        self.snakeLayer.lineCap = CAShapeLayerLineCap.round

        self.snakeLayer.frame = bounds
        layer.addSublayer(self.snakeLayer)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil, self.animating {
            self.startAnimating()
        }
    }

    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            self.stopAnimating()
        case .loading:
            self.startAnimating()
        case let .releasing(progress):
            self.updateForProgress(progress)
        }
    }

    func updateForProgress(_ progress: CGFloat) {
        self.snakeLayer.isHidden = false

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.snakeLayer.strokeStart = 0
        self.snakeLayer.strokeEnd = self.snakeLengthByCycle / CGFloat(self.cycleCount) * progress
        CATransaction.commit()
    }

    fileprivate let AnimationGroupKey = "SnakePathAnimations"
    func startAnimating() {
        self.animating = true
        self.snakeLayer.isHidden = false

        self.snakeLayer.strokeStart = 0
        self.snakeLayer.strokeEnd = self.snakeLengthByCycle / CGFloat(self.cycleCount)

        let strokeStartAnim = CABasicAnimation(keyPath: "strokeStart")
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        let moveAnim = CABasicAnimation(keyPath: "position")

        strokeStartAnim.toValue = 1 - self.snakeLengthByCycle / CGFloat(self.cycleCount)
        strokeEndAnim.toValue = 1
        moveAnim.toValue = NSValue(cgPoint: CGPoint(x: self.snakeLayer.position.x - self.pathLength, y: self.snakeLayer.position.y))

        let animGroup = CAAnimationGroup()
        animGroup.animations = [strokeStartAnim, strokeEndAnim, moveAnim]
        animGroup.duration = Double(self.cycleCount) * 0.6

        self.snakeLayer.add(animGroup, forKey: self.AnimationGroupKey)
    }

    func stopAnimating() {
        self.animating = false

        self.snakeLayer.isHidden = true
        self.snakeLayer.removeAnimation(forKey: self.AnimationGroupKey)
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
