//
//  ViewController.swift
//  HJColorPickerViewTask
//
//  Created by Hetu Jotaniya on 13/08/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var ButtonSegments: [UIButton]! {
        didSet {
            ButtonSegments.forEach { $0.backgroundColor = ThemeColors.segmentBackgroundColor}
        }
    }

    @IBOutlet var viewSelectedColors: [UIView]! {
        didSet {
            viewSelectedColors.forEach { $0.layer.cornerRadius = (viewSelectedColors.first?.frame.height ?? 35) / 2 }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ButtonSegments.first?.backgroundColor = ThemeColors.segmentSelectedBackgroundColor
        ButtonSegments.first?.isSelected = true
        viewSelectedColors[0].backgroundColor = ThemeColors.colorTeal
        viewSelectedColors[1].backgroundColor = ThemeColors.colorGreen
        viewSelectedColors[2].backgroundColor = ThemeColors.colorOrange
    }

    @IBAction func segmentTapped(_ sender: UIButton) {
        ButtonSegments.forEach{ $0.isSelected = false}
        sender.isSelected = !sender.isSelected
        let _ = ButtonSegments.first {
            if $0.isSelected {
                $0.backgroundColor = ThemeColors.segmentSelectedBackgroundColor
            } else {
                $0.backgroundColor = ThemeColors.segmentBackgroundColor
            }
            return false
        }
        //TODO: move thumb to respective color
    }

}

enum ThemeColors {
    static let colorTeal = Utilities.colorFromHexString("#00c2a3")
    static let colorGreen = Utilities.colorFromHexString("#4ba54f")
    static let colorOrange = Utilities.colorFromHexString("#ff6100")
    static let segmentBackgroundColor = Utilities.colorFromHexString("#2c2c2c")
    static let segmentSelectedBackgroundColor = Utilities.colorFromHexString("#3b3b3b")
}
