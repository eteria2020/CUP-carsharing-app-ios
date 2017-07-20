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

enum NoFeedsSelectionInput: SelectionInput {
    case empty
}

enum NoFeedsSelectionOutput: SelectionOutput {
    case empty
}

final class NoFeedsViewModel: ViewModelType {
    lazy var selection:Action<NoFeedsSelectionInput,NoFeedsSelectionOutput> = Action { input in
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
