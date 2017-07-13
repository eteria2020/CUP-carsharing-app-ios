import Foundation
import RxCocoa
import RxSwift
import Action
import Boomerang

typealias Selection = Action<SelectionInput,SelectionOutput>

struct ViewModelFactory {
    static func navigationBar(leftItemType: NavigationBarItemType, rightItemType: NavigationBarItemType) -> ViewModelType {
        return NavigationBarViewModel(leftItem: leftItemType.getItem(), rightItem: rightItemType.getItem())
    }
    
    static func circularMenu(type: CircularMenuType) -> ViewModelType {
        return CircularMenuViewModel(type: type)
    }
    
    static func web(with type: WebType) -> ViewModelType {
        return WebViewModel(with: type)
    }
    
    static func intro() -> ViewModelType {
        return IntroViewModel()
    }

    static func signup() -> ViewModelType {
        return SignupViewModel()
    }

    static func login(nextViewModel: ViewModelType? = nil) -> ViewModelType {
        let loginViewModel = LoginViewModel()
        loginViewModel.nextViewModel = nextViewModel
        return loginViewModel
    }
    
    static func profile() -> ViewModelType {
        return ProfileViewModel()
    }

    static func home() -> ViewModelType {
        return HomeViewModel()
    }

    static func onBoard() -> ViewModelType {
        return OnBoardViewModel()
    }

    static func searchCars() -> ViewModelType {
        return SearchCarsViewModel()
    }
    
    static func searchBar() -> ViewModelType {
        return SearchBarViewModel()
    }
    
    static func carPopup() -> ViewModelType {
        return CarPopupViewModel()
    }

    static func feeds() -> ViewModelType {
        return FeedsViewModel()
    }

    static func carBookingPopup() -> ViewModelType {
        return CarBookingPopupViewModel()
    }

    static func menu() -> ViewModelType {
        return MenuViewModel()
    }

    static func settings() -> ViewModelType {
        return SettingsViewModel()
    }
    
    static func settingsLanguages() -> ViewModelType {
        return SettingsLanguagesViewModel()
    }
    
    static func settingsCities() -> ViewModelType {
        return SettingsCitiesViewModel()
    }
    
    static func noFavourites() -> ViewModelType {
        return NoFavouritesViewModel()
    }

    static func newFavourite() -> ViewModelType {
        return NewFavouriteViewModel()
    }

    static func favourites() -> ViewModelType {
        return FavouritesViewModel()
    }
    
    static func carTrips() -> ViewModelType {
        return CarTripsViewModel()
    }
    
    static func noCarTrips() -> ViewModelType {
        return NoCarTripsViewModel()
    }
    
    static func menuItem(fromModel model:MenuItem) -> ItemViewModelType {
        return MenuItemViewModel(model: model)
    }
    
    static func settingItem(fromModel model:Setting) -> ItemViewModelType {
        return SettingItemViewModel(model: model)
    }
    
    static func settingsLanguagesItem(fromModel model:Language) -> ItemViewModelType {
        return SettingsLanguageItemViewModel(model: model)
    }
    
    static func settingsCitiesItem(fromModel model:City) -> ItemViewModelType {
        return SettingsCityItemViewModel(model: model)
    }
    
    static func feedItem(fromModel model:Feed) -> ItemViewModelType {
        return FeedItemViewModel(model: model)
    }

    static func carTripItem(fromModel model:CarTrip) -> ItemViewModelType {
        return CarTripItemViewModel(model: model)
    }

    static func searchBarItem(fromModel model:Address) -> ItemViewModelType {
        return SearchBarItemViewModel(model: model)
    }
    
    static func searchBarItem(fromModel model:Car) -> ItemViewModelType {
        return SearchBarItemViewModel(model: model)
    }
    
    static func searchBarItem(fromModel model:Favorite) -> ItemViewModelType {
        return SearchBarItemViewModel(model: model)
    }
    
    static func carBookingCompleted(carTrip: CarTrip) -> ViewModelType {
        return CarBookingCompletedViewModel(carTrip: carTrip)
    }
    
    static func favouriteItem(fromModel model:Address) -> ItemViewModelType {
        return FavouriteItemViewModel(model: model)
    }
    
    static func categoryItem(fromModel model:Category) -> ItemViewModelType {
        return CategoryItemViewModel(model: model)
    }
}
