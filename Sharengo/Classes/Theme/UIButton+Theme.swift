//
//  UIButton+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 27/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

public enum ButtonStyle {
    case roundedButton
}

public extension UIButton {
    func style(_ style:ButtonStyle, title: String) {
        switch style {
        case .roundedButton:
            self.backgroundColor = .clear
            self.setBackgroundImage(UIImage.imageWithSolidColor(ZAlertView.positiveColor, size: self.frame.size), for: .normal)
            self.layer.cornerRadius = ZAlertView.cornerRadius
            self.clipsToBounds = true
            self.setTitle(title, for: UIControlState())
            self.titleLabel?.font = ZAlertView.buttonFont ?? UIFont.boldSystemFont(ofSize: 14)
            self.setTitleColor(ZAlertView.buttonTitleColor, for: .normal)
            // TODO: ???
            self.setBackgroundImage(UIImage.imageWithSolidColor(ZAlertView.positiveColor, size: self.frame.size), for: .highlighted)
            self.setTitleColor(ZAlertView.buttonTitleColor, for: .highlighted)
        }
    }
}

