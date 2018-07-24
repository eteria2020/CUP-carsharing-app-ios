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
 The Language model is used to represent language used in settings section
 */
public class Language: ModelType {
    /// Language name
    public var title: String = ""
    /// Language action
    public var action: SettingsLanguageSelectionOutput = SettingsLanguageSelectionOutput.empty
    /// Boolean used to determine which language is selected from user
    public var selected = false
    
    // MARK: - Init methods
    
    public init(title: String, action: SettingsLanguageSelectionOutput, selected: Bool) {
        self.title = title
        self.action = action
        self.selected = selected
    }
}
