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
    private let colorPicker = CustomColorPicker()
    private var mover: ColorThumbView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegment()
        setupColorPicker()
        setupColorMover()
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
        
        //TODO: To move thumb
        let color: UIColor
        //TODO: Simplify/minimise this
           if sender == ButtonSegments[0] {
               color = viewSelectedColors[0].backgroundColor ?? .clear
           } else if sender == ButtonSegments[1] {
               color = viewSelectedColors[1].backgroundColor ?? .clear
           } else {
               color = viewSelectedColors[2].backgroundColor ?? .clear
           }

        //TODO: Remove unnecessary
        UIView.animate(withDuration: 0.1, animations: {
            let location = self.colorPicker.colorWheelView.location(of: color)
            self.colorPicker.currentThumb?.color = color
            self.colorPicker.positionThumbView(self.mover, forColorLocation: location)
            self.colorPicker.layoutSubviews()
            self.mover.layoutSubviews()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}


extension ViewController: CustomColorPickerDelegate {
    func colorPickerThumbDidChange(_ colorPicker: CustomColorPicker, thumbView: ColorThumbView, to color: UIColor) {
            //TODO: Simplify/minimise this
        if ButtonSegments[0].isSelected {
            viewSelectedColors[0].backgroundColor = color
        } else if ButtonSegments[1].isSelected {
            viewSelectedColors[1].backgroundColor = color
        } else if ButtonSegments[2].isSelected {
            viewSelectedColors[2].backgroundColor = color
        }
    }
}

private extension ViewController {
    func setupSegment() {
        ButtonSegments.first?.backgroundColor = ThemeColors.segmentSelectedBackgroundColor
        ButtonSegments.first?.isSelected = true
        viewSelectedColors[0].backgroundColor = ThemeColors.colorTeal
        viewSelectedColors[1].backgroundColor = ThemeColors.colorGreen
        viewSelectedColors[2].backgroundColor = ThemeColors.colorOrange
    }

    func setupColorMover() {
        mover = colorPicker.addThumb(at: ThemeColors.colorTeal)
    }

    func setupColorPicker() {
        colorPicker.delegate = self
        colorPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorPicker)
        
        let screenWidth = UIScreen.main.bounds.width
        let dynamicWidth = screenWidth - 32
        let dynamicHeight = dynamicWidth
        let verticalOffset = -dynamicHeight / 6
        
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset),
            colorPicker.widthAnchor.constraint(equalToConstant: dynamicWidth),
            colorPicker.heightAnchor.constraint(equalToConstant: dynamicHeight)
        ])
    }
}
