//
//  ColorThumbView.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 14/08/24.
//

import Foundation
import UIKit

class ColorThumbView: UIView {

    private let thumbShape = CAShapeLayer()

    var color: UIColor = .black {
        didSet { layoutNow() }
    }
    
    var accessoryImage: UIImage? {
        didSet {
            let imageView = UIImageView(image: accessoryImage)
            imageView.contentMode = .scaleAspectFit
            accessoryView = imageView
        }
    }
    
    var accessoryView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let accessoryView = accessoryView {
                addAccessoryView(accessoryView)
            }
        }
    }
    
    var accessoryViewEdgeInsets: UIEdgeInsets = .zero
    var borderWidth: CGFloat = 2.0
    var borderColor: UIColor = .white
    
    // MARK: - Initialization
    convenience init(color: UIColor) {
        self.init(frame: .zero)
        self.color = color
        commonInit()
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
        layoutThumbShape()
        layoutAccessoryViewIfNeeded()
        applyDropShadow(color: UIColor.black,
                        opacity: 0.5,
                        offset: CGSize(width: 2, height: 4),
                        radius: 10.0)
        layer.masksToBounds = false
    }
    
    
    func commonInit() {
        layer.addSublayer(thumbShape)
    }
    
    func makeThumbPath(frame: CGRect) -> CGPath {
        let buttonRadius: CGFloat = 15
        let buttonPath = UIBezierPath(arcCenter: CGPoint(x: buttonRadius, y: buttonRadius), radius: buttonRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        return buttonPath.cgPath
    }
    
    func layoutThumbShape() {
        let size = CGSize(width: bounds.width - borderWidth, height: bounds.height - borderWidth)
        thumbShape.path = makeThumbPath(frame: CGRect(origin: .zero, size: size))
        thumbShape.frame = CGRect(origin: CGPoint(x: bounds.midX - (size.width / 2), y: bounds.midY - (size.height / 2)), size: size)
        thumbShape.fillColor = color.cgColor
        thumbShape.strokeColor = borderColor.cgColor
        thumbShape.lineWidth = borderWidth
    }
    
    func layoutAccessoryViewIfNeeded() {
        if let accessoryLayer = accessoryView?.layer {
            let width = bounds.width - borderWidth * 2
            let size = CGSize(width: width - (accessoryViewEdgeInsets.left + accessoryViewEdgeInsets.right),
                              height: width - (accessoryViewEdgeInsets.top + accessoryViewEdgeInsets.bottom))
            accessoryLayer.frame = CGRect(origin: CGPoint(x: (borderWidth) + accessoryViewEdgeInsets.left, y: (borderWidth) + accessoryViewEdgeInsets.top), size: size)
            accessoryLayer.cornerRadius = size.height / 2
            accessoryLayer.masksToBounds = true
        }
    }
    
    func addAccessoryView(_ view: UIView) {
        let accessoryLayer = view.layer
        thumbShape.addSublayer(accessoryLayer)
    }
}
