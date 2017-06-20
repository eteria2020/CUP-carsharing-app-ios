//
//  MenuViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum MenuSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum MenuSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
}

final class MenuViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var itemSelected: Bool = false
    
    fileprivate var resultsDispose: DisposeBag?
    var allCars: [Car] = []
    
    lazy var selection:Action<SearchBarSelectionInput,SearchBarSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Menu {
            return ViewModelFactory.menuItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                if let model = self.model(atIndex: indexPath) as? Address {
                    self.itemSelected = true
                    return .just(.address(model))
                } else if let model = self.model(atIndex: indexPath) as? Car {
                    self.itemSelected = true
                    return .just(.car(model))
                } else if let model = self.model(atIndex: indexPath) as? Favorite {
                    print(model)
                }
                
                return .just(.empty)
            default:
                return .just(.empty)
            }
            
        }
    }
}
