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

enum SearchCarSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum SearchCarSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
}

final class SearchCarsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    /*
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? Car else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    */
    
    lazy var selection:Action<SearchCarSelectionInput,SearchCarSelectionOutput> = Action { input in
        /*
        switch input {
        case .item(let indexPath):
            guard let model = (self.model(atIndex:indexPath) as? SearchCar) else {
                return .empty()
            }
            let destinationViewModel = __proper_factory_method_here__
            return .just(.viewModel(destinationViewModel))
        }
        */
        return .empty()
    }
    
    init() {
    }
}
