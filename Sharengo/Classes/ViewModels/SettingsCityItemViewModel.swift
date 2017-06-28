//
//  CityItemViewModel.swift
//  Sharengo
//
//  Created by Fabrizio Infante on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang

final class CityItemViewModel : ItemViewModelType {
    var model:ItemViewModelType.Model
    var itemIdentifier:ListIdentifier
    
    init(model: City) {
        self.model = model
    }
}
