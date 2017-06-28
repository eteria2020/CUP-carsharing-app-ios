//
//  NewFavouriteViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum NewFavouriteSelectionInput: SelectionInput {
    case empty
}

enum NewFavouriteSelectionOutput: SelectionOutput {
    case empty
}

final class NewFavouriteViewModel: ViewModelType {
    lazy var selection:Action<NewFavouriteSelectionInput,NewFavouriteSelectionOutput> = Action { input in
        return .just(.empty)
    }
    
    init() {
        
    }
}
