//
//  ColorWheelView.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 14/08/24.
//

import Foundation
import UIKit

class ColorWheelView: UIView {
    private let defaultImageViewRoundedInset: CGFloat = 1.0
    private let imageView = UIImageView()
    private let imageViewMask = UIView()
    var radius: CGFloat {
        return max(bounds.width, bounds.height) / 2.0
    }
    
    var middlePoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

     override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
     override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
        layer.cornerRadius = radius
        
        let screenScale: CGFloat = UIScreen.main.scale
        if let colorWheelImage: CIImage = makeColorWheelImage(radius: radius * screenScale) {
            imageView.image = UIImage(ciImage: colorWheelImage, scale: screenScale, orientation: .up)
        }

        imageViewMask.frame = imageView.bounds.insetBy(dx: defaultImageViewRoundedInset, dy: defaultImageViewRoundedInset)
        imageViewMask.layer.cornerRadius = imageViewMask.bounds.width / 2.0
        imageView.mask = imageViewMask
    }

     func location(of color: UIColor) -> CGPoint {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        let radianAngle = hue * (2 * .pi)
        let distance = saturation * radius
        let colorTranslation = CGPoint(x: distance * cos(radianAngle), y: -distance * sin(radianAngle))
        let colorPoint = CGPoint(x: bounds.midX + colorTranslation.x, y: bounds.midY + colorTranslation.y)
        
        return colorPoint
    }

    func pixelColor(at point: CGPoint) -> UIColor? {
        guard pointIsInColorWheel(point) else { return nil }
        guard !pointIsOnColorWheelEdge(point) else {
            let angleToCenter = atan2(point.x - middlePoint.x, point.y - middlePoint.y)
            return edgeColor(for: angleToCenter)
        }
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(
            data: pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.translateBy(x: -point.x, y: -point.y)
        imageView.layer.render(in: context)
        let color = UIColor(
            red: CGFloat(pixel[0]) / 255.0,
            green: CGFloat(pixel[1]) / 255.0,
            blue: CGFloat(pixel[2]) / 255.0,
            alpha: 1.0
        )
        
        pixel.deallocate()
        return color
    }

    func pointIsInColorWheel(_ point: CGPoint) -> Bool {
        let distanceFromCenter: CGFloat = hypot(middlePoint.x - point.x, middlePoint.y - point.y)
        let pointExistsInRadius: Bool = distanceFromCenter <= (radius - layer.borderWidth)
        return pointExistsInRadius
    }
    
    func pointIsOnColorWheelEdge(_ point: CGPoint) -> Bool {
        let distanceToCenter = hypot(middlePoint.x - point.x, middlePoint.y - point.y)
        let isPointOnEdge = distanceToCenter >= radius - 1.0
        return isPointOnEdge
    }
    
    func commonInit() {
        backgroundColor = .clear
        setupImageView()
    }
    
    func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageViewMask.backgroundColor = .black
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor, constant: defaultImageViewRoundedInset * 2),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, constant: defaultImageViewRoundedInset * 2),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func makeColorWheelImage(radius: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIHueSaturationValueGradient", parameters: [
            "inputColorSpace": CGColorSpaceCreateDeviceRGB(),
            "inputDither": 0,
            "inputRadius": radius,
            "inputSoftness": 0,
            "inputValue": 1
        ])
        return filter?.outputImage
    }

    func edgeColor(for angle: CGFloat) -> UIColor {
        var normalizedAngle = angle + .pi
        normalizedAngle += (.pi / 2)
        var hue = normalizedAngle / (2 * .pi)
        if hue > 1 { hue -= 1 }
        return UIColor(hue: hue, saturation: 1, brightness: 1.0, alpha: 1.0)
    }
}

