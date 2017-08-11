//
//  SearchCarsViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import MapKit
import Moya
import Gloss
import ReachabilitySwift
import GoogleMaps

enum SearchCarsType {
    case searchCars
    case feeds
    
    func getCircularMenuType() -> CircularMenuType {
        switch self {
        case .searchCars:
            return .searchCars
        case .feeds:
            return .feeds
        }
    }
}

final class SearchCarsViewModel: ViewModelType {
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var publishersApiController: PublishersAPIController = PublishersAPIController()
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var oldNearestCar: Car?
    fileprivate var timerCars: Timer?
    fileprivate var cars: [Car] = []
    var nearestCar: Car?
    var allCars: [Car] = []
    var carBooked: Car?
    var carBooking: CarBooking?
    var carTrip: CarTrip?
    let type: SearchCarsType
    var showCars: Bool = false
    var errorOffers: Bool?
    var errorEvents: Bool?
    var feeds = [Feed]()
    
    var array_annotations: Variable<[GMUClusterItem]> = Variable([])

    init(type: SearchCarsType) {
        self.type = type
        self.getAllCars()
        self.timerCars = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(self.getAllCars), userInfo: nil, repeats: true)
    }
    
    deinit {
        self.timerCars?.invalidate()
        self.timerCars = nil
    }
    
    // MARK: - Cars methods
    
    @objc func getAllCars() {
        self.apiController.searchCars()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let cars = [Car].from(jsonArray: data) {
                            self.allCars = cars.filter({ (car) -> Bool in
                                return car.status == .operative
                            })
                            // Distance
                            for car in self.allCars {
                                let locationController = LocationController.shared
                                if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
                                    if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                                        car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                                        let index = self.cars.index(where: { (singleCar) -> Bool in
                                            return car.plate == singleCar.plate
                                        })
                                        if let index = index {
                                            self.cars[index].distance = car.distance
                                        }
                                    }
                                }
                            }
                            self.manageAnnotations()
                            return
                        }
                    }
                    self.allCars.removeAll()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    func resetCars() {
        self.cars.removeAll()
        self.manageAnnotations()
    }
    
    func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    func reloadResults(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        self.errorEvents = nil
        self.errorOffers = nil
        if type == .searchCars || showCars == true {
            self.apiController.searchCars(latitude: latitude, longitude: longitude, radius: radius)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.array_data {
                            if let cars = [Car].from(jsonArray: data) {
                                self.cars = cars.filter({ (car) -> Bool in
                                    return car.status == .operative
                                })
                                self.manageAnnotations()
                                return
                            }
                        }
                        self.resetCars()
                    case .error(_):
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            var message = "alert_generalError".localized()
                            if Reachability()?.isReachable == false {
                                message = "alert_connectionError".localized()
                            }
                            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                            self.resetCars()
                        }
                    default:
                        break
                    }
                }.addDisposableTo(resultsDispose!)
        } else {
            self.resetCars()
        }
        self.feeds.removeAll()
        if type == .feeds {
            self.publishersApiController.getMapOffers(latitude: latitude, longitude: longitude, radius: radius)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status_bool == true, let data = response.array_data {
                            if let feeds = [Feed].from(jsonArray: data) {
                                self.feeds.append(contentsOf: feeds)
                                self.errorOffers = false
                                self.manageAnnotations()
                                return
                            }
                        }
                        self.errorOffers = false
                        self.manageAnnotations()
                        return
                    case .error(_):
                        self.errorOffers = true
                        self.manageAnnotations()
                    default:
                        break
                    }
                }.addDisposableTo(resultsDispose!)
            
            self.publishersApiController.getMapEvents(latitude: latitude, longitude: longitude, radius: radius)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status_bool == true, let data = response.array_data {
                            if let feeds = [Feed].from(jsonArray: data) {
                                self.feeds.append(contentsOf: feeds)
                                self.errorEvents = false
                                self.manageAnnotations()
                                return
                            }
                        }
                        self.errorEvents = false
                        self.manageAnnotations()
                        return
                    case .error(_):
                        self.errorEvents = true
                        self.manageAnnotations()
                    default:
                        break
                    }
                }.addDisposableTo(resultsDispose!)
        } else {
            self.manageAnnotations()
        }
    }
    
    func manageAnnotations() {
        var annotations: [GMUClusterItem] = []
        if type == .searchCars || showCars == true {
            var carBookedFounded: Bool = false
            if let car = self.carBooked {
                let locationController = LocationController.shared
                if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
                    if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                        car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                        let index = self.cars.index(where: { (singleCar) -> Bool in
                            return car.plate == singleCar.plate
                        })
                        if let index = index {
                            self.cars[index].distance = car.distance
                        }
                    }
                }
            }
            for car in self.cars {
                let locationController = LocationController.shared
                if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
                    if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                        car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                        let index = self.allCars.index(where: { (allCar) -> Bool in
                            return car.plate == allCar.plate
                        })
                        if let index = index {
                            self.allCars[index].distance = car.distance
                        }
                    }
                }
                if car.plate == self.carBooked?.plate {
                    carBookedFounded = true
                }
            }
            self.updateCarProperties()
            // TODO GOOGLE
            DispatchQueue.main.async {
                for car in self.cars {
                    if let coordinate = car.location?.coordinate {
                        let annotation = CarAnnotation(position: coordinate)
                       // annotation.icon = annotation.getImage()
                        annotation.car = car
                        annotations.append(annotation)
                    }
                }
                if carBookedFounded == false && self.carBooked != nil {
                    if let coordinate = self.carBooked!.location?.coordinate {
                        let annotation = CarAnnotation(position: coordinate)
                      //  annotation.icon = annotation.getImage()
                        annotation.car = self.carBooked!
                        annotations.append(annotation)
                    }
                }
                if self.type == .searchCars {
                    self.array_annotations.value = annotations
                }
            }
        }
        if type == .feeds {
            if self.errorEvents == false && self.errorOffers == false {
                DispatchQueue.main.async {
                    for feed in self.feeds {
                        if let coordinate = feed.feedLocation?.coordinate {
                            let annotation = FeedAnnotation(position: coordinate)
                            annotation.icon = annotation.getImage()
                            annotation.feed = feed
                        // TODO GOOGLE
                            //    annotations.append(annotation)
                        }
                    }
                    self.array_annotations.value = annotations
                }
            } else if self.errorEvents == true || self.errorOffers == true {
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    var message = "alert_generalError".localized()
                    if Reachability()?.isReachable == false {
                        message = "alert_connectionError".localized()
                    }
                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    self.array_annotations.value = annotations
                }
            }
        }
    }
    
    fileprivate func updateCarProperties () {
        self.nearestCar = nil
        for car in self.allCars {
            car.booked = false
            car.opened = false
            if let carBooked = self.carBooked {
                if car.plate == carBooked.plate {
                    car.booked = true
                    car.opened = carBooked.opened
                }
            }
            if self.nearestCar == nil {
                self.nearestCar = car
            } else if let nearestCar = nearestCar {
                if let nearestCarDistance = nearestCar.distance, let carDistance = car.distance {
                    if nearestCarDistance > carDistance {
                        self.nearestCar = car
                    }
                }
            }
            let index = self.cars.index(where: { (singleCar) -> Bool in
                return car.plate == singleCar.plate
            })
            if let index = index {
                self.cars[index] = car
            }
        }
        self.nearestCar?.nearest = true
    }
}
