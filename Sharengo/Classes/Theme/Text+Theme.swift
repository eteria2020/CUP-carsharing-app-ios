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
    case favouritesItemTitle = "favouritesItemTitle"
    case favouritesPopupTitle = "favouritesPopupTitle"
    case favouritesPopupDescription = "favouritesPopupDescription"
    
    // CarTrips
    case carTripsHeader = "carTripsHeader"
    case carTripsItemTitle = "carTripsItemTitle"
    case carTripsItemSubtitle = "carTripsItemSubtitle"
    case carTripsItemDescription = "carTripsItemDescription"
    case carTripsItemExtendedDescription = "carTripsItemExtendedDescription"
    case carTripsSearchCarsLabel = "carTripsSearchCarsLabel"

    // OnBoard
    case onBoardDescription = "onBoardDescription"
    case onBoardSkip = "onBoardSkip"
    
    // Feeds
    case feedsHeaderCategory = "feedsHeaderCategory"
    case feedsHeader = "feedsHeader"
    case feedsClaim = "feedsClaim"
    case feedsItemBottom = "feedsItemBottom"
    case feedsAroundMe = "feedsAroundMe"
    
    // Categories
    case categoriesItemTitle = "categoriesItemTitle"
    
    // Feed Detail
    case feedDetailHeader = "feedDetailHeader"
    case feedClaim = "feedClaim"
    case feedsClaimMirrored = "feedsClaimMirrored"
    case feedBottom = "feedBottom"
    case feedFavourite = "feedFavourite"

    // No Feeds
    case noFeedsHeader = "noFeedsHeader"
    case noFeedsDescription = "noFeedsDescription"
    case noFeedsFeedsHeader = "noFeedsFeedsHeader"

    // Support
    case supportHeader = "supportHeader"
    case supportTitle = "supportTitle"
    case supportSubtitle = "supportSubtitle"
    
    // Invite Friend
    case inviteFriendHeader = "inviteFriendHeader"
    case inviteFriendDescriptionFirstPart = "inviteFriendDescriptionFirstPart"
    case inviteFriendDescriptionSecondPart = "inviteFriendDescriptionSecondPart"
    case inviteFriendDescriptionThirdPart = "inviteFriendDescriptionThirdPart"
    case inviteFriendDescriptionFourthPart = "inviteFriendDescriptionFourthPart"
    
    // Faq
    case faqHeader = "faqHeader"

    // Rates
    case ratesHeaderTitle = "ratesHeaderTitle"
    case ratesRatesTitle = "ratesRatesTitle"
    case ratesRatesDescription = "ratesRatesDescription"
    case ratesBonusTitle = "ratesBonusTitle"
    case ratesBonusDescription = "ratesBonusDescription"
    
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
            .favouritesTitle,
            .favouritesItemTitle,
            .favouritesPopupTitle,
            .favouritesPopupDescription,
            .profileEcoStatus,
            // CarTrips
            .carTripsHeader,
            .carTripsItemTitle,
            .carTripsItemSubtitle,
            .carTripsItemDescription,
            .carTripsItemExtendedDescription,
            .carTripsSearchCarsLabel,
            // OnBoard
            .onBoardDescription,
            .onBoardSkip,
            // Feeds
            .feedsHeaderCategory,
            .feedsHeader,
            .feedsClaim,
            .feedsClaimMirrored,
            .feedsItemBottom,
            .feedsAroundMe,
            // Categories
            .categoriesItemTitle,
            // Feed Detail
            .feedDetailHeader,
            .feedClaim,
            .feedBottom,
            .feedFavourite,
            // No Feeds
            .noFeedsHeader,
            .noFeedsDescription,
            .noFeedsFeedsHeader,
            // Support
            .supportHeader,
            .supportTitle,
            .supportSubtitle,
            // Invite Friend
            .inviteFriendHeader,
            .inviteFriendDescriptionFirstPart,
            .inviteFriendDescriptionSecondPart,
            .inviteFriendDescriptionThirdPart,
            .inviteFriendDescriptionFourthPart,
            // Faq
            .faqHeader,
            // Rates
            .ratesHeaderTitle,
            .ratesRatesTitle,
            .ratesRatesDescription,
            .ratesBonusTitle,
            .ratesBonusDescription,
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
            case .favouritesItemTitle:
                let statusStyle = StringStyle(.font(Font.favouritesItemTitleLabelEmphasized.value), .color(Color.favouritesItemTitleLabelEmphasized.value), .alignment(.center))
                return StringStyle(.font(Font.favouritesItemTitleLabel.value), .color(Color.favouritesItemTitleLabel.value), .alignment(.center),.xmlRules([.style("bold", statusStyle)]))
            case .favouritesPopupTitle:
                return StringStyle(.font(Font.favouritesPopupTitle.value), .color(Color.favouritesPopupTitle.value), .alignment(.center))
            case .favouritesPopupDescription:
                let statusStyle = StringStyle(.font(Font.favouritesItemTitleLabelEmphasized.value), .color(ColorBrand.white.value), .alignment(.center))
                return StringStyle(.font(Font.favouritesItemTitleLabel.value), .color(ColorBrand.white.value), .alignment(.center),.xmlRules([.style("bold", statusStyle)]))
            // CarTrips
            case .carTripsHeader:
                return StringStyle(.font(Font.carTripsHeader.value), .color(Color.carTripsHeaderLabel.value), .alignment(.center))
            case .carTripsItemTitle:
                return StringStyle(.font(Font.carTripsItemTitle.value), .color(Color.carTripsItemTitle.value), .alignment(.center))
            case .carTripsItemSubtitle:
                return StringStyle(.font(Font.carTripsItemSubtitle.value), .color(Color.carTripsItemSubtitle.value), .alignment(.center))
            case .carTripsItemDescription:
                return StringStyle(.font(Font.carTripsItemDescriptionTitle.value), .color(Color.carTripsItemDescriptionTitle.value), .alignment(.center))
            case .carTripsItemExtendedDescription:
                let startDateAndTimeStyle = StringStyle(.font(Font.carTripsItemDescriptionTitle.value), .color(Color.carTripsItemDescriptionTitle.value), .alignment(.center))
                let startAddressStyle = StringStyle(.font(Font.carTripsItemExtendedDescription.value), .color(Color.carTripsItemExtendedDescription.value), .alignment(.center))
                let endDateAndTimeStyle = StringStyle(.font(Font.carTripsItemDescriptionTitle.value), .color(Color.carTripsItemDescriptionTitle.value), .alignment(.center))
                let endAddressStyle = StringStyle(.font(Font.carTripsItemExtendedDescription.value), .color(Color.carTripsItemExtendedDescription.value), .alignment(.center))
                let minuteRateStyle = StringStyle(.font(Font.carBookingPopupLabelEmphasized.value), .color(Color.carBookingPopupLabel.value), .alignment(.center))
                let freeMinutesStyle = StringStyle(.font(Font.carBookingPopupLabelEmphasized.value), .color(Color.carBookingPopupLabel.value), .alignment(.center))
                let kmTraveledStyle = StringStyle(.font(Font.carBookingPopupLabelEmphasized.value), .color(Color.carTripsItemDescriptionTitle.value), .alignment(.center))
                let placeholderStyle = StringStyle(.font(Font.carTripsItemExtendedDescription.value), .color(Color.carTripsItemExtendedDescription.value), .alignment(.center))
                return StringStyle(.font(Font.carBookingPopupLabel.value), .color(Color.carBookingPopupLabel.value), .alignment(.center),.xmlRules([.style("startDateAndTime", startDateAndTimeStyle), .style("startAddress", startAddressStyle), .style("endDateAndTime", endDateAndTimeStyle), .style("endAddress", endAddressStyle),  .style("minuteRate", minuteRateStyle), .style("placeholder", placeholderStyle), .style("freeMinutes", freeMinutesStyle), .style("kmTraveled", kmTraveledStyle)]))
            case .carTripsSearchCarsLabel:
                return StringStyle(.font(Font.carTripsSearchCarsLabel.value), .color(Color.carTripsSearchCarsLabel.value), .alignment(.center))
            // OnBoard
            case .onBoardDescription:
                return StringStyle(.font(Font.onBoardDescription.value), .color(Color.onBoardDescription.value), .alignment(.center))
            case .onBoardSkip:
                return StringStyle(.font(Font.onBoardSkipButton.value), .color(Color.onBoardSkipTextButton.value), .alignment(.left))
            // Feeds
            case .feedsHeaderCategory:
                return StringStyle(.font(Font.feedsHeaderCategory.value), .color(Color.feedsHeaderCategoryLabel.value), .alignment(.center))
            case .feedsHeader:
                return StringStyle(.font(Font.feedsHeader.value), .color(Color.feedsHeaderBackground.value), .alignment(.center))
            case .feedsClaim:
                return StringStyle(.font(Font.feedsClaim.value), .color(Color.feedsClaim.value), .alignment(.right))
            case .feedsClaimMirrored:
                return StringStyle(.font(Font.feedsClaim.value), .color(Color.feedsClaim.value), .alignment(.left))
            case .feedsItemBottom:
                let titleStyle = StringStyle(.font(Font.feedsItemTitle.value), .color(Color.feedsItemTitle.value), .alignment(.left))
                let dateStyle = StringStyle(.font(Font.feedsItemDate.value), .color(Color.feedsItemDate.value), .alignment(.left))
                let subtitleStyle = StringStyle(.font(Font.feedsItemSubtitle.value), .color(Color.feedsItemSubtitle.value), .alignment(.left))
                let descriptionStyle = StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.left))
                let advantageStyle = StringStyle(.font(Font.feedsItemAdvantage.value), .color(Color.feedsItemAdvantage.value), .alignment(.left))
                return StringStyle(.font(Font.feedsItemDescription.value), .color(Color.feedsItemDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("date", dateStyle), .style("subtitle", subtitleStyle), .style("description", descriptionStyle),  .style("advantage", advantageStyle)]))
            case .feedsAroundMe:
                return StringStyle(.font(Font.feedsAroundMeButton.value), .color(Color.feedsAroundMeButtonLabel.value), .alignment(.left))
            // Categories
            case .categoriesItemTitle:
                return StringStyle(.font(Font.categoriesItemTitle.value), .color(Color.categoriesItemTitle.value), .alignment(.center))
            // Feed Detail
            case .feedDetailHeader:
                return StringStyle(.font(Font.feedDetailHeader.value), .color(Color.feedDetailHeaderLabel.value), .alignment(.center))
            case .feedClaim:
                return StringStyle(.font(Font.feedClaim.value), .color(Color.feedClaim.value), .alignment(.right))
            case .feedBottom:
                let titleStyle = StringStyle(.font(Font.feedTitle.value), .color(Color.feedTitle.value), .alignment(.left))
                let dateStyle = StringStyle(.font(Font.feedDate.value), .color(Color.feedDate.value), .alignment(.left))
                let subtitleStyle = StringStyle(.font(Font.feedSubtitle.value), .color(Color.feedSubtitle.value), .alignment(.left))
                let descriptionStyle = StringStyle(.font(Font.feedDescription.value), .color(Color.feedDescription.value), .alignment(.left))
                let extendedDescriptionStyle = StringStyle(.font(Font.feedExtendedDescription.value), .color(Color.feedExtendedDescription.value), .alignment(.left))
                let advantageStyle = StringStyle(.font(Font.feedAdvantage.value), .color(Color.feedAdvantage.value), .alignment(.left))
                return StringStyle(.font(Font.feedDescription.value), .color(Color.feedDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("date", dateStyle), .style("subtitle", subtitleStyle), .style("description", descriptionStyle),  .style("advantage", advantageStyle), .style("extendedDescription", extendedDescriptionStyle)]))
            case .feedFavourite:
                return StringStyle(.font(Font.feedFavouriteButton.value), .color(Color.feedFavouriteButtonLabel.value), .alignment(.left))
            // No Feeds
            case .noFeedsHeader:
                return StringStyle(.font(Font.noFeedsHeader.value), .color(Color.noFeedsHeaderLabel.value), .alignment(.center))
            case .noFeedsDescription:
                let titleStyle = StringStyle(.font(Font.noFeedsTitle.value), .color(Color.noFeedsTitle.value), .alignment(.center))
                let descriptionStyle = StringStyle(.font(Font.noFeedsDescription.value), .color(Color.noFeedsDescription.value), .alignment(.center))
                return StringStyle(.font(Font.noFeedsDescription.value), .color(Color.noFeedsDescription.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("description", descriptionStyle)]))

            case .noFeedsFeedsHeader:
                return StringStyle(.font(Font.noFeedsFeedsHeader.value), .color(Color.noFeedsFeedsHeaderBackground.value), .alignment(.center))
            // Support
            case .supportHeader:
                return StringStyle(.font(Font.supportHeader.value), .color(Color.supportHeaderLabel.value), .alignment(.center))
            case .supportTitle:
                return StringStyle(.font(Font.supportTitle.value), .color(Color.supportTitle.value), .alignment(.center))
            case .supportSubtitle:
                return StringStyle(.font(Font.supportSubtitle.value), .color(Color.supportSubtitle.value), .alignment(.center))
            // Invite Friend
            case .inviteFriendHeader:
                return StringStyle(.font(Font.inviteFriendHeader.value), .color(Color.inviteFriendHeaderLabel.value), .alignment(.center))
            case .inviteFriendDescriptionFirstPart:
                let titleStyle = StringStyle(.font(Font.inviteFriendDescriptionFirstPartTitle.value), .color(Color.inviteFriendDescriptionFirstPartTitle.value), .alignment(.center))
                let subtitleStyle = StringStyle(.font(Font.inviteFriendDescriptionFirstPartSubtitle.value), .color(Color.inviteFriendDescriptionFirstPartSubtitle.value), .alignment(.center))
                return StringStyle(.font(Font.inviteFriendDescriptionFirstPartTitle.value), .color(Color.inviteFriendDescriptionFirstPartTitle.value), .alignment(.center),.xmlRules([.style("title", titleStyle), .style("subtitle", subtitleStyle)]))
            case .inviteFriendDescriptionSecondPart:
                return StringStyle(.font(Font.inviteFriendDescriptionSecondPart.value), .color(Color.inviteFriendDescriptionSecondPartLabel.value), .alignment(.center))
            case .inviteFriendDescriptionThirdPart:
                let firstPartStyle = StringStyle(.font(Font.inviteFriendDescriptionThirdPartTitle.value), .color(Color.inviteFriendDescriptionThirdPartTitle.value), .alignment(.center))
                let secondPartStyle = StringStyle(.font(Font.inviteFriendDescriptionThirdPartSubtitle.value), .color(Color.inviteFriendDescriptionThirdPartSubtitle.value), .alignment(.center))
                return StringStyle(.font(Font.inviteFriendDescriptionFirstPartTitle.value), .color(Color.inviteFriendDescriptionFirstPartTitle.value), .alignment(.center),.xmlRules([.style("firstPart", firstPartStyle), .style("secondPart", secondPartStyle)]))
            case .inviteFriendDescriptionFourthPart:
                return StringStyle(.font(Font.inviteFriendDescriptionFourthPart.value), .color(Color.inviteFriendDescriptionFourthPartLabel.value), .alignment(.center))
            // Faq
            case .faqHeader:
                return StringStyle(.font(Font.faqHeader.value), .color(Color.faqHeaderTitle.value), .alignment(.center))
            // Rates
            case .ratesHeaderTitle:
                return StringStyle(.font(Font.ratesHeaderTitle.value), .color(Color.ratesHeaderTitle.value), .alignment(.center))
            case .ratesRatesTitle:
                return StringStyle(.font(Font.ratesRatesTitle.value), .color(Color.ratesRatesTitle.value), .alignment(.center))
            case .ratesRatesDescription:
                let descriptionStyle = StringStyle(.font(Font.ratesRatesDescription.value), .color(Color.ratesRatesDescription.value), .alignment(.center))
                let valueStyle = StringStyle(.font(Font.ratesRatesValue.value), .color(Color.ratesRatesDescription.value), .alignment(.center))
                return StringStyle(.font(Font.ratesRatesDescription.value), .color(Color.ratesRatesDescription.value), .alignment(.center),.xmlRules([.style("description", descriptionStyle), .style("value", valueStyle)]))
            case .ratesBonusTitle:
                return StringStyle(.font(Font.ratesBonusTitle.value), .color(Color.ratesBonusTitle.value), .alignment(.center))
            case .ratesBonusDescription:
                return StringStyle(.font(Font.ratesBonusDescription.value), .color(Color.ratesBonusDescription.value), .alignment(.center))
            }
        }().byAdding(.lineBreakMode(.byTruncatingTail))
    }
    
    static func setup() {
        all.forEach { NamedStyles.shared.registerStyle(style: $0) }
    }
}
