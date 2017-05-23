//
//  SearchBarViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum SearchBarSelectionInput: SelectionInput {
    case item(IndexPath)
}
enum SearchBarSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class SearchBarViewModel: ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
   
    lazy var selection:Action<SearchBarSelectionInput,SearchBarSelectionOutput> = Action { input in
        return .empty()
    }
    
    init() {
    }
}
