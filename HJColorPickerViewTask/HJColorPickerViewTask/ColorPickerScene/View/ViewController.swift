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
    @IBOutlet weak var colorPicker: UIImageView!
    private var mover = UIView()
    private var selectedColor: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        ButtonSegments.first?.backgroundColor = ThemeColors.segmentSelectedBackgroundColor
        ButtonSegments.first?.isSelected = true
        viewSelectedColors[0].backgroundColor = ThemeColors.colorTeal
        viewSelectedColors[1].backgroundColor = ThemeColors.colorGreen
        viewSelectedColors[2].backgroundColor = ThemeColors.colorOrange
        setupUI()
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

private extension ViewController {
    func setupUI() {
        
        let wheelSize = view.frame.width - 40
        colorPicker.frame = CGRect(x: 20, y: 160, width: wheelSize, height: wheelSize)
        colorPicker.image = generateColorWheel(size: colorPicker.frame.size)
        
        colorPicker.layer.cornerRadius = wheelSize / 2
        //        imageColorWheel.clipsToBounds = true
        
        colorPicker.isUserInteractionEnabled = true
        view.addSubview(colorPicker)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        colorPicker.addGestureRecognizer(panGesture)
        mover.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        mover.layer.cornerRadius = 17.5
        mover.layer.borderWidth = 2
        mover.layer.borderColor = UIColor.white.cgColor
        mover.applyDropShadow(color: UIColor.black, opacity:  0.6, offset: CGSize(width: 3, height: 3), radius: 10)
        colorPicker.addSubview(mover)
    }

    //FIXME: thumb is showing delayed color maybe - should show current location color
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: colorPicker)
        let center = CGPoint(x: colorPicker.bounds.width / 2, y: colorPicker.bounds.height / 2)
        let radius = colorPicker.bounds.width / 2

        let dx = location.x - center.x
        let dy = location.y - center.y
        let distanceFromCenter = sqrt(dx * dx + dy * dy)

        if distanceFromCenter <= radius {
            mover.center = location
        } else {
            let angle = atan2(dy, dx)
            let limitedX = center.x + radius * cos(angle)
            let limitedY = center.y + radius * sin(angle)
            mover.center = CGPoint(x: limitedX, y: limitedY)
        }

        if let color = colorPicker.color(at: mover.center) {
            selectedColor = color
            mover.backgroundColor = color
            updateSegmentedControlColor(color)
        }
    }

    func updateSegmentedControlColor(_ color: UIColor) {
        if ButtonSegments[0].isSelected {
            viewSelectedColors[0].backgroundColor = color
        } else if ButtonSegments[1].isSelected {
            viewSelectedColors[1].backgroundColor = color
        } else if ButtonSegments[2].isSelected {
            viewSelectedColors[2].backgroundColor = color
        }
    }

    func generateColorWheel(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            for y in 0..<Int(size.height) {
                for x in 0..<Int(size.width) {
                    let color = getColorAtPoint(CGPoint(x: x, y: y), size: size)
                    ctx.cgContext.setFillColor(color.cgColor)
                    ctx.cgContext.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }
    
    func getColorAtPoint(_ point: CGPoint, size: CGSize) -> UIColor {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angle = atan2(dy, dx) + .pi
        let distance = hypot(dx, dy) / (size.width / 2)
        
        let hue = angle / (2 * .pi)
        let saturation = min(1, distance)
        return UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
    }

    func moveHandleToColor(_ color: UIColor) {
        let size = colorPicker.frame.size
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 2
        
       
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let angle = hue * 2 * .pi
        let distance = saturation * radius
        
        let x = center.x + distance * cos(angle)
        let y = center.y + distance * sin(angle)
        
        mover.center = CGPoint(x: x, y: y)
    }
}

extension UIImageView {
    func color(at point: CGPoint) -> UIColor? {
        guard let cgImage = self.image?.cgImage, let provider = cgImage.dataProvider else { return nil }
        let data = provider.data
        let bytes = CFDataGetBytePtr(data)
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        let x = Int(point.x)
        let y = Int(point.y)
        let offset = ((Int(cgImage.width) * y) + x) * bytesPerPixel
        let components = (r: bytes![offset], g: bytes![offset + 1], b: bytes![offset + 2], a: bytes![offset + 3])
        return UIColor(red: CGFloat(components.r) / 255, green: CGFloat(components.g) / 255, blue: CGFloat(components.b) / 255, alpha: CGFloat(components.a) / 255)
    }
}
