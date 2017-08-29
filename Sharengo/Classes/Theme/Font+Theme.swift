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
    case feedsHeaderCategory
    case feedsItemTitle
    case feedsItemDate
    case feedsItemDate2
    case feedsItemSubtitle
    case feedsItemSubtitle2
    case feedsItemDescription
    case feedsItemDescription2
    case feedsItemAdvantage
    case feedsItemAdvantage2
    case feedsAroundMeButton
    case feedsClaim
    
    // Categories
    case categoriesItemTitle

    // Feed Detail
    case feedDetailHeader
    case feedTitle
    case feedDate
    case feedSubtitle
    case feedDescription
    case feedExtendedDescription
    case feedAdvantage
    case feedFavouriteButton
    case feedClaim
    
    // No Feeds
    case noFeedsHeader
    case noFeedsTitle
    case noFeedsDescription
    case noFeedsFeedsHeader

    // Support
    case supportHeader
    case supportTitle
    case supportSubtitle
    
    // Invite Friend
    case inviteFriendHeader
    case inviteFriendDescriptionFirstPartTitle
    case inviteFriendDescriptionFirstPartSubtitle
    case inviteFriendDescriptionSecondPart
    case inviteFriendDescriptionThirdPartTitle
    case inviteFriendDescriptionThirdPartSubtitle
    case inviteFriendDescriptionFourthPart

    // Faq
    case faqHeader

    // Rates
    case ratesHeaderTitle
    case ratesRatesTitle
    case ratesRatesDescription
    case ratesRatesValue
    case ratesBonusTitle
    case ratesBonusDescription

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
            case .feedsHeaderCategory:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .feedsHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemDate:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemDate2:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .feedsItemSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemSubtitle2:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .feedsItemDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .feedsItemDescription2:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .feedsItemAdvantage:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedsItemAdvantage2:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .feedsAroundMeButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedsClaim:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Categories
            case .categoriesItemTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Feed Detail
            case .feedDetailHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .feedTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedDate:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .feedExtendedDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .feedAdvantage:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .feedFavouriteButton:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .feedClaim:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // No Feeds
            case .noFeedsHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .noFeedsTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .noFeedsDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .noFeedsFeedsHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            // Support
            case .supportHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .supportTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            case .supportSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 14))
            // Invite Friend
            case .inviteFriendHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionFirstPartTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionFirstPartSubtitle:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionSecondPart:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionThirdPartTitle:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionThirdPartSubtitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .inviteFriendDescriptionFourthPart:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            // Faq
            case .faqHeader:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            // Rates
            case .ratesHeaderTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .ratesRatesTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .ratesRatesDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
            case .ratesRatesValue:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 12))
            case .ratesBonusTitle:
                return FontWeight.bold.font(withSize: self.getFontSize(size: 13))
            case .ratesBonusDescription:
                return FontWeight.regular.font(withSize: self.getFontSize(size: 13))
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
