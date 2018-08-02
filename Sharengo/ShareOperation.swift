//
//  ShareOperation.swift
//  Sharengo
//
//  Created by Sharengo on 31/07/2018.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation

class ShareOperation: Hashable, Equatable
{
    var hashValue: Int {
        return id.hashValue
    }
    
    static func == (lhs: ShareOperation, rhs: ShareOperation) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum State {
        case waiting
        case running
        case cancelled
    }
    
    typealias ShareOperationHandler = (_ success: Bool)->()
    typealias ShareOperationExecution = (_ operation: ShareOperation, _ handler: @escaping ShareOperationHandler)->()
    
    let id: String
    var state: State = .waiting
    let interval: TimeInterval
    var timer: Timer? = nil
    let operation: ShareOperationExecution
    var userInfo: [AnyHashable: Any] = [:]
    
    init(interval: TimeInterval, operation: @escaping ShareOperationExecution)
    {
        self.id = UUID().uuidString
        self.interval = interval
        self.operation = operation
    }
}
