//
//  NoFeedsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 16/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

/**
 Enum that specifies selection input
 */
public enum NoFeedsSelectionInput: SelectionInput {
    case empty
}

/**
 Enum that specifies selection output
 */
public enum NoFeedsSelectionOutput: SelectionOutput {
    case empty
}

/**
 The No Feeds viewmodel provides data related to display content on NoFeedsVC
 */
public class NoFeedsViewModel: ViewModelType {
    /// Selection variable
    lazy public var selection:Action<NoFeedsSelectionInput,NoFeedsSelectionOutput> = Action { input in
        switch input {
        default:
            return .just(.empty)
        }
    }
    var category: Category? = nil
    var categoryTitle: String?
    var sectionSelected = FeedSections.feed
    
    init(category: Category?) {
        self.category = category
        self.categoryTitle = category?.title
    }
}
