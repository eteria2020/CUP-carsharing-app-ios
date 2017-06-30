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
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? CarTrip else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    
    lazy var selection:Action<CarTripSelectionInput,CarTripSelectionOutput> = Action { input in
        switch input {
        case .item(let indexPath):
            guard let model = (self.model(atIndex:indexPath) as? CarTrip) else {
                return .empty()
            }
            let destinationViewModel = __proper_factory_method_here__
            return .just(.viewModel(destinationViewModel))
        }
    }
    
    
    init() {
        
    }
}
