//
//  SettingsLanguagesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

enum SettingsLanguageSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum SettingsLanguageSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

final class SettingsLanguagesViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var languages = [Language]()
    var title = ""
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<SettingsLanguageSelectionInput,SettingsLanguageSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Language {
            return ViewModelFactory.settingsLanguagesItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.title = "lbl_settingsLanguagesHeaderTitle".localized()
        
        let languageItem1 = Language(title: "language_italian")
        let languageItem2 = Language(title: "language_english")
        languages.append(languageItem1)
        languages.append(languageItem2)
        
        self.dataHolder = ListDataHolder(data:Observable.just(languages).structured())
        
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Setting else { return .empty() }
                if let viewModel = model.viewModel  {
                    switch viewModel {
                    case is HomeViewModel:
                        return .just(.viewModel(viewModel))
                    default:
                        return .just(.viewModel(viewModel))
                    }
                }
                return .just(.empty)
            }
        }
    }
}
