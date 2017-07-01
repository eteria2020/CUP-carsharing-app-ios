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
    var title: String?
    var subtitle: String?
    var description: String?

    init(model: CarTrip) {
        self.model = model
        let selected = model.selected

        self.title = String(format: "lbl_carTripsItemTitle".localized(), model.carPlate!)
        self.subtitle = String(format: "lbl_carTripsItemSubtitle".localized(), model.carPlate!)
        if selected
        {
            self.description = String(format: "lbl_carTripsItemTitle".localized(), model.carPlate!)
        }
        else
        {
            self.description = String(format: "lbl_carTripsItemSubtitle".localized(), model.carPlate!)
        }
    }
}
