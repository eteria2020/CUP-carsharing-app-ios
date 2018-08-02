//
//  CoreController+Operations.swift
//  Sharengo
//
//  Created by Sharengo on 31/07/2018.
//  Copyright © 2018 CSGroup. All rights reserved.
//

import Foundation

extension CoreController
{
    static var CarPlateKey: String {
        return "CarPlateKey"
    }
    
    func startCheckCloseTripOperation(withCar car: Car)
    {
        stopCheckCloseTripOperation()
        
        guard let plate = car.plate else { return }
        
        debugPrint("CoreController: Start check close trip with plate: \(plate)")
        
        checkCloseTripOperation.userInfo = [CoreController.CarPlateKey: plate]
        ShareOperationController.shared.execute(checkCloseTripOperation)
    }
    
    func stopCheckCloseTripOperation()
    {
        debugPrint("CoreController: Stop check close trip")
        
        checkCloseTripOperation.userInfo = [:]
        ShareOperationController.shared.stop(checkCloseTripOperation)
    }
    
    func startCheckOpenTripOperation()
    {
        stopCheckOpenTripOperation()
        
        ShareOperationController.shared.execute(checkOpenTripOperation)
    }
    
    func stopCheckOpenTripOperation()
    {
        ShareOperationController.shared.stop(checkOpenTripOperation)
    }
}
