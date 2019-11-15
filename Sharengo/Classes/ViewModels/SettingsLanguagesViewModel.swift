//
//  SettingsLanguagesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum SettingsLanguageSelectionInput : SelectionInput {
    case item(IndexPath)
}

/**
 Enum that specifies selection output
 */
public enum SettingsLanguageSelectionOutput : SelectionOutput {
    case english
    case italian
    case slovenian
    case slovack
    case dutch
    case empty
}

/**
 The Setting city model provides data related to display content on settings
 */
public final class SettingsLanguagesViewModel : ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// ViewModel variable used to save data
    var languages = [Language]()
    /// Variable used to save title
    public var title = ""
    /// Selection variable
    public lazy var selection:Action<SettingsLanguageSelectionInput,SettingsLanguageSelectionOutput> = Action { input in
        return .empty()
    }
    
    // MARK: - ViewModel methods
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Language {
            return ViewModelFactory.settingsLanguagesItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public init() {
        self.updateData()
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  Language else { return .empty() }
                return .just(model.action)
            }
        }
    }
    
    /**
     This method updates settings languages options
     */
    public func updateData() {
        self.title = "lbl_settingsLanguagesHeaderTitle".localized()
        languages.removeAll()
        var italian: Bool = false
        var english: Bool = false
        var slovenian: Bool = false
        var slovak: Bool = false
        var dutch: Bool = false
        var languageid = "0"
        if let dictionary = UserDefaults.standard.object(forKey: "languageDic") as? [String: String] {
            if let username = KeychainSwift().get("Username") {
                languageid = dictionary[username] ?? "0"
            }
        }
        if languageid == "it"
        {
            italian = true
        }
        else if languageid == "en"
        {
            english = true
        }
        else if languageid == "sl"
        {
            slovenian = true
        }
        else if languageid == "sk"
        {
            slovak = true
        }
        else if languageid == "nl"
        {
            dutch = true
        }
        let languageItem1 = Language(title: "language_italian", action: .italian, selected: italian)
        let languageItem2 = Language(title: "language_english", action: .english, selected: english)
        let languageItem3 = Language(title: "language_slovack", action: .slovack, selected: slovak)
        let languageItem4 = Language(title: "language_dutch", action: .dutch, selected: dutch)
        let languageItem5 = Language(title: "language_slovenian", action: .slovenian, selected: slovenian)
        if(Config().language == "it")
        {
            languages.append(languageItem1)
            languages.append(languageItem2)
        }
        else if(Config().language == "sl")
        {
            languages.append(languageItem5)
            languages.append(languageItem2)
        }
        else if(Config().language == "sk")
        {
            languages.append(languageItem3)
            languages.append(languageItem2)
        }
        else if(Config().language == "nl")
        {
            languages.append(languageItem4)
            languages.append(languageItem2)
        }
       
        self.dataHolder = ListDataHolder(data:Observable.just(languages).structured())
    }
}
