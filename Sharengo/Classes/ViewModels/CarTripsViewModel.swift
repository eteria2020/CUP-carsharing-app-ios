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
 The Car TripsViewModel provides data related to display content on car trips screen
 */
public class CarTripsViewModel : ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// Array of car trips
    public var carTrips = [CarTrip]()
    /// Id of selected car trip
    var idSelected: Int = -1
    /// Selection variable
    lazy public var selection:Action<CarTripSelectionInput,CarTripSelectionOutput> = Action { input in
        return .empty()
    }
    
    // MARK: - ViewModel methods
    
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
    
    // MARK: - Update methods
    
    /**
     This method updates car trips
     */
    func updateData(carTrips: [CarTrip]) {
        self.carTrips = carTrips
       /* var carTripsReduced : [CarTrip] = [CarTrip]()
        for i in 0...10{
            carTripsReduced.append(carTrips[i])
        }
        //var num: Int = carTripsReduced.count*/
        
        self.dataHolder = ListDataHolder(data:Observable.just(carTrips).structured())
    }
}
