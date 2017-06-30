//
//  CarTripsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum CarTripSelectionInput : SelectionInput {
    case empty
}
enum CarTripSelectionOutput : SelectionOutput {
    case empty
}

final class CarTripsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var carTrips = [CarTrip]()
    var title = ""
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<CarTripSelectionInput,CarTripSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? CarTrip {
            return ViewModelFactory.carTripItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.title = "lbl_carTripsHeaderTitle".localized()
        
        self.carTrips = CoreController.shared.allCarTrips
        self.dataHolder = ListDataHolder(data:Observable.just(carTrips).structured())
        
        self.selection = Action { input in
            return .just(.empty)
        }
    }
}
