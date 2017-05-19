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

enum Color
{
    // CircularMenu
    case circularMenuBorder
    case circularMenuMain

    var value: UIColor {
        get {
            switch self {
            case .circularMenuBorder:
                return ColorBrand.yellow.value
            case .circularMenuMain:
                return ColorBrand.clear.value
            }
        }
    }
}
