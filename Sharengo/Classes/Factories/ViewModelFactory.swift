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
    
    static func intro() -> ViewModelType {
        return IntroViewModel()
    }

    static func home() -> ViewModelType {
        return HomeViewModel()
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
    
    static func carBookingPopup() -> ViewModelType {
        return CarBookingPopupViewModel()
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
}
