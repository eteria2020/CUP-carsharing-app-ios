//
//  CarPopupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

public enum CarPopupInput: SelectionInput {
    case open
    case book
}

public enum CarPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case book(Car)
}

final class CarPopupViewModel: ViewModelTypeSelectable {
    fileprivate var car: Car?
    var type: Variable<String> = Variable("")
    var plate: String = ""
    var capacity: String = ""
    var distance: String = ""
    var walkingDistance: String = ""
    var address: Variable<String?> = Variable(nil)
    
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.car {
                    return .just(.open(car))
                }
            case .book:
                if let car = self.car {
                    return .just(.book(car))
                }
            }
            return .just(.empty)
        }
    }
    
    func updateWithCar(car: Car) {
        self.car = car
        self.type.value = car.type
        self.plate = String(format: "lbl_carPopupPlate".localized(), car.plate ?? "")
        self.capacity = String(format: "lbl_carPopupCapacity".localized(), car.capacity != nil ? "\(car.capacity!)%" : "")
        if let distance = car.distance {
            let restultDistance = getDistanceFromMeters(inputedMeters: Int(distance.rounded(.up)))
            if restultDistance.kilometers > 0 {
                self.distance = String(format: "lbl_carPopupDistance_km".localized(), restultDistance.kilometers)
            } else if restultDistance.meters > 0 {
                self.distance = String(format: "lbl_carPopupDistance_mt".localized(), restultDistance.meters)
            }
            let minutes: Float = Float(distance.rounded(.up)/100.0)
            let restultWalkingDistance = getTimeFromMinutes(inputedMinutes: Int(minutes.rounded(.up)))
            if restultWalkingDistance.hours > 0 {
                if restultWalkingDistance.minutes > 0 {
                    self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_h_m".localized(), restultWalkingDistance.hours, restultWalkingDistance.minutes < 10 ? "0\(restultWalkingDistance.minutes)" : "\(restultWalkingDistance.minutes)")
                } else {
                    self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_h".localized(), restultWalkingDistance.hours)
                }
            } else if restultWalkingDistance.minutes > 0 {
                self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_m".localized(), restultWalkingDistance.minutes)
            }
        }
        if let address = car.address.value {
            self.address.value = address
        } else {
            car.getAddress()
            car.address.asObservable()
                .subscribe(onNext: {[weak self] (address) in
                    DispatchQueue.main.async {
                        if address != nil {
                            self?.address.value = address
                        }
                    }
            }).addDisposableTo(disposeBag)
        }
    }
    
    // MARK: - Utility methods
    
    func getDistanceFromMeters(inputedMeters: Int) -> (kilometers: Float, meters: Int)
    {
        let kilometers = (Float(inputedMeters) / 1000)
        let meters = Float(inputedMeters).truncatingRemainder(dividingBy: 1000)
        
        return (Float(kilometers), Int(meters))
    }
    
    func getTimeFromMinutes(inputedMinutes: Int) -> (hours: Int, minutes: Int)
    {
        let hours = (Float(inputedMinutes) / 60).rounded(.towardZero)
        let minutes = Float(inputedMinutes).truncatingRemainder(dividingBy: 60)
        
        return (Int(hours), Int(minutes))
    }
}
