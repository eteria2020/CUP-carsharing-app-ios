//
//  ShareOperationController.swift
//  Sharengo
//
//  Created by Sharengo on 31/07/2018.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation

class ShareOperationController
{
    private static let OperationKey: String = "OperationKey"
    static let shared = ShareOperationController()
    
    private var operations: Set<ShareOperation> = []
    
    func execute(_ operation: ShareOperation)
    {
        DispatchQueue.main.async { [unowned self] in
            
            guard !self.operations.contains(operation) else {
                debugPrint("ShareOperationController: Error: Operation \(operation.id) is already managed!")
                return
            }
            
            self.operations.insert(operation)
            operation.timer = Timer.scheduledTimer(timeInterval: operation.interval, target: self, selector: #selector(ShareOperationController.timerDidFire(_:)), userInfo: [ShareOperationController.OperationKey: operation.id], repeats: true)
            operation.timer?.fire()
        }
    }
    
    func stop(_ operation: ShareOperation)
    {
        DispatchQueue.main.async { [unowned self] in
            guard self.operations.contains(operation) else { return }
            
            operation.timer?.invalidate()
            operation.timer = nil
            operation.state = .waiting
            self.operations.remove(operation)
            
            debugPrint("ShareOperationController: Stopped operation: \(operation.id)")
        }
    }
    
    func stopAll()
    {
        DispatchQueue.main.async { [unowned self] in
            self.operations.forEach { self.stop($0) }
        }
    }
    
    @objc public func timerDidFire(_ timer: Timer)
    {
        guard   let dictionary = timer.userInfo as? [String: Any],
                let id = dictionary[ShareOperationController.OperationKey] as? String,
                let operation = operations.filter({ $0.id == id }).first,
                operation.state != .running
                else { return }
        
        debugPrint("ShareOperationController: Started operation: \(operation.id)")
        
        operation.state = .running
        operation.operation(operation) { [unowned operation, unowned self] success in
            DispatchQueue.main.async { [unowned self] in
                self.evaluateOperationResult(operation, success: success)
            }
        }
    }
    
    private func evaluateOperationResult(_ operation: ShareOperation, success: Bool)
    {
        if !success
        {
            operation.state = .waiting
        }
        else
        {
            self.stop(operation)
        }
    }
}
