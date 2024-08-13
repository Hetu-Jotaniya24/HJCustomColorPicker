//
//  UIView+Extension.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 13/08/24.
//

import Foundation
import UIKit

extension UIView {
    func applyDropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

