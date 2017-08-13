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
import KeychainSwift

class CoreController {
    static let shared = CoreController()
    var currentViewController: UIViewController?
    let apiController: ApiController = ApiController()
    let publishersApiController: PublishersAPIController = PublishersAPIController()
    let sharengoApiController: SharengoApiController = SharengoApiController()
    var updateTimer: Timer?
    var updateInProgress = false
    var allCarBookings: [CarBooking] = []
    var allCarTrips: [CarTrip] = []
    var currentCarBooking: CarBooking?
    var currentCarTrip: CarTrip?
    var notificationIsShowed: Bool = false
    var cities: [City] = []
    var polygons: [Polygon] = []

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
    
    private init() {
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60*1, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
    }
    
    @objc func updateData() {
        self.updateCities()
        self.updatePolygons()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        self.notificationIsShowed = false
        self.updateInProgress = true
        self.updateUser()
    }
    
    fileprivate func updatePolygons() {
        self.sharengoApiController.getPolygons()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let polygons):
                    self.polygons = polygons
                    var cache: [PolygonCache] = [PolygonCache]()
                    for polygon in self.polygons {
                        cache.append(polygon.getPolygonCache())
                    }
                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: cache as Array)
                    UserDefaults.standard.set(archivedArray, forKey: "cachePolygons")
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }

    fileprivate func updateCities() {
        self.publishersApiController.getCities()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status_bool == true, let data = response.array_data {
                        if let cities = [City].from(jsonArray: data) {
                            self.cities = cities
                            var cache: [CityCache] = [CityCache]()
                            for city in self.cities {
                                cache.append(city.getCityCache())
                            }
                            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: cache as Array)
                            UserDefaults.standard.set(archivedArray, forKey: "cacheCities")
                        }
                    }
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func updateUser() {
        if let username = KeychainSwift().get("Username"), let password = KeychainSwift().get("Password") {
        self.apiController.getUser(username: username, password: password)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        if let pin = data["pin"] {
                            KeychainSwift().set("\(String(describing: pin))", forKey: "UserPin")
                        }
                        if let firstname = data["name"] {
                            KeychainSwift().set("\(String(describing: firstname))", forKey: "UserFirstname")
                        }
                        self.updateCarBookings()
                    }
                    else if response.status == 404, let code = response.code {
                        if code == "not_found" {
                            // TODO: logout
                        }
                    }
                    else if let msg = response.msg {
                        if msg == "invalid_credentials" {
                            // TODO: logout
                        } else if msg == "user_disabled" {
                            // TODO: logout
                        }
                    }
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
        }
    }
    
    fileprivate func updateCarBookings() {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
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
                            self.updateCarTrips()
                            return
                        }
                    }
                    self.allCarBookings = []
                    self.updateCarTrips()
                case .error(_):
                    self.allCarBookings = []
                    self.updateCarTrips()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func updateCarTrips() {
        if  KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        self.apiController.tripsList()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let carTrips = [CarTrip].from(jsonArray: data) {
                            self.allCarTrips = carTrips
                            self.stopUpdateData()
                            return
                        }
                    }
                    self.allCarTrips = []
                    self.stopUpdateData()
                case .error(_):
                    self.allCarTrips = []
                    self.stopUpdateData()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func stopUpdateData() {
        self.updateInProgress = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
        self.currentCarBooking = self.allCarBookings.first
        self.currentCarTrip = self.allCarTrips.first
    }
}
