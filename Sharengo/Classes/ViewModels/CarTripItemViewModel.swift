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
import KeychainSwift

/**
 The Car Trip viewmodel provides data related to display content on car trip collection view cell
 */
public class CarTripItemViewModel : ItemViewModelType {
    public var model:ItemViewModelType.Model
    public var itemIdentifier:ListIdentifier = CollectionViewCell.carTrip

    init(model: CarTrip) {
        self.model = model
    }
}
