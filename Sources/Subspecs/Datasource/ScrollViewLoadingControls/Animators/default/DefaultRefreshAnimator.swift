//
//  DefaultRefreshAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

open class DefaultRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    open var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    open var circleLayer: CAShapeLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicatorView.isHidden = true
        activityIndicatorView.hidesWhenStopped = true

        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).cgPath
        circleLayer.strokeColor = UIColor.gray.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 3
        circleLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0)))
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0

        addSubview(activityIndicatorView)
        layer.addSublayer(circleLayer)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        activityIndicatorView.frame = bounds
        circleLayer.frame = bounds
    }

    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            stopAnimating()
        case let .releasing(progress):
            updateCircle(progress)
        case .loading:
            startAnimating()
        }
    }

    func startAnimating() {
        circleLayer.isHidden = true
        circleLayer.strokeEnd = 0

        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        circleLayer.isHidden = false

        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }

    func updateCircle(_ progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        circleLayer.strokeStart = 0
        // 为了让circle增长速度在开始时比较慢，后来加快，这样更好看
        circleLayer.strokeEnd = progress * progress
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
