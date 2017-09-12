//
//  SettingsCitiesViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum SettingsCitySelectionInput : SelectionInput {
    case item(IndexPath)
}

/**
 Enum that specifies selection output
 */
public enum SettingsCitySelectionOutput : SelectionOutput {
    case model(City)
    case empty
}

/**
 The Setting city model provides data related to display content on settings
 */
public final class SettingsCitiesViewModel : ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// Variable used to save title
    public var title = ""
    /// Variable used to save next screen that has to be opened after login
    public var nextViewModel: ViewModelType?
    /// Selection variable
    public lazy var selection:Action<SettingsCitySelectionInput,SettingsCitySelectionOutput> = Action { input in
        return .empty()
    }
    
    // MARK: - ViewModel methods
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? City {
            return ViewModelFactory.settingsCitiesItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public init() {
        self.title = "lbl_settingsCitiesHeaderTitle".localized()
        self.updateData()
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as? City else { return .empty() }
                return .just(.model(model))
            }
        }
    }
    
    // MARK: - Update methods
    
    /**
     This method updates settings cities options
     */
    public func updateData()
    {
        var cityid = "0"
        if var dictionary = UserDefaults.standard.object(forKey: "cityDic") as? [String: String] {
            if let username = KeychainSwift().get("Username") {
                cityid = dictionary[username] ?? "0"
            }
        }
        let cities = CoreController.shared.cities
        for city in cities {
            if city.identifier == cityid {
                city.selected = true
            } else {
                city.selected = false
            }
        }
        
        self.dataHolder = ListDataHolder(data:Observable.just(cities).structured())
    }
}
