//
//  DrawingUtils.swift
//  Pods
//
//  Created by Brian Strobach on 3/17/17.
//
//

import Swiftest
import UIKitTheme

open class DrawingUtils {

    public static func draw(polygon: [CGPoint], style: ViewStyle, innerBorder: Bool = true) {
			draw(polygon: polygon,
						  fill: style.backgroundColor,
						  borderColor: style.borderStyle?.borderColor,
						  borderWidth: style.borderStyle?.borderWidth)
	}
    public static func draw(polygon: [CGPoint], fill: UIColor? = nil, borderColor: UIColor? = nil, borderWidth: CGFloat? = nil, innerBorder: Bool = true) {
        var points = polygon
        let firstPoint = points.removeFirst()
        
        let path = UIBezierPath()
        path.move(to: firstPoint)
        for point in points {
            path.addLine(to: point)
        }
        path.addLine(to: firstPoint)
		if let borderWidth = borderWidth { path.lineWidth = borderWidth }
		if let borderColor = borderColor {
			if innerBorder {
				path.addClip()
			}
			borderColor.setStroke()
			path.stroke()
		}
		if let fill = fill {
			fill.setFill()
			path.fill()
		}

    }
    
    public static func drawSplitBackgroundSpanning(view: UIView, startY: CGFloat? = nil, incline: CGFloat, filledWith color: UIColor) {
        let rect = view.bounds
        let startY = startY ?? rect.minY
        let poly = [
            CGPoint(x: rect.minX, y: startY),
            CGPoint(x: rect.maxX, y: startY - incline),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY)
        ]
        draw(polygon: poly, fill: color)
    }

    public static func drawDottedUnderline(strokeColor: UIColor? = nil,
                                           fillColor: UIColor? = nil,
                                           lineWidth: CGFloat = 2,
                                           in view: UIView) {
		let strokeColor = strokeColor ?? .black
		let fillColor = fillColor ?? view.backgroundColor ?? .white
		let path = UIBezierPath()

		var start = view.frame.bottomLeft
		start.x += lineWidth / 2.0

		var end = view.frame.bottomRight
		end.x -= lineWidth / 2.0

		path.move(to: start)
		path.addLine(to: end)
		path.lineWidth = lineWidth

		let dashes: [CGFloat] = [0.001, path.lineWidth * 2]
		path.setLineDash(dashes, count: dashes.count, phase: 0)
		path.lineCapStyle = CGLineCap.round

//		UIGraphicsBeginImageContextWithOptions(CGSize(width:300, height:20), false, 2)

		fillColor.setFill()
		UIGraphicsGetCurrentContext()!.fill(.infinite)

		strokeColor.setStroke()
		path.stroke()

//		let image = UIGraphicsGetImageFromCurrentImageContext()
//		let view = UIImageView(image: image)
	}
}
