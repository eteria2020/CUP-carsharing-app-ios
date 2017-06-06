//
//  UIButton+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 27/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

public enum ButtonStyle {
    case roundedButton(UIColor)
}

public extension UIButton {
    func style(_ style:ButtonStyle, title: String) {
        switch style {
        case .roundedButton(let backgroundColor):
            // TODO: sostituire le variabili relative a ZAlertView
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(backgroundColor, size: self.frame.size), for: .normal)
            self.layer.cornerRadius = ZAlertView.cornerRadius
            self.clipsToBounds = true
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = Font.roundedButton.value
            self.setTitleColor(ZAlertView.buttonTitleColor, for: .normal)
        }
    }
}

