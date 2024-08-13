//
//  CustomColorPicker.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 14/08/24.
//

import Foundation
import UIKit

protocol CustomColorPickerDelegate: AnyObject {
    func colorPickerThumbDidChange(_ colorPicker: CustomColorPicker, thumbView: ColorThumbView, to color: UIColor)
}

class CustomColorPicker: UIControl {
    
    weak var delegate: CustomColorPickerDelegate?
    var borderWidth: CGFloat = 2
    var borderColor: UIColor = .white
    var thumbSize: CGSize = CGSize(width: 35, height: 35)
    var handleHitboxExtensionY: CGFloat = 10.0
    private(set) var colorThumbs: [ColorThumbView] = []
    private(set) var currentThumb: ColorThumbView?
    let colorWheelView = ColorWheelView()
    var colorWheelViewWidthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorThumbs.forEach { thumb in
            let location = colorWheelView.location(of: thumb.color)
            thumb.frame.size = thumbSize
            positionThumbView(thumb, forColorLocation: location)
        }
    }
    
    func addThumb(at color: UIColor? = nil) -> ColorThumbView {
        let thumbView = ColorThumbView()
        thumbView.color = color ?? .white
        addThumb(thumbView)
        return thumbView
    }
    
    func addThumb(_ thumbView: ColorThumbView) {
        colorThumbs.append(thumbView)
        colorWheelView.addSubview(thumbView)
        if currentThumb == nil {
            currentThumb = thumbView
        }
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: colorWheelView)
        
        for thumb in colorThumbs {
            if extendedHitFrame(for: thumb).contains(location) {
                colorWheelView.bringSubviewToFront(thumb)
                currentThumb = thumb
                return true
            }
        }
        return false
    }
    
     override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        var location = touch.location(in: colorWheelView)
        guard let cThumb = currentThumb else { return false }
        
        if !colorWheelView.pointIsInColorWheel(location) {
            let center = colorWheelView.middlePoint
            let radius = colorWheelView.radius
            let angleToCenter = atan2(location.x - center.x, location.y - center.y)
            let positionOnColorWheelEdge = CGPoint(x: center.x + radius * sin(angleToCenter),
                                                   y: center.y + radius * cos(angleToCenter))
            location = positionOnColorWheelEdge
        }
        
        if let pixelColor = colorWheelView.pixelColor(at: location) {
            let previousBrightness = cThumb.color.brightness
            cThumb.color = pixelColor.withBrightness(previousBrightness)
            positionThumbView(cThumb, forColorLocation: location)
            delegate?.colorPickerThumbDidChange(self, thumbView: cThumb, to: cThumb.color)
            sendActions(for: .valueChanged)
        }
        
        return true
    }
    
     override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        sendActions(for: .touchUpInside)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchableBounds = bounds.insetBy(dx: -thumbSize.width, dy: -thumbSize.height)
        return touchableBounds.contains(point) ? self : super.hitTest(point, with: event)
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        setupColorWheelView()
    }
    
    func setupColorWheelView() {
        colorWheelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorWheelView)
        colorWheelViewWidthConstraint = colorWheelView.widthAnchor.constraint(equalTo: self.widthAnchor)
        
        NSLayoutConstraint.activate([
            colorWheelView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            colorWheelView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            colorWheelViewWidthConstraint,
            colorWheelView.heightAnchor.constraint(equalTo: colorWheelView.widthAnchor),
        ])
    }

    // MARK: - Helpers
    func extendedHitFrame(for thumbView: ColorThumbView) -> CGRect {
        var frame = thumbView.frame
        frame.size.height += handleHitboxExtensionY
        return frame
    }
    
    func positionThumbView(_ thumb: ColorThumbView, forColorLocation location: CGPoint) {
        thumb.center = location.applying(CGAffineTransform.identity.translatedBy(x: 0, y: -thumb.bounds.height * 0.09))
    }
}
