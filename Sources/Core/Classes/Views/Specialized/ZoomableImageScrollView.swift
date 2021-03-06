//
//  ZoomableImageScrollView.swift
//  Pods
//
//  Created by Brian Strobach on 8/10/16.
//
//

import UIKit

protocol ZoomableImageScrollViewDelegate: AnyObject {
    func imageScrollView(_ imageScrollView: ZoomableImageScrollView, didReframeImage image: UIImage)
}

open class ZoomableImageScrollView: UIScrollView, UIScrollViewDelegate {
    var boundingView: UIView!
    var originalImageViewSize: CGSize!

    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        return imageView

    }()

    weak var imageScrollViewDelegate: ZoomableImageScrollViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    fileprivate func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        self.boundingView = self

        bouncesZoom = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ZoomableImageScrollView.doubleTapGestureRecognizer(_:)))
        tapGesture.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(tapGesture)

        minimumZoomScale = 1.0
        maximumZoomScale = 5.0
        self.imageView.frame = self.boundingView.bounds
        addSubview(self.imageView)
        contentSize = self.imageView.frame.size
        self.originalImageViewSize = self.imageView.frame.size
        self.recalculateMinMaxZoomScalesForCurrentBounds()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.recalculateMinMaxZoomScalesForCurrentBounds()
    }

    // MARK: - UIScrollViewDelegate

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    // MARK: - Display image

    open func displayImage(_ image: UIImage) {
        contentOffset = CGPoint.zero
        self.imageView.image = image
        self.resetZoom()
    }

    open func resetZoom() {
        zoomScale = self.calculateZoomScaleToAspectFitImageViewToBoundingView()
    }

    open func recalculateMinMaxZoomScalesForCurrentBounds() {
        let zoomRange = maximumZoomScale - minimumZoomScale
        minimumZoomScale = self.calculateZoomScaleToAspectFitImageViewToBoundingView()
        maximumZoomScale = minimumZoomScale + zoomRange
    }

    fileprivate func calculateZoomScaleToAspectFitImageViewToBoundingView() -> CGFloat {
        // calculate min/max zoomscale
        let boundingSize = self.boundingView.bounds.size
        let xScale = boundingSize.width / self.originalImageViewSize.width
        let yScale = boundingSize.height / self.originalImageViewSize.height
        let minScale = min(xScale, yScale) // Forces image to span at least one length fo the boundingView
        return minScale
    }

    // MARK: - Gesture

    @objc fileprivate func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than middle scale point. Else, zoom in
        let scaleStep = (maximumZoomScale - minimumZoomScale) / 2.0
        var nextStep = zoomScale + scaleStep
        if nextStep > maximumZoomScale {
            nextStep = minimumZoomScale
        }
        let zoomRect = self.zoomRectForScale(nextStep, center: gestureRecognizer.location(ofTouch: 0, in: self.imageView))
        zoom(to: zoomRect, animated: true)
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.imageWasReframed()
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.imageWasReframed()
    }

    open func imageWasReframed() {
        if let image = imageView.image {
            self.imageScrollViewDelegate?.imageScrollView(self, didReframeImage: image)
        }
    }

    open func getCurrentCropRectForImage() -> CGRect {
        let scale = 1 / zoomScale
        let boundingView = self.boundingView ?? self
        let visibleRect = CGRect(x: (contentOffset.x + contentInset.left) * scale,
                                 y: (contentOffset.y + contentInset.top) * scale,
                                 width: boundingView.bounds.size.width * scale,
                                 height: boundingView.bounds.size.height * scale)
        return visibleRect
    }

    fileprivate func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero

        // the zoom rect is in the content view's coordinates.
        // at a zoom scale of 1.0, it would be the size of the ZoomableImageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width = frame.size.width / scale

        // choose an origin so as to get the right center.
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    open func refresh() {
        if let image = imageView.image {
            self.displayImage(image)
        }
    }
}
