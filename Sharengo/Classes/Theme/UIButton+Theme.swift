//
//  UIButton+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 27/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

/**
 Enum of button's styles used in app
*/
public enum ButtonStyle {
    case clearButton(UIFont, UIColor)
    case roundedButton(UIColor)
    case squaredButton(UIColor)
    case headerButton(UIFont, UIColor, UIColor)
}

/**
 UIButton Extension with useful methods
*/
public extension UIButton {
    /**
     This method set button properties associated with a style and set button's title.
     - Parameter style: style of button
     - Parameter title: title of button
     */
    public func style(_ style:ButtonStyle, title: String) {
        switch style {
        case .clearButton(let font, let color):
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(UIColor.clear, size: self.frame.size), for: .normal)
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = font
            self.setTitleColor(color, for: .normal)
        case .roundedButton(let backgroundColor):
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(backgroundColor, size: self.frame.size), for: .normal)
            self.layer.cornerRadius = 4
            self.clipsToBounds = true
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = Font.roundedButton.value
            self.setTitleColor(Color.alertButton.value, for: .normal)
        case .squaredButton(let backgroundColor):
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(backgroundColor, size: self.frame.size), for: .normal)
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = Font.roundedButton.value
            self.setTitleColor(Color.alertLightButton.value, for: .normal)
        case .headerButton(let font, let backgroundColor, let textColor):
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(backgroundColor, size: self.frame.size), for: .normal)
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = font
            self.setTitleColor(textColor, for: .normal)
        }
    }
}

