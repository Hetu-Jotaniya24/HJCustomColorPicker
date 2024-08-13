//
//  UIColor+Extension.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 14/08/24.
//

import Foundation
import UIKit

extension UIColor {
    
    func withBrightness(_ value: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var alpha: CGFloat = 0
        let brightness = max(0, min(value, 1))
        getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    var brightness: CGFloat {
        var brightness: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
}
