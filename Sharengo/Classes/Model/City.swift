//
//  City.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

public class City: ModelType {
    var title: String = ""
    var icon: String = ""
    var action: SettingsLanguageSelectionOutput = SettingsLanguageSelectionOutput.empty
    var selected = false
    
    init(title: String, icon: String, action: SettingsLanguageSelectionOutput, selected: Bool) {
        self.title = title
        self.icon = icon
        self.action = action
        self.selected = selected
    }
}
