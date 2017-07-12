//
//  Color+Theme.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

enum ColorBrand {
    case yellow
    case green
    case black
    case white
    case lightGray
    case gray
    case grayDisabled
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
            case .lightGray:
                return UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
            case .gray:
                return UIColor(red: 176/255.0, green: 176/255.0, blue: 176/255.0, alpha: 1.0)
            case .grayDisabled:
                return UIColor(red: 158/255.0, green: 153/255.0, blue: 146/255.0, alpha: 1.0)
            case .clear:
                return UIColor.clear
            }
        }
    }
}

enum Color {
    // Alert
    case alertBackground
    case alertButtonsPositiveBackground
    case alertButtonsNegativeBackground
    case alertMessage
    case alertButton
    case alertLightButton
    
    // NavigationBar
    case navigationBarBackground
    
    // CircularMenu
    case circularMenuBackgroundBorder
    case circularMenuBackground

    // Menu
    case menuTopBackground
    case menuBackBackground
    case menuLabel
    case menuProfile

    // Signup
    case signupBackground
    case signupHeaderTitleLabel
    case signupHeaderSubTitleLabel
    case signupStepHeaderLabel
    case signupStepDescriptionLabel

    // Login
    case loginBackground
    case loginHeaderLabel
    case loginTextField
    case loginTextFieldPlaceholder
    case loginContinueAsNotLoggedButton
    
    // Intro
    case introTitle

    // Home
    case homeEnabledBackground
    case homeDisabledBackground
    case homeDisabledIcon
    case homeDescriptionLabel
    
    // SearchCars
    case searchCarsClusterLabel
    case searchCarsNearestCar
    case searchCarsBookedCar
    
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

    // CarBookingPopup
    case carBookingPopupBackground
    case carBookingPopupPin
    case carBookingPopupLabel
    case carBookingPopupStatus

    // CarBookingCompleted
    case carBookingCompletedBannerBackground
    case carBookingCompletedBannerLabel
    case carBookingCompletedBackground
    case carBookingCompletedDescription
    case carBookingCompletedCo2
    
    // Profile
    case profileBackground
    case profileEcoStatus
    
    // Setting
    case settingHeaderBackground
    case settingHeaderLabel
    case settingItemLabel
    case settingIconBackground
    case settingOddCellBackground
    case settingEvenCellBackground

    // SettingsLanguages
    case settingsLanguagesHeaderBackground
    case settingsLanguagesHeaderLabel
    case settingsLanguagesItemLabel
    case settingsLanguagesBackground
    case settingsLanguagesOddCellBackground
    case settingsLanguagesEvenCellBackground

    // SettingsCities
    case settingsCitiesHeaderBackground
    case settingsCitiesHeaderLabel
    case settingsCitiesItemLabel
    case settingsCitiesBackground
    case settingsCitiesOddCellBackground
    case settingsCitiesEvenCellBackground

    // NoFavourites
    case noFavouritesHeaderBackground
    case noFavouritesHeaderLabel
    case noFavouritesBackground
    case noFavouritesTitle
    case noFavouritesDescription
    case noFavouritesNewFavouriteTextButton
    case noFavouritesNewFavouriteBackgroundButton
    case favouritesTitle
    case favouritesTitleLabel
    case favouritesItemTitleLabelEmphasized
    case favouritesItemTitleLabel
    case favouritesPopupTitle

    // CarTrips
    case carTripsHeaderBackground
    case carTripsHeaderLabel
    case carTripsItemTitle
    case carTripsItemBorderBackground
    case carTripsItemSubtitle
    case carTripsItemDescriptionTitle
    case carTripsItemDescriptionSubtitle
    case carTripsOddCellBackground
    case carTripsEvenCellBackground
    case carTripsItemExtendedDescription
    case carTripsSearchCarsLabel
    case noCarTripsSearchCarsButton

    // OnBoard
    case onBoardDescription
    case onBoardSkipTextButton
    case onBoardPageControlEmpty
    case onBoardPageControlFilled

    // Feeds
    case feedsHeaderBackground
    case feedsHeaderLabel
    case feedsHeaderBottomButtonOn
    case feedsHeaderBottomButtonOff
    case feedsAroundMeButtonLabel
    case feedsAroundMeButtonBackground
    case feedsItemIconBorderBackground

    // Web
    case webBackground
    
    var value: UIColor {
        get {
            switch self {
            // Alert
            case .alertBackground:
                return ColorBrand.black.value
            case .alertButtonsPositiveBackground:
                return ColorBrand.yellow.value
            case .alertButtonsNegativeBackground:
                return ColorBrand.gray.value
            case .alertMessage:
                return ColorBrand.white.value
            case .alertButton:
                return ColorBrand.black.value
            case .alertLightButton:
                return ColorBrand.white.value
            // NavigationBar
            case .navigationBarBackground:
                return ColorBrand.yellow.value
            // CircularMenu
            case .circularMenuBackgroundBorder:
                return ColorBrand.yellow.value.withAlphaComponent(0.5)
            case .circularMenuBackground:
                return ColorBrand.clear.value
            // Menu
            case .menuTopBackground:
                return ColorBrand.white.value
            case .menuBackBackground:
                return ColorBrand.lightGray.value
            case .menuLabel:
                return ColorBrand.black.value
            case .menuProfile:
                return ColorBrand.green.value
            // Signup
            case .signupBackground:
                return ColorBrand.lightGray.value
            case .signupHeaderTitleLabel:
                return ColorBrand.green.value
            case .signupHeaderSubTitleLabel:
                return ColorBrand.black.value
            case .signupStepHeaderLabel:
                return ColorBrand.green.value
            case .signupStepDescriptionLabel:
                return ColorBrand.black.value
            // Login
            case .loginBackground:
                return ColorBrand.lightGray.value
            case .loginHeaderLabel:
                return ColorBrand.green.value
            case .loginTextField:
                return ColorBrand.black.value
            case .loginTextFieldPlaceholder:
                return ColorBrand.black.value.withAlphaComponent(0.6)
            case .loginContinueAsNotLoggedButton:
                return ColorBrand.green.value
            // Intro
            case .introTitle:
                return ColorBrand.green.value
            // Home
            case .homeEnabledBackground:
                return ColorBrand.green.value
            case .homeDisabledBackground:
                return ColorBrand.grayDisabled.value
            case .homeDisabledIcon:
                return UIColor(hexString: "#b4ada7")
            case .homeDescriptionLabel:
                return ColorBrand.black.value
            // SearchCars
            case .searchCarsClusterLabel:
                return ColorBrand.green.value
            case .searchCarsNearestCar:
                return ColorBrand.green.value
            case .searchCarsBookedCar:
                return ColorBrand.yellow.value
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
                return ColorBrand.lightGray.value
            case .carPopupType:
                return ColorBrand.black.value
            case .carPopupLabel:
                return ColorBrand.black.value
            case .carPopupAddressPlaceholder:
                return ColorBrand.black.value.withAlphaComponent(0.7)
            // CarBookingPopup
            case .carBookingPopupBackground:
                return ColorBrand.clear.value
            case .carBookingPopupPin:
                return ColorBrand.yellow.value
            case .carBookingPopupLabel:
                return ColorBrand.black.value
            case .carBookingPopupStatus:
                return ColorBrand.green.value
            // CarBookingCompleted
            case .carBookingCompletedBannerBackground:
                return ColorBrand.white.value
            case .carBookingCompletedBannerLabel:
                return ColorBrand.black.value
            case .carBookingCompletedBackground:
                return ColorBrand.lightGray.value
            case .carBookingCompletedDescription:
                return ColorBrand.black.value
            case .carBookingCompletedCo2:
                return ColorBrand.green.value
            // Profile
            case .profileBackground:
                return ColorBrand.lightGray.value
            case .profileEcoStatus:
                return ColorBrand.green.value
            // Setting
            case .settingHeaderBackground:
                return ColorBrand.black.value
            case .settingHeaderLabel:
                return ColorBrand.white.value
            case .settingItemLabel:
                return ColorBrand.green.value
            case .settingIconBackground:
                return ColorBrand.green.value
            case .settingOddCellBackground:
                return ColorBrand.lightGray.value
            case .settingEvenCellBackground:
                return ColorBrand.white.value
            // SettingsLanguages
            case .settingsLanguagesHeaderBackground:
                return ColorBrand.black.value
            case .settingsLanguagesHeaderLabel:
                return ColorBrand.white.value
            case .settingsLanguagesItemLabel:
                return ColorBrand.green.value
            case .settingsLanguagesBackground:
                return ColorBrand.gray.value
            case .settingsLanguagesOddCellBackground:
                return ColorBrand.lightGray.value
            case .settingsLanguagesEvenCellBackground:
                return ColorBrand.white.value
            // SettingsCities
            case .settingsCitiesHeaderBackground:
                return ColorBrand.black.value
            case .settingsCitiesHeaderLabel:
                return ColorBrand.white.value
            case .settingsCitiesItemLabel:
                return ColorBrand.green.value
            case .settingsCitiesBackground:
                return ColorBrand.gray.value
            case .settingsCitiesOddCellBackground:
                return ColorBrand.lightGray.value
            case .settingsCitiesEvenCellBackground:
                return ColorBrand.white.value
            // No Favourites
            case .noFavouritesHeaderBackground:
                return ColorBrand.black.value
            case .noFavouritesHeaderLabel:
                return ColorBrand.white.value
            case .noFavouritesBackground:
                return ColorBrand.lightGray.value
            case .noFavouritesTitle:
                return ColorBrand.green.value
            case .noFavouritesDescription:
                return ColorBrand.black.value
            case .noFavouritesNewFavouriteTextButton:
                return ColorBrand.white.value
            case .noFavouritesNewFavouriteBackgroundButton:
                return ColorBrand.green.value
            case .favouritesTitle:
                return ColorBrand.green.value
            case .favouritesTitleLabel:
                return ColorBrand.white.value
            case .favouritesItemTitleLabelEmphasized:
                return ColorBrand.green.value
            case .favouritesItemTitleLabel:
                return ColorBrand.black.value
            case .favouritesPopupTitle:
                return ColorBrand.white.value
            // CarTrips
            case .carTripsHeaderBackground:
                return ColorBrand.black.value
            case .carTripsHeaderLabel:
                return ColorBrand.white.value
            case .carTripsOddCellBackground:
                return ColorBrand.white.value
            case .carTripsEvenCellBackground:
                return ColorBrand.lightGray.value
            case .carTripsItemBorderBackground:
                return ColorBrand.black.value
            case .carTripsItemTitle:
                return ColorBrand.green.value
            case .carTripsItemSubtitle:
                return ColorBrand.black.value
            case .carTripsItemDescriptionTitle:
                return UIColor(hexString: "#888888")
            case .carTripsItemDescriptionSubtitle:
                return ColorBrand.black.value
            case .carTripsItemExtendedDescription:
                return ColorBrand.black.value
            case .noCarTripsSearchCarsButton:
                return ColorBrand.yellow.value
            case .carTripsSearchCarsLabel:
                return UIColor(hexString: "#888888")
            // OnBoard
            case .onBoardDescription:
                return ColorBrand.green.value
            case .onBoardSkipTextButton:
                return ColorBrand.green.value
            case .onBoardPageControlEmpty:
                return ColorBrand.white.value
            case .onBoardPageControlFilled:
                return ColorBrand.green.value
            // Feeds
            case .feedsHeaderBackground:
                return ColorBrand.green.value
            case .feedsHeaderLabel:
                return ColorBrand.green.value
            case .feedsHeaderBottomButtonOn:
                return ColorBrand.white.value
            case .feedsHeaderBottomButtonOff:
                return ColorBrand.green.value
            case .feedsAroundMeButtonLabel:
                return ColorBrand.green.value
            case .feedsAroundMeButtonBackground:
                return ColorBrand.green.value
            // Web
            case .webBackground:
                return ColorBrand.lightGray.value
            }
        }
    }
}
