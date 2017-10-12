//
//  FaqViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

/**
 Enum that specifies selection input
 */
public enum FaqInput: SelectionInput {
    case tutorial
}

/**
 Enum that specifies selection output
 */
public enum FaqOutput: SelectionInput {
    case tutorial
}

/**
 The FaqViewModel provides data related to display content on faqs
 */
public class FaqViewModel: ViewModelTypeSelectable {
    /// Selection variable
    public var selection: Action<FaqInput, FaqOutput> = Action { input in
            switch input {
            case .tutorial:
                return .just(.tutorial)
             }
    }
    /// Url request created with page url
    public var urlRequest:URLRequest?
    
    // MARK: - Utilities methods
    
    public required init()
    {
        let url = URL(string: "http://support.sharengo.it/home")
        self.urlRequest = URLRequest(url: url!)
    }    
}
