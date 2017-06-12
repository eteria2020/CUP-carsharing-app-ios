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
    case searchBarResult = "searchBarResult"
   
    // CarPopup
    case carPopupType = "carPopupType"
    case carPopupPlate = "carPopupPlate"
    case carPopupCapacity = "carPopupCapacity"
    case carPopupAddressPlaceholder = "carPopupAddressPlaceholder"
    case carPopupAddress = "carPopupAddress"
    case carPopupDistance = "carPopupDistance"
    case carPopupWalkingDistance = "carPopupWalkingDistance"
    
    // CarBookingPopup
    case carBookingPopupPin = "carBookingPopupPin"
    case carBookingPopupInfo = "carBookingPopupInfo"
    case carBookingPopupTime = "carBookingPopupTime"
    
    // CarBookingCompleted
    case carBookingCompletedDescription = "carBookingCompletedDescription"
    case carBookingCompletedCo2 = "carBookingCompletedCo2"
    
    static var all:[TextStyle] {
        return [
            // SearchBar
            .searchBarTextField,
            .searchBarResult,
            // CarPopup
            .carPopupType,
            .carPopupPlate,
            .carPopupCapacity,
            .carPopupAddressPlaceholder,
            .carPopupAddress,
            .carPopupDistance,
            .carPopupWalkingDistance,
            // CarBookingPopup
            .carBookingPopupPin,
            .carBookingPopupInfo,
            .carBookingPopupTime,
            // CarBookingCompleted
            .carBookingCompletedDescription,
            .carBookingCompletedCo2
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
            case .searchBarResult:
                return StringStyle(.font(Font.searchBarResult.value), .color(Color.searchBarResult.value), .alignment(.center))
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
            // CarBookingPopup
            case .carBookingPopupPin:
                return StringStyle(.font(Font.carBookingPopupPin.value), .color(Color.carBookingPopupPin.value), .alignment(.center))
            case .carBookingPopupInfo:
                let statusStyle = StringStyle(.font(Font.carBookingPopupStatus.value), .color(Color.carBookingPopupStatus.value), .alignment(.center))
                let placeholderStyle = StringStyle(.font(Font.carPopup.value), .color(Color.carPopupAddressPlaceholder.value), .alignment(.center))
                let boldStyle = StringStyle(.font(Font.carBookingPopupLabelEmphasized.value), .color(Color.carBookingPopupLabel.value), .alignment(.center))
                return StringStyle(.font(Font.carBookingPopupLabel.value), .color(Color.carBookingPopupLabel.value), .alignment(.center),.xmlRules([.style("bold", boldStyle), .style("status", statusStyle), .style("placeholder", placeholderStyle)]))
            case .carBookingPopupTime:
                let boldStyle = StringStyle(.font(Font.carBookingPopupLabelEmphasized.value), .color(Color.carBookingPopupLabel.value), .alignment(.left))
                return StringStyle(.font(Font.carBookingPopupLabel.value), .color(Color.carBookingPopupLabel.value), .alignment(.left),.xmlRules([.style("bold", boldStyle)]))
            // CarBookingCompleted
            case .carBookingCompletedDescription:
                let boldStyle = StringStyle(.font(Font.carBookingCompletedDescriptionEmphasized.value), .color(Color.carBookingCompletedDescription.value), .alignment(.center))
                return StringStyle(.font(Font.carBookingCompletedDescription.value), .color(Color.carBookingCompletedDescription.value), .alignment(.center),.xmlRules([.style("bold", boldStyle)]))
            case .carBookingCompletedCo2:
                let boldStyle = StringStyle(.font(Font.carBookingCompletedDescriptionEmphasized.value), .color(Color.carBookingCompletedCo2.value), .alignment(.center))
                return StringStyle(.font(Font.carBookingCompletedDescription.value), .color(Color.carBookingCompletedDescription.value), .alignment(.center),.xmlRules([.style("bold", boldStyle)]))
            }
        }().byAdding(.lineBreakMode(.byTruncatingTail))
    }
    
    static func setup() {
        all.forEach { NamedStyles.shared.registerStyle(style: $0) }
    }
}
