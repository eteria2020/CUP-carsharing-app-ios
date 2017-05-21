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
    case clear

    var value: UIColor {
        get {
            switch self {
            case .yellow:
                return UIColor.yellow
            case .green:
                return UIColor.green
            case .black:
                return UIColor.black
            case .white:
                return UIColor.white
            case .clear:
                return UIColor.clear
            }
        }
    }
}

enum Color {
    // NavigationBar
    case navigationBarBackground
    
    // CircularMenu
    case circularMenuBackgroundBorder
    case circularMenuBackground
    
    // SearchBar
    case searchBarBackground
    case searchBarBackgroundMicrophone
    case searchBarTextField
    case searchBarTextFieldPlaceholder
    
    var value: UIColor {
        get {
            switch self {
            case .navigationBarBackground:
                return ColorBrand.yellow.value
            case .circularMenuBackgroundBorder:
                return ColorBrand.yellow.value.withAlphaComponent(0.5)
            case .circularMenuBackground:
                return ColorBrand.clear.value
            case .searchBarBackground:
                return ColorBrand.black.value
            case .searchBarBackgroundMicrophone:
                return ColorBrand.white.value
            case .searchBarTextField:
                return ColorBrand.white.value
            case .searchBarTextFieldPlaceholder:
                return ColorBrand.white.value.withAlphaComponent(0.6)
            }
        }
    }
}
