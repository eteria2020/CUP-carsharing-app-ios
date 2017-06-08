//
//  CoreController.swift
//  Sharengo
//
//  Created by Dedecube on 08/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Boomerang

class CoreController
{
    private init() {
        self.bookingsTimer = Timer.scheduledTimer(timeInterval: 60*1, target: self, selector: #selector(self.updateBookings), userInfo: nil, repeats: true)
    }
    static let shared = CoreController()
    var allCarBookings: [CarBooking] = []
    var apiController: ApiController = ApiController()
    var bookingsTimer: Timer?
    
    private struct AssociatedKeys {
        static var disposeBag = "vc_disposeBag"
    }
   
    public var disposeBag: DisposeBag {
        var disposeBag: DisposeBag
        if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
            disposeBag = lookup
        } else {
            disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return disposeBag
    }
    
    @objc func updateBookings() {
        self.apiController.bookingList()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let carBookings = [CarBooking].from(jsonArray: data) {
                            self.allCarBookings = carBookings.filter({ (carBooking) -> Bool in
                                return carBooking.isActive == true
                            })
                        }
                    }
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
}
