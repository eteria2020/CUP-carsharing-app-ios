//
//  Text+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 21/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import BonMot

public protocol TextStyleType {
    var name:String {get}
    var style:StringStyle {get}
}

public extension NamedStyles {
    func registerStyle(style:TextStyleType) {
        self.registerStyle(forName: style.name, style: style.style)
    }
}

enum TextStyle: String, TextStyleType {
    // SearchBar
    case searchBarTextField = "searchBarTextField"
   
    // CarPopup
    case carPopupType = "carPopupType"
    case carPopupPlate = "carPopupPlate"
    case carPopupCapacity = "carPopupCapacity"
    case carPopupAddressPlaceholder = "carPopupAddressPlaceholder"
    case carPopupAddress = "carPopupAddress"
    case carPopupDistance = "carPopupDistance"
    case carPopupWalkingDistance = "carPopupWalkingDistance"
    
    static var all:[TextStyle] {
        return [
            // SearchBar
            .searchBarTextField,
            // CarPopup
            .carPopupType,
            .carPopupPlate,
            .carPopupCapacity,
            .carPopupAddressPlaceholder,
            .carPopupAddress,
            .carPopupDistance,
            .carPopupWalkingDistance
        ]
    }
    
    var name:String {
        return self.rawValue
    }
    
    var style:StringStyle {
        return { () -> StringStyle in
            switch self {
            // SearchBar
            case .searchBarTextField:
                return StringStyle(.font(Font.searchBarTextField.value), .color(Color.searchBarTextField.value), .alignment(.center))
            // CarPopup
            case .carPopupType:
                return StringStyle(.font(Font.carPopupType.value), .color(Color.carPopupLabel.value), .alignment(.center))
            case .carPopupPlate, .carPopupCapacity:
                let boldStyle = StringStyle(.font(Font.carPopupEmphasized.value), .color(Color.carPopupLabel.value), .alignment(.center))
                return StringStyle(.font(Font.carPopup.value), .color(Color.carPopupLabel.value), .alignment(.center),.xmlRules([.style("bold", boldStyle)]))
            case .carPopupAddressPlaceholder:
                return StringStyle(.font(Font.carPopup.value), .color(Color.carPopupAddressPlaceholder.value), .alignment(.left))
            case .carPopupAddress, .carPopupDistance, .carPopupWalkingDistance:
                return StringStyle(.font(Font.carPopup.value), .color(Color.carPopupLabel.value), .alignment(.left))
            }
        }().byAdding(.lineBreakMode(.byTruncatingTail))
    }
    
    static func setup() {
        all.forEach { NamedStyles.shared.registerStyle(style: $0) }
    }
}
