//
//  Color+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

enum ColorBrand {
    case yellow
    case green
    case black
    case white
    case gray
    case clear

    var value: UIColor {
        get {
            switch self {
            case .yellow:
                return UIColor(red: 255/255.0, green: 233/255.0, blue: 0/255.0, alpha: 1.0)
            case .green:
                return UIColor(red: 68/255.0, green: 173/255.0, blue: 79/255.0, alpha: 1.0)
            case .black:
                return UIColor(red: 27/255.0, green: 35/255.0, blue: 41/255.0, alpha: 1.0)
            case .white:
                return UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
            case .gray:
                return UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
            case .clear:
                return UIColor.clear
            }
        }
    }
}

enum Color {
    // Alert
    case alertBackground
    case alerButtonsBackground
    case alertMessage
    case alertButton
    
    // NavigationBar
    case navigationBarBackground
    
    // CircularMenu
    case circularMenuBackgroundBorder
    case circularMenuBackground
    
    // Home
    case homeSearchCarBackground
    
    // SearchBar
    case searchBarBackground
    case searchBarBackgroundMicrophone
    case searchBarBackgroundMicrophoneSpeechInProgress
    case searchBarTextField
    case searchBarTextFieldPlaceholder
    case searchBarResult
    case searchBarResultBackground
    
    // CarPopup
    case carPopupBackground
    case carPopupType
    case carPopupLabel
    case carPopupAddressPlaceholder
    
    var value: UIColor {
        get {
            switch self {
            // Alert
            case .alertBackground:
                return ColorBrand.black.value
            case .alerButtonsBackground:
                return ColorBrand.yellow.value
            case .alertMessage:
                return ColorBrand.white.value
            case .alertButton:
                return ColorBrand.black.value
            // NavigationBar
            case .navigationBarBackground:
                return ColorBrand.yellow.value
            // CircularMenu
            case .circularMenuBackgroundBorder:
                return ColorBrand.yellow.value.withAlphaComponent(0.5)
            case .circularMenuBackground:
                return ColorBrand.clear.value
            // Home
            case .homeSearchCarBackground:
                return ColorBrand.green.value
            // SearchBar
            case .searchBarBackground:
                return ColorBrand.black.value
            case .searchBarBackgroundMicrophone:
                return ColorBrand.white.value
            case .searchBarBackgroundMicrophoneSpeechInProgress:
                return ColorBrand.yellow.value
            case .searchBarTextField:
                return ColorBrand.white.value
            case .searchBarTextFieldPlaceholder:
                return ColorBrand.white.value.withAlphaComponent(0.6)
            case .searchBarResult:
                return ColorBrand.white.value
            case .searchBarResultBackground:
                return UIColor(hexString: "#1C2329").withAlphaComponent(0.95)
            // CarPopup
            case .carPopupBackground:
                return ColorBrand.gray.value
            case .carPopupType:
                return ColorBrand.black.value
            case .carPopupLabel:
                return ColorBrand.black.value
            case .carPopupAddressPlaceholder:
                return ColorBrand.black.value.withAlphaComponent(0.7)
            }
        }
    }
}
