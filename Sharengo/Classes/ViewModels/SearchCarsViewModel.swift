//
//  SearchCarsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum SearchCarSelectionInput: SelectionInput {
    case item(IndexPath)
}
enum SearchCarSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class SearchCarsViewModel: ViewModelTypeSelectable {
    var cars: [Car] = []
    
    lazy var selection:Action<SearchCarSelectionInput,SearchCarSelectionOutput> = Action { input in
        return .empty()
    }
    
    init() {
    }
}
