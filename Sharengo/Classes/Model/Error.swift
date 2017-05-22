//
//  Error.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation

enum ErrorType : Swift.Error {
    
    case connectionError
    case unknown
    
    var title: String {
        return "Errore"
    }
    
    // TODO: ???
    var message: String {
        switch self {
        case .connectionError:
            return "Impossibile connettersi al server"
        case .unknown:
            return "Errore imprevisto"
        }
    }
    
}
