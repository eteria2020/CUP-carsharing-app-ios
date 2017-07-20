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

enum SettingsCitySelectionInput : SelectionInput {
    case item(IndexPath)
}
enum SettingsCitySelectionOutput : SelectionOutput {
    case model(City)
    case empty
}

final class SettingsCitiesViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var title = ""
    fileprivate var resultsDispose: DisposeBag?
    var nextViewModel: ViewModelType?
    
    lazy var selection:Action<SettingsCitySelectionInput,SettingsCitySelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? City {
            return ViewModelFactory.settingsCitiesItem(fromModel: item)
        }
        return nil
    }
    
    init() {
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
    
    func updateData()
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
