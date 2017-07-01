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
    // Intro
    case introTitle = "introTitle"

    // Menu
    case menuHeader = "menuHeader"
    case menuItemTitle = "menuItemTitle"

    // Home
    case homeDescription = "homeDescription"
    
    // SearchBar
    case searchBarTextField = "searchBarTextField"
    case searchBarResult = "searchBarResult"

    // Signup
    case signupHeader = "signupHeader"
    case signupStepHeader = "signupStepHeader"
    case signupStepDescription = "signupStepDescription"

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

    // Login
    case loginFormHeader = "loginFormHeader"
    case loginNotYetRegistered = "loginNotYetRegistered"
    
    // Profile
    case profileEcoStatus = "profileEcoStatus"

    // Settings
    case settingHeader = "settingHeader"
    case settingItemTitle = "settingItemTitle"

    // SettingsLanguages
    case settingsLanguagesHeader = "settingsLanguagesHeader"
    case settingsLanguagesItemTitle = "settingsLanguagesItemTitle"

    // SettingsCities
    case settingsCitiesHeader = "settingsCitiesHeader"
    case settingsCitiesItemTitle = "settingsCitiesItemTitle"

    // NoFavourites
    case noFavouritesHeader = "noFavouritesHeader"
    case noFavouritesTitle = "noFavouritesTitle"
    case noFavouritesDescription = "noFavouritesDescription"
    
    // Favourites
    case favouritesTitle = "favouritesTitle"

    static var all:[TextStyle] {
        return [
            // Intro
            .introTitle,
            // Home
            .homeDescription,
            // Menu
            .menuHeader,
            .menuItemTitle,
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
            .carBookingCompletedCo2,
            // Login
            .loginFormHeader,
            .loginNotYetRegistered,
            // Signup
            .signupHeader,
            .signupStepHeader,
            .signupStepDescription,
            // Profile
            .profileEcoStatus,
            // Setting
            .settingHeader,
            .settingItemTitle,
            // SettingsLanguages
            .settingsLanguagesHeader,
            .settingsLanguagesItemTitle,
            // SettingsLanguages
            .settingsCitiesHeader,
            .settingsCitiesItemTitle,
            // NoFavourites
            .noFavouritesHeader,
            .noFavouritesTitle,
            .noFavouritesDescription,
            // Favourites
            .favouritesTitle
        ]
    }
    
    var name:String {
        return self.rawValue
    }
    
    var style:StringStyle {
        return { () -> StringStyle in
            switch self {
            // Intro
            case .introTitle:
                return StringStyle(.font(Font.introTitle.value), .color(Color.introTitle.value), .alignment(.center))
            // Menu
            case .menuHeader:
                return StringStyle(.font(Font.menuHeader.value), .color(Color.menuLabel.value), .alignment(.left))
            case .menuItemTitle:
                return StringStyle(.font(Font.menuLabel.value), .color(Color.menuLabel.value), .alignment(.left))
            // Home
            case .homeDescription:
                let boldStyle = StringStyle(.font(Font.homeDescriptionEmphasized.value), .color(Color.homeDescriptionLabel.value), .alignment(.center))
                return StringStyle(.font(Font.homeDescription.value), .color(Color.homeDescriptionLabel.value), .alignment(.center),.xmlRules([.style("bold", boldStyle)]))
            // SearchBar
            case .searchBarTextField:
                return StringStyle(.font(Font.searchBarTextField.value), .color(Color.searchBarTextField.value), .alignment(.center))
            case .searchBarResult:
                return StringStyle(.font(Font.searchBarResult.value), .color(Color.searchBarResult.value), .alignment(.center))
            // Signup
            case .signupHeader:
                let titleStyle = StringStyle(.font(Font.signupHeaderTitleLabel.value), .color(Color.signupHeaderTitleLabel.value), .alignment(.center))
                return StringStyle(.font(Font.signupHeaderSubTitleLabel.value), .color(Color.signupHeaderSubTitleLabel.value), .alignment(.center),.xmlRules([.style("title", titleStyle)]))
            case .signupStepHeader:
                return StringStyle(.font(Font.signupStepHeaderLabel.value), .color(Color.signupStepHeaderLabel.value), .alignment(.center))
            case .signupStepDescription:
                return StringStyle(.font(Font.signupStepDescriptionLabel.value), .color(Color.signupStepDescriptionLabel.value), .alignment(.center))
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
            // Login
            case .loginFormHeader:
                return StringStyle(.font(Font.loginHeaderLabel.value), .color(Color.loginHeaderLabel.value), .alignment(.center))
            case .loginNotYetRegistered:
                return StringStyle(.font(Font.loginHeaderLabel.value), .color(Color.loginHeaderLabel.value), .alignment(.center))
            // Profile
            case .profileEcoStatus:
                return StringStyle(.font(Font.profileEcoStatus.value), .color(Color.profileEcoStatus.value), .alignment(.center))
            // Settings
            case .settingHeader:
                return StringStyle(.font(Font.settingHeader.value), .color(Color.settingHeaderLabel.value), .alignment(.center))
            case .settingItemTitle:
                return StringStyle(.font(Font.settingLabel.value), .color(Color.settingItemLabel.value), .alignment(.center))
            // SettingsLanguages
            case .settingsLanguagesHeader:
                return StringStyle(.font(Font.settingsLanguagesHeader.value), .color(Color.settingsLanguagesHeaderLabel.value), .alignment(.center))
            case .settingsLanguagesItemTitle:
                return StringStyle(.font(Font.settingsLanguagesLabel.value), .color(Color.settingsLanguagesItemLabel.value), .alignment(.center))
            // SettingsCities
            case .settingsCitiesHeader:
                return StringStyle(.font(Font.settingsCitiesHeader.value), .color(Color.settingsCitiesHeaderLabel.value), .alignment(.center))
            case .settingsCitiesItemTitle:
                return StringStyle(.font(Font.settingsCitiesLabel.value), .color(Color.settingsCitiesItemLabel.value), .alignment(.center))
            // NoFavourites
            case .noFavouritesHeader:
                return StringStyle(.font(Font.noFavouritesHeader.value), .color(Color.noFavouritesHeaderLabel.value), .alignment(.center))
            case .noFavouritesTitle:
                return StringStyle(.font(Font.noFavouritesTitleLabel.value), .color(Color.noFavouritesTitle.value), .alignment(.center))
            case .noFavouritesDescription:
                return StringStyle(.font(Font.noFavouritesDescriptionLabel.value), .color(Color.noFavouritesDescription.value), .alignment(.center))
            // Favourites
            case .favouritesTitle:
                let boldStyle = StringStyle(.font(Font.favouritesTitleLabelEmphasized.value), .color(Color.favouritesTitleLabel.value), .alignment(.center))
                return StringStyle(.font(Font.favouritesTitleLabel.value), .color(Color.favouritesTitleLabel.value), .alignment(.center),.xmlRules([.style("bold", boldStyle)]))
            }
        }().byAdding(.lineBreakMode(.byTruncatingTail))
    }
    
    static func setup() {
        all.forEach { NamedStyles.shared.registerStyle(style: $0) }
    }
}
