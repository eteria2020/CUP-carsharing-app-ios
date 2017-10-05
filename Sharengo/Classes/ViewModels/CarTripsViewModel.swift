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

/**
 Enum that specifies selection input
 */
public enum CarTripSelectionInput : SelectionInput {
    case item(IndexPath)
    case empty
}

/**
 Enum that specifies selection output
 */
public enum CarTripSelectionOutput : SelectionOutput {
    case reload
    case empty
}

/**
 The Car Trips viewmodel provides data related to display content on CarTripsVC
 */
public class CarTripsViewModel : ListViewModelType, ViewModelTypeSelectable {
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    var carTrips = [CarTrip]()
    var previousSelectedCarTrip: CarTrip?
    fileprivate var resultsDispose: DisposeBag?
    var idSelected: Int = -1
    
    /// Selection variable
    lazy public var selection:Action<CarTripSelectionInput,CarTripSelectionOutput> = Action { input in
        return .empty()
    }
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? CarTrip {
            return ViewModelFactory.carTripItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public required init() {
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  CarTrip else { return .empty() }
//                if self.previousSelectedCarTrip?.id != model.id {
//                    model.selected = true
//                    self.previousSelectedCarTrip?.selected = false
//                    self.previousSelectedCarTrip = model
//                } else {
//                    model.selected = !model.selected
//                }
                if model.id != self.idSelected {
                    self.idSelected = model.id ?? -1
                } else {
                    self.idSelected = -1
                }
                return .just(.reload)
            default:
                return .just(.empty)
            }
        }
    }
    
    /**
     This method updates car trips
     */
    func updateData(carTrips: [CarTrip]) {
        self.carTrips = carTrips
        self.dataHolder = ListDataHolder(data:Observable.just(carTrips).structured())
    }
}
