//
//  Font+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 21/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import DeviceKit

enum FontWeight {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    public func font(withSize size:CGFloat) -> UIFont {
        switch self {
        case .light:
            return UIFont(name: "Poppins-Light", size: size)!
        case .regular:
            return UIFont(name: "Poppins-Regular", size: size)!
        case .medium:
            return UIFont(name: "Poppins-Medium", size: size)!
        case .semibold:
            return UIFont(name: "Poppins-SemiBold", size: size)!
        case .bold:
            return UIFont(name: "Poppins", size: size)!
        }
    }
}

enum Font {
    // Alert
    case alertMessage
    case alertButtons
    
    // SearchBar
    case searchBarTextField
    case searchBarTextFieldPlaceholder
    
    // CarPopup
    case carPopupType
    case carPopup
    case carPopupEmphasized
    
    var value: UIFont {
        get {
            switch self {
            // Alert
            case .alertMessage:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 14))
            case .alertButtons:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // SearchBar
            case .searchBarTextField:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 14))
            case .searchBarTextFieldPlaceholder:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 14))
            // CarPopup
            case .carPopupType:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 14))
            case .carPopup:
                return FontWeight.medium.font(withSize: self.getFontSize(size: 12))
            case .carPopupEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            }
        }
    }
    
    func getFontSize(size: CGFloat) -> CGFloat {
        let device = Device()
        switch device.diagonal {
        case 3.5:
            return size * 0.9
        case 4:
            return size
        case 4.7:
            return size * 1.1
        case 5.5:
            return size * 1.2
        default:
            return size
        }
    }
}
