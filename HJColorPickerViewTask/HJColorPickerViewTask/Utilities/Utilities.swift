//
//  Utilities.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 13/08/24.
//

import Foundation
import UIKit

class Utilities {
    class func colorFromHexString(_ hex: String) -> UIColor? {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cleanedHex.hasPrefix("#") {
            cleanedHex.remove(at: cleanedHex.startIndex)
        }

        guard cleanedHex.count == 6 || cleanedHex.count == 8 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&rgbValue)

        let r, g, b, a: CGFloat
        if cleanedHex.count == 6 {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
            a = 1.0
        } else { // 8 characters
            r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgbValue & 0x000000FF) / 255.0
        }

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

}
