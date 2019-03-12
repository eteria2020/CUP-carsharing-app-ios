//
//  NoCarTripsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action

enum NoCarTripsSelectionInput: SelectionInput {
    case empty
}

enum NoCarTripsSelectionOutput: SelectionOutput {
    case empty
}

final class NoCarTripsViewModel: ViewModelType {
    lazy var selection:Action<NoFavouritesSelectionInput,NoFavouritesSelectionOutput> = Action { input in
        switch input {
        default:
            return .just(.empty)
        }
    }

    init() {

    }
}
