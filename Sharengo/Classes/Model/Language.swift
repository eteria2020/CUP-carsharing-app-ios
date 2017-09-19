//
//  Language.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift

/**
 The Language  model is used to represent language used in the app.
 */
public class Language: ModelType {
    /// Title
    var title: String = ""
    /// Action
    var action: SettingsLanguageSelectionOutput = SettingsLanguageSelectionOutput.empty
    /// Boolean used to determine which language is used from User
    var selected = false
    
    // MARK: - Init methods
    
    public init(title: String, action: SettingsLanguageSelectionOutput, selected: Bool) {
        self.title = title
        self.action = action
        self.selected = selected
    }
}
