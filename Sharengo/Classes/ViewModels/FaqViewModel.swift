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

public enum FaqInput: SelectionInput {
    case empty
}

public enum FaqOutput: SelectionInput {
    case empty
}

final class FaqViewModel: ViewModelTypeSelectable {
    public var selection: Action<FaqInput, FaqOutput> = Action { _ in
        return .just(.empty)
    }
    
    var urlRequest:URLRequest?
    
    init()
    {
        let url = URL(string: "http://support.sharengo.it/home")
        self.urlRequest = URLRequest(url: url!)
    }    
}
