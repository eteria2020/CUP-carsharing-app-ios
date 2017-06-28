import UIKit
import Boomerang

enum Storyboard : String {
    case main = "Main"
    func scene<Type:UIViewController>(_ identifier:SceneIdentifier) -> Type {
        return UIStoryboard(name: self.rawValue, bundle: nil).instantiateViewController(withIdentifier: identifier.rawValue).setup() as! Type
    }
}

enum SceneIdentifier : String, ListIdentifier {
    case web = "web"
    case intro = "intro"
    case loading = "loading"
    case menu = "menu"
    case settings = "settings"
    case settingsLanguages = "settingsLanguages"
    case settingsCities = "settingsCities"
    case signup = "signup"
    case login = "login"
    case home = "home"
    case profile = "profile"
    case searchBar = "searchBar"
    case searchCars = "searchCars"
    case carBookingCompleted = "carBookingCompleted"
    case noFavourites = "noFavourites"
    var name: String {
        return self.rawValue
    }
    var type: String? {return nil}
}

extension ListViewModelType {
    var listIdentifiers:[ListIdentifier] {
        return CollectionViewCell.all()
    }
}

enum CollectionViewCell : String, ListIdentifier {
    case searchBar = "SearchBarCollectionViewCell"
    case menu = "MenuItemCollectionViewCell"
    case setting = "SettingItemCollectionViewCell"
    case settingsLanguage = "SettingsLanguageItemCollectionViewCell"
    case settingsCity = "SettingsCityItemCollectionViewCell"

    static func all() -> [CollectionViewCell] {
        return [
            .searchBar,
            .menu,
            .setting,
            .settingsLanguage,
            .settingsCity
        ]
    }
    static func headers() -> [CollectionViewCell] {
        return self.all().filter{ $0.type == UICollectionElementKindSectionHeader}
    }
    var name: String {return self.rawValue}
    var type: String? {
        switch self {
        default: return nil
            
        }
    }
}
