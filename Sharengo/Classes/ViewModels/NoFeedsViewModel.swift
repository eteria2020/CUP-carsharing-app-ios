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
 The NoFeedsViewModel provides data related to display content on no feeds screen
 */
public class NoFeedsViewModel: ViewModelType {
    /// Selection variable
    lazy public var selection:Action<NoFeedsSelectionInput,NoFeedsSelectionOutput> = Action { input in
        switch input {
        default:
            return .just(.empty)
        }
    }
    /// Variable used to save category
    public var category: Category? = nil
    /// Variable used to save category title
    public var categoryTitle: String?
    /// Variable used to save if section is feeds or categories
    public var sectionSelected = FeedSections.feed
    
    // MARK: Init methods
    
    public init(category: Category?) {
        self.category = category
        self.categoryTitle = category?.title
    }
}
