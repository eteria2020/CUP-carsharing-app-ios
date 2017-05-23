//
//  HomeViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum HomeSelectionInput : SelectionInput {
    case searchCars
}
enum HomeSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
}

final class HomeViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    /*
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? Car else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    */
    
    lazy var selection:Action<HomeSelectionInput,SearchBarSelectionOutput> = Action { input in
        switch input {
        case .searchCars:
            return .just(.viewModel(ViewModelFactory.searchCars()))
        }
    }
    
    init() {
    }
}
