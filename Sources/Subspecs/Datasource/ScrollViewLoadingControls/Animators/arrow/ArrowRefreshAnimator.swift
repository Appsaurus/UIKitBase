//
//  ArrowRefreshAnimator.swift
//  AppsaurusUIKit
//
//  Created by Brian Stroach on 9/1/2017
//  Copyright © 2017 Appsaurus LLC. All rights reserved.
//

import UIKit

extension UIColor {
    static var ArrowBlue: UIColor {
        return UIColor(red: 76 / 255.0, green: 143 / 255.0, blue: 1.0, alpha: 1.0)
    }

    static var ArrowLightGray: UIColor {
        return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }
}

open class ArrowRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    fileprivate(set) var animating = false
    open var color: UIColor = UIColor.ArrowBlue {
        didSet {
            self.arrowLayer.strokeColor = self.color.cgColor
            self.circleFrontLayer.strokeColor = self.color.cgColor
            self.activityIndicatorView.color = self.color
        }
    }

    fileprivate var arrowLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var circleFrontLayer: CAShapeLayer = CAShapeLayer()
    fileprivate var circleBackLayer: CAShapeLayer = CAShapeLayer()

    fileprivate var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.circleBackLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).cgPath
        self.circleBackLayer.fillColor = nil
        self.circleBackLayer.strokeColor = UIColor.ArrowLightGray.cgColor
        self.circleBackLayer.lineWidth = 3

        self.circleFrontLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).cgPath
        self.circleFrontLayer.fillColor = nil
        self.circleFrontLayer.strokeColor = self.color.cgColor
        self.circleFrontLayer.lineWidth = 3
        self.circleFrontLayer.lineCap = CAShapeLayerLineCap.round
        self.circleFrontLayer.strokeStart = 0
        self.circleFrontLayer.strokeEnd = 0
        self.circleFrontLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0)))

        let arrowWidth = min(frame.width, frame.height) / 2
        let arrowHeight = arrowWidth * 0.5

        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: arrowHeight))
        arrowPath.addLine(to: CGPoint(x: arrowWidth / 2, y: 0))
        arrowPath.addLine(to: CGPoint(x: arrowWidth, y: arrowHeight))

        self.arrowLayer.path = arrowPath.cgPath
        self.arrowLayer.fillColor = nil
        self.arrowLayer.strokeColor = self.color.cgColor
        self.arrowLayer.lineWidth = 3
        self.arrowLayer.lineJoin = CAShapeLayerLineJoin.round
        self.arrowLayer.lineCap = CAShapeLayerLineCap.butt

        self.circleBackLayer.frame = bounds
        self.circleFrontLayer.frame = bounds
        self.arrowLayer.frame = CGRect(x: (frame.width - arrowWidth) / 2, y: (frame.height - arrowHeight) / 2, width: arrowWidth, height: arrowHeight)

        self.activityIndicatorView.frame = bounds
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.color = UIColor.ArrowBlue

        layer.addSublayer(self.circleBackLayer)
        layer.addSublayer(self.circleFrontLayer)
        layer.addSublayer(self.arrowLayer)
        addSubview(self.activityIndicatorView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func animateState(_ state: PullToRefreshState) {
        switch state {
        case .none:
            self.stopAnimating()
        case let .releasing(progress):
            self.updateForProgress(progress)
        case .loading:
            self.startAnimating()
        }
    }

    func updateForProgress(_ progress: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.circleFrontLayer.strokeEnd = progress * progress
        self.arrowLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2) * progress * progress))
        CATransaction.commit()
    }

    func startAnimating() {
        self.animating = true
        self.circleFrontLayer.strokeEnd = 0
        self.arrowLayer.transform = CATransform3DIdentity

        self.circleBackLayer.isHidden = true
        self.circleFrontLayer.isHidden = true
        self.arrowLayer.isHidden = true

        self.activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        self.animating = false

        self.circleBackLayer.isHidden = false
        self.circleFrontLayer.isHidden = false
        self.arrowLayer.isHidden = false

        self.activityIndicatorView.stopAnimating()
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
         // Drawing code
     }
     */
}
