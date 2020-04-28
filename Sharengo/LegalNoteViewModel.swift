//
//  LegalNoteModel.swift
//  Sharengo
//
//  Created by sharengo on 09/05/18.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation
import RxSwift
import Action


public enum LegalNoteInput: SelectionInput {
}

public enum LegalNoteOutput: SelectionInput {
    case empty
}

final class  LegalNoteViewModel: ViewModelTypeSelectable {
    public var selection: Action<LegalNoteInput, LegalNoteOutput> = Action { input in
        return .just(.empty)
    }
    
    var urlRequest:URLRequest?
        
    init()
    {
        let url = URL(string: Config().legalNote_EndPoit)
        self.urlRequest = URLRequest(url: url!)
    }
    
}
