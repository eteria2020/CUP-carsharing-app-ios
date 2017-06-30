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
    case item(IndexPath)
}
enum CarTripSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
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
        self.title = "lbl_settingsHeaderTitle".localized()
        
        
        self.dataHolder = ListDataHolder(data:Observable.just(carTrips).structured())
        
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  CarTrip else { return .empty() }
                if let viewModel = model.viewModel  {
                    return .just(.viewModel(viewModel))
                }
                return .just(.empty)
            }
        }
    }
}
