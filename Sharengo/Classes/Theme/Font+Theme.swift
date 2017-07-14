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
    // General
    case roundedButton
    
    // Alert
    case alertMessage
    case alertButton
    
    // Intro
    case introTitle

    // Menu
    case menuHeader
    case menuLabel

    // Home
    case homeDescription
    case homeDescriptionEmphasized
    
    // SearchCars
    case searchCarsClusterLabel
    
    // SearchBar
    case searchBarTextField
    case searchBarTextFieldPlaceholder
    case searchBarResult
    
    // CarPopup
    case carPopupType
    case carPopup
    case carPopupEmphasized
    
    // CarBookingPopup
    case carBookingPopupPin
    case carBookingPopupLabel
    case carBookingPopupLabelEmphasized
    case carBookingPopupStatus
    
    // CarBookingCompleted
    case carBookingCompletedBannerLabel
    case carBookingCompletedBannerLabelEmphasized
    case carBookingCompletedDescription
    case carBookingCompletedDescriptionEmphasized

    // Signup
    case signupHeaderTitleLabel
    case signupHeaderSubTitleLabel
    case signupStepHeaderLabel
    case signupStepDescriptionLabel

    // Login
    case loginHeaderLabel
    case loginTextField
    case loginTextFieldPlaceholder
    case loginForgotPassword
    
    // Profile
    case profileEcoStatus

    // Settings
    case settingHeader
    case settingLabel
    
    // SettingsLanguages
    case settingsLanguagesHeader
    case settingsLanguagesLabel

    // SettingsCities
    case settingsCitiesHeader
    case settingsCitiesLabel

    // NoFavourites
    case noFavouritesHeader
    case noFavouritesTitleLabel
    case noFavouritesDescriptionLabel
    
    // Favourites
    case favouritesUndoButton
    case favouritesTitleLabelEmphasized
    case favouritesTitleLabel
    case favouritesItemTitleLabelEmphasized
    case favouritesItemTitleLabel
    case favouritesPopupTitle

    // CarTrips
    case carTripsHeader
    case carTripsItemTitle
    case carTripsItemSubtitle
    case carTripsItemDescriptionTitle
    case carTripsItemDescriptionSubtitle
    case carTripsItemExtendedDescription
    case carTripsSearchCarsLabel
    
    // OnBoard
    case onBoardDescription
    case onBoardSkipButton
    
    // Feeds
    case feedsHeader
    case feedsItemTitle
    case feedsItemDate
    case feedsItemSubtitle
    case feedsItemDescription
    case feedsItemAdvantage
    case feedsAroundMeButton
    
    // Categories
    case categoriesItemTitle

    // Feed Detail
    case feedDetailHeader
    
    var value: UIFont {
        get {
            switch self {
            // General
            case .roundedButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 11))
            // Alert
            case .alertMessage:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .alertButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // Intro
            case .introTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 20))
            // Menu
            case .menuHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .menuLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            // Home
            case .homeDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 14))
            case .homeDescriptionEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // SearchCars
            case .searchCarsClusterLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // SearchBar
            case .searchBarTextField:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .searchBarTextFieldPlaceholder:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .searchBarResult:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            // CarPopup
            case .carPopupType:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 11))
            case .carPopup:
                return FontWeight.medium.font(withSize: self.getFontSize(size: 11))
            case .carPopupEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 11))
            // CarBookingPopup
            case .carBookingPopupPin:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 11))
            case .carBookingPopupLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 11))
            case .carBookingPopupLabelEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 11))
            case .carBookingPopupStatus:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 11))
            // CarBookingCompleted
            case .carBookingCompletedBannerLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .carBookingCompletedBannerLabelEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .carBookingCompletedDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .carBookingCompletedDescriptionEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // Signup
            case .signupHeaderTitleLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .signupHeaderSubTitleLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .signupStepHeaderLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .signupStepDescriptionLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            // Login
            case .loginHeaderLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .loginTextField:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .loginTextFieldPlaceholder:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .loginForgotPassword:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            // Profile
            case .profileEcoStatus:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 20))
            // Settings
            case .settingHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .settingLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // SettingsLanguages
            case .settingsLanguagesHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .settingsLanguagesLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // SettingsCities
            case .settingsCitiesHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .settingsCitiesLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // NoFavourites
            case .noFavouritesHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .noFavouritesTitleLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .noFavouritesDescriptionLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            // Favourites
            case .favouritesUndoButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .favouritesTitleLabelEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .favouritesTitleLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .favouritesItemTitleLabelEmphasized:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .favouritesItemTitleLabel:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .favouritesPopupTitle:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            // CarTrips
            case .carTripsHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .carTripsItemTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .carTripsItemSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .carTripsItemDescriptionTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .carTripsItemDescriptionSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .carTripsItemExtendedDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .carTripsSearchCarsLabel:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // OnBoard
            case .onBoardDescription:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 16))
            case .onBoardSkipButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Feeds
            case .feedsHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsItemDate:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsItemSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsItemDescription:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsItemAdvantage:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsAroundMeButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Categories
            case .categoriesItemTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Feed Detail
            case .feedDetailHeader:
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
