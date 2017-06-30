//
//  CarTripItemViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class CarTripItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier = CollectionViewCell.carTrip
    var identifier: String?
    var time: String?
    var startDateAndTime: String?
    var startAddress: String?
    var endDateAndTime: String?
    var endAddress: String?
    var minuteRate: String?
    var freeMinutes: String?
    var traveledKilometers: String?
    var plate: String?

    init(model: CarTrip) {
        self.model = model
        self.identifier = model.carPlate
        self.time = model.carPlate
        self.startDateAndTime = model.carPlate
        self.startAddress = model.carPlate
        self.endDateAndTime = model.carPlate
        self.endAddress = model.carPlate
        self.minuteRate = model.carPlate
        self.freeMinutes = model.carPlate
        self.traveledKilometers = model.carPlate
        self.plate = model.carPlate
    }
}
