//
//  Language.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

public class Language: ModelType {
    var title: String = ""
    var action: SettingsLanguageSelectionOutput = SettingsLanguageSelectionOutput.empty
    var selected = false
    
    init(title: String, action: SettingsLanguageSelectionOutput, selected: Bool) {
        self.title = title
        self.action = action
        self.selected = selected
    }
}
