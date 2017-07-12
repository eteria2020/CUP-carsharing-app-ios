//
//  FeedsViewModel.swift
//  Sharengo
//
//  Created by Fabrizio Infante on 12/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum FeedSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum FeedSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
}

final class FeedsViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        guard let item = model as? Feed else {
            return nil
        }
        return ViewModelFactory.__proper_factory_method_here()
    }
    
    lazy var selection:Action<FeedSelectionInput,FeedSelectionOutput> = Action { input in
        switch input {
        case .item(let indexPath):
            guard let model = (self.model(atIndex:indexPath) as? Feed) else {
                return .empty()
            }
            let destinationViewModel = __proper_factory_method_here__
            return .just(.viewModel(destinationViewModel))
        }
    }
    
    
    init() {
        
    }
}
