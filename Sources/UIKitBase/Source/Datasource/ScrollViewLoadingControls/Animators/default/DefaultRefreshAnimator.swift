//
//  DefaultRefreshAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class DefaultRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    open var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    open var circleLayer = CAShapeLayer()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.hidesWhenStopped = true

        self.circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).cgPath
        self.circleLayer.strokeColor = UIColor.gray.cgColor
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.lineWidth = 3
        self.circleLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0)))
        self.circleLayer.strokeStart = 0
        self.circleLayer.strokeEnd = 0

        addSubview(self.activityIndicatorView)
        layer.addSublayer(self.circleLayer)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.activityIndicatorView.frame = bounds
        self.circleLayer.frame = bounds
    }

    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            self.stopAnimating()
        case let .releasing(progress):
            self.updateCircle(progress)
        case .loading:
            self.startAnimating()
        }
    }

    func startAnimating() {
        self.circleLayer.isHidden = true
        self.circleLayer.strokeEnd = 0

        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        self.circleLayer.isHidden = false

        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
    }

    func updateCircle(_ progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.circleLayer.strokeStart = 0
        // 为了让circle增长速度在开始时比较慢，后来加快，这样更好看
        self.circleLayer.strokeEnd = progress * progress
        CATransaction.commit()
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
