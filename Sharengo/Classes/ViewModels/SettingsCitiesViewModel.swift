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
    case milano
    case roma
    case firenze
    case modena
    case empty
}

final class SettingsCitiesViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var cities = [City]()
    var title = ""
    fileprivate var resultsDispose: DisposeBag?
    
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
                guard let model = self.model(atIndex: indexPath) as?  City else { return .empty() }
                return .just(model.action)
            }
        }
    }
    
    func updateData()
    {
        cities.removeAll()
        var cityMilano: Bool = false
        var cityRoma: Bool = false
        var cityFirenze: Bool = false
        var cityModena: Bool = false
        
        if UserDefaults.standard.object(forKey: "city") as? String == "milano"
        {
            cityMilano = true
        }
        else if UserDefaults.standard.object(forKey: "city") as? String == "roma"
        {
            cityRoma = true
        }
        else if UserDefaults.standard.object(forKey: "city") as? String == "firenze"
        {
            cityFirenze = true
        }
        else if UserDefaults.standard.object(forKey: "city") as? String == "modena"
        {
            cityModena = true
        }
        
        let cityItem1 = City(title: "city_milano".localized(), icon: "ic_compass", action: .milano, selected: cityMilano)
        let cityItem2 = City(title: "city_roma".localized(), icon: "ic_compass", action: .roma, selected: cityRoma)
        let cityItem3 = City(title: "city_firenze".localized(), icon: "ic_compass", action: .firenze, selected: cityFirenze)
        let cityItem4 = City(title: "city_modena".localized(), icon: "ic_compass", action: .modena, selected: cityModena)
        
        cities.append(cityItem1)
        cities.append(cityItem2)
        cities.append(cityItem3)
        cities.append(cityItem4)
        
        self.dataHolder = ListDataHolder(data:Observable.just(cities).structured())
    }
}
