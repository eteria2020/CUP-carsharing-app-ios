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
    case english
    case italian
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
        self.updateData()
        
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Language else { return .empty() }
                return .just(model.action)
            }
        }
    }
    
    func updateData()
    {
        self.title = "lbl_settingsLanguagesHeaderTitle".localized()
        languages.removeAll()
        var italian: Bool = false
        var english: Bool = false
        
        if UserDefaults.standard.object(forKey: "language") as? String == "it"
        {
            italian = true
        }
        else if UserDefaults.standard.object(forKey: "language") as? String == "en"
        {
            english = true
        }
        
        let languageItem1 = Language(title: "language_italian", action: .italian, selected: italian)
        let languageItem2 = Language(title: "language_english", action: .english, selected: english)
        languages.append(languageItem1)
        languages.append(languageItem2)
        
        self.dataHolder = ListDataHolder(data:Observable.just(languages).structured())
    }
}
