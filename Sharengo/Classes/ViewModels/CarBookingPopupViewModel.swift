//
//  CarBookingPopupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action
import KeychainSwift
import DeviceKit

public enum CarBookingPopupInput: SelectionInput {
    case open
    case delete
    case close
}

public enum CarBookingPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case delete
    case close(Car)
}

final class CarBookingPopupViewModel: ViewModelTypeSelectable
{
    var carBooking: CarBooking?
    var carTrip: CarTrip?
    var pin: String = ""
    var time: Variable<String> = Variable("")
    var hideButtons: Bool = false
    var info: Variable<String?> = Variable(nil)
    var timeTimer: Timer?
    var carBookingPopupView: CarBookingPopupView?
    var secondi: Int?
    var isCarClosing: Variable<Bool> = Variable(false)
    
    public var selection: Action<CarBookingPopupInput, CarBookingPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init()
    {
        self.selection = Action { input in
            switch input
            {
            case .open:
                if let car = self.carBooking?.car.value
                {
                    return .just(.open(car))
                }
                else if let car = self.carTrip?.car.value
                {
                    return .just(.open(car))
                }
                
            case .delete:
                return .just(.delete)
                
            case .close:
                if let car = self.carTrip?.car.value
                {
                    return .just(.close(car))
                }
            }
            return .just(.empty)
        }
        
        self.timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    func updateWithCarBooking(carBooking: CarBooking)
    {
        self.carBooking = carBooking
        self.updateData()
        
        if let car = self.carBooking?.car.value
        {
            if let location = car.location
            {
                let key = "address-\(location.coordinate.latitude)-\(location.coordinate.longitude)"
                if let address = UserDefaults.standard.object(forKey: key) as? String {
                    self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
                }
                else
                {
                    self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
                    car.getAddress()
                    car.address.asObservable()
                        .subscribe(onNext: {[weak self] (address) in
                            DispatchQueue.main.async {
                                if address != nil {
                                    self?.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address!)
                                    UserDefaults.standard.set(address!, forKey: key)
                                }
                            }
                        }).disposed(by: disposeBag)
                }
            }
            
            if car.opened
            {
                self.hideButtons = true
            }
        }
    }
    
    func updateWithCarTrip(carTrip: CarTrip)
    {
        self.carTrip = carTrip
        self.updateData()
        
        if let car = self.carTrip?.car.value
        {
            self.info.value = String(format: "lbl_carBookingPopupInfoPlaceholder".localized(), car.plate ?? "")
            if self.carTrip != nil
            {
                if self.carTrip?.car.value?.parking == true
                {
                    self.info.value = String(format: "lbl_carTripParkingPopupInfo".localized(), car.plate ?? "")
                }
//                else
//                {
////                    self.info.value = String(format: "lbl_carTripPopupInfo".localized(), car.plate ?? "")
//                }
            }
//            else if let address = car.address.value
//            {
//                self.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address)
//            }
//            else
//            {
//                car.getAddress()
//                car.address.asObservable()
//                    .subscribe(onNext: {[weak self] (address) in
//                        DispatchQueue.main.async {
//                            if address != nil {
//                                self?.info.value = String(format: "lbl_carBookingPopupInfo".localized(), car.plate ?? "", address!)
//                            }
//                        }
//                    }).addDisposableTo(disposeBag)
//            }
            
            if car.opened {
                self.hideButtons = true
            }
        }
    }
    
    func updateData()
    {
        if let pin = KeychainSwift().get("UserPin")
        {
            self.pin = String(format: "lbl_carBookingPopupPin".localized(), pin)
        }
        else
        {
            self.pin = ""
        }
        
        self.info.value = ""
        self.hideButtons = false
        self.updateTime()
    }
    
    @objc fileprivate func updateTime()
    {
        self.time.value = ""
        
        if self.carBooking != nil
        {
            setConstraintOnDevice(normal: true)
            if self.carBookingPopupView?.alpha ?? 0.0 > 0.0
            {
                if let timer = self.carBooking?.timer
                {
                    self.time.value = String(format: "lbl_carBookingPopupTime".localized(), timer)
                }
            }
        }
        else if self.carTrip != nil
        {
            if self.carBookingPopupView?.alpha ?? 0.0 > 0.0
            {
                if let timer = self.carTrip?.timer
                {
                    self.time.value = timer
                }
                setConstraintOnDevice(normal: true)
                if let minuti = self.carTrip?.minutes
                {
                    if minuti > 4
                    {
                        setConstraintOnDevice(normal: true)
                        
                        if( self.carTrip?.car.value?.parking == true){
                            self.info.value = String(format: "lbl_carTripParkingPopupInfo".localized(), self.carTrip?.car.value?.plate ?? "")
                            setConstraintOnDevice(normal: true)
                        }else
                        {
                        self.info.value = String(format: "lbl_carTripPopupInfo".localized(), self.carTrip?.car.value?.plate ?? "")
                        setConstraintOnDevice(normal: true)
                        }
                    }
                    else
                    {
                        setConstraintOnDevice(normal: false)
                        
                        if( self.carTrip?.car.value?.parking == true){
                            self.info.value = String(format: "lbl_carTripParkingPopupInfo".localized(), self.carTrip?.car.value?.plate ?? "")
                            setConstraintOnDevice(normal: true)
                        }else
                        {
                            self.info.value = String(format: "lbl_carTripPopupInfo5min".localized(), self.carTrip?.car.value?.plate ?? "")
                            setConstraintOnDevice(normal: false)
                        }
                    }
                }
            }
        }
        
    }
    
    func setConstraintOnDevice(normal : Bool){
        
        if normal {
            
            switch Device.current.diagonal
            {
            case 3.5:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 180
            case 4:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 200
            case 4.7:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 210
            case 5.5:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
            case 5.8:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
            default:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
            }
        }
        else{
            switch Device.current.diagonal
            {
            case 3.5:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 180
            case 4:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 260
            case 4.7:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 295
            case 5.5:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 295
            case 5.8:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 295
            default:
                self.carBookingPopupView?.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 295
            }
            
        }
        
    }
}
