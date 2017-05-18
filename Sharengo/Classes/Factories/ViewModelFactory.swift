import Foundation
import RxCocoa
import RxSwift
import Action
import Boomerang

typealias Selection = Action<SelectionInput,SelectionOutput>

struct ViewModelFactory {
    static func searchCars() -> ViewModelType {
        return SearchCarsViewModel()
    }
}
