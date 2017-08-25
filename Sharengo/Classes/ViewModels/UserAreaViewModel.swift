//
//  UserAreaViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Action
import Boomerang

public enum UserAreaInput: SelectionInput {
    case tutorial
}

public enum UserAreaOutput: SelectionInput {
    case tutorial
}

final class UserAreaViewModel: ViewModelTypeSelectable {
    public var selection: Action<UserAreaInput, UserAreaOutput> = Action { input in
            switch input {
            case .tutorial:
                return .just(.tutorial)
             }
    }
    
    var urlRequest:URLRequest?
    
    init()
    {
        let url = URL(string: "https://www.sharengo.it/area-utente/mobile")
        self.urlRequest = URLRequest(url: url!)
    }    
}
