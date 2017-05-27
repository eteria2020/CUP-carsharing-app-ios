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
    
    static func home() -> ViewModelType {
        return HomeViewModel()
    }
    
    static func searchCars() -> ViewModelType {
        return SearchCarsViewModel()
    }
    
    static func carPopup() -> ViewModelType {
        return CarPopupViewModel()
    }
}
