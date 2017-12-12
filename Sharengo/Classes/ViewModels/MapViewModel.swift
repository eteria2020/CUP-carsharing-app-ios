//
//  MapViewModel.swift
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

/**
 Enum that specifies map type and features related to it. These are:
  - circular menu
*/
public enum MapType {
    case searchCars
    case feeds
    
    public func getCircularMenuType() -> CircularMenuType {
        switch self {
        case .searchCars:
            return .searchCars
        case .feeds:
            return .feeds
        }
    }
}

/**
 The Map model provides data related to display content on a map
*/
public final class MapViewModel: ViewModelType {
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var googleApiController: GoogleAPIController = GoogleAPIController()
    fileprivate var publishersApiController: PublishersAPIController = PublishersAPIController()
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var timerCars: Timer?
    /// Type of the map
    public let type: MapType
    /// Variable used to know if map has to show cars or not with map type feeds
    public var showCars: Bool = false
    /// Support variable to store error with offers for feeds
    public var errorOffers: Bool?
    /// Support variable to store error with events for feeds
    public var errorEvents: Bool?
    /// Variable used to save feeds
    public var feeds = [Feed]()
    /// Variable used to save cars
    public var cars: [Car] = []
    /// Variable used to save all cars in share'ngo system
    public var allCars: [Car] = []
    /// Variable used to save nearest car
    public var nearestCar: Variable<Car?> = Variable<Car?>(nil)
    /// Variable used to save car booked
    public var carBooked: Car?
    /// Variable used to save car booking
    public var carBooking: CarBooking?
    /// Variable used to save car trip
    public var carTrip: CarTrip?
    /// Array of annotations
    public var array_annotations: Variable<[GMUClusterItem]> = Variable([])
    
    // MARK: - Init methods
    
    public init(type: MapType) {
        self.type = type
        self.getAllCars()
        self.timerCars = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(self.getAllCars), userInfo: nil, repeats: true)
    }
    
    deinit {
        self.timerCars?.invalidate()
        self.timerCars = nil
    }
    
    // MARK: - Cars methods
    
    /**
     This method gets all cars in share'ngo system and updates distance
     */
    @objc public func getAllCars() {
        self.apiController.searchCars()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let cars = [Car].from(jsonArray: data) {
                            self.allCars = cars
                            // Distance
                            for car in self.allCars {
                                let locationManager = LocationManager.sharedInstance
                                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                                    if let userLocation = locationManager.lastLocationCopy.value {
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
    
    /**
     This method resets cars variable
     */
    public func resetCars() {
        self.cars.removeAll()
        self.manageAnnotations()
    }
    
    /**
     This method stops cars and feeds request
     */
    public func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    /**
     This method starts cars request
     - Parameter latitude: The latitude is one of the coordinate that determines the center of the map
     - Parameter longitude: The longitude is one of the coordinate that determines the center of the map
     - Parameter radius: The radius is the distance from the center of the map to the edge of the map
     */
    public func reloadResults(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        self.errorEvents = nil
        self.errorOffers = nil
        if type == .searchCars || showCars == true {
            var userLatitude: CLLocationDegrees = 0
            var userLongitude: CLLocationDegrees = 0
            let locationManager = LocationManager.sharedInstance
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                if let userLocation = locationManager.lastLocationCopy.value {
                    userLatitude = userLocation.coordinate.latitude
                    userLongitude = userLocation.coordinate.longitude
                }
            }
            self.apiController.searchCars(latitude: latitude, longitude: longitude, radius: radius, userLatitude: userLatitude, userLongitude: userLongitude)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.array_data {
                            if let cars = [Car].from(jsonArray: data) {
                                self.cars = cars
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
    
    /**
     This method updates distance and manages cars and feeds in array of annotations
     */
    public func manageAnnotations() {
        var annotations: [GMUClusterItem] = []
        if type == .searchCars || showCars == true {
            var carBookedFounded: Bool = false
            // Distance
            if let car = self.carBooked {
                let locationManager = LocationManager.sharedInstance
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    if let userLocation = locationManager.lastLocationCopy.value {
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
            }
            for car in self.cars {
                let locationManager = LocationManager.sharedInstance
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    if let userLocation = locationManager.lastLocationCopy.value {
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
                }
                if car.plate == self.carBooked?.plate {
                    carBookedFounded = true
                }
            }
            for car in self.allCars {
                let locationManager = LocationManager.sharedInstance
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    if let userLocation = locationManager.lastLocationCopy.value {
                        if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                            car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                            let index = self.cars.index(where: { (allCar) -> Bool in
                                return car.plate == allCar.plate
                            })
                            if let index = index {
                                self.cars[index].distance = car.distance
                            }
                        }
                    }
                }
            }
            self.updateCarsProperties()
            for car in self.cars {
                if let coordinate = car.location?.coordinate {
                    let annotation = CarAnnotation(position: coordinate, car: car, carBooked: self.carBooked, carTrip: self.carTrip)
                    annotations.append(annotation)
                }
            }
            if carBookedFounded == false && self.carBooked != nil && (self.carTrip == nil || self.carTrip?.car.value?.parking == true) {
                if let coordinate = self.carBooked!.location?.coordinate {
                    let annotation = CarAnnotation(position: coordinate, car: self.carBooked!, carBooked:  self.carBooked, carTrip: self.carTrip)
                    annotations.append(annotation)
                }
            }
            if self.type == .searchCars {
                self.array_annotations.value = annotations
            }
        }
        if type == .feeds {
            self.updateCarsProperties()
            if self.errorEvents == false && self.errorOffers == false {
                DispatchQueue.main.async {
                    for feed in self.feeds {
                        if let coordinate = feed.feedLocation?.coordinate {
                            let annotation = FeedAnnotation(position: coordinate, feed: feed)
                            annotations.append(annotation)
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
    
    /**
     This method updates cars proprerties:
     - nearest
     - booked
     - opened
     */
    public func updateCarsProperties () {
        var nearestCarCopy: Car? = nil
        for car in self.allCars {
            car.nearest = false
            car.booked = false
            car.opened = false
            if let carBooked = self.carBooked {
                if car.plate == carBooked.plate {
                    car.booked = true
                    car.opened = carBooked.opened
                }
            }
            if car.distance ?? 0 > 0 {
                if nearestCarCopy == nil {
                    nearestCarCopy = car
                } else if let nearestCar = nearestCarCopy {
                    if let nearestCarDistance = nearestCar.distance, let carDistance = car.distance {
                        if nearestCarDistance > carDistance {
                            nearestCarCopy = car
                        }
                    }
                }
            }
            let index = self.cars.index(where: { (singleCar) -> Bool in
                return car.plate == singleCar.plate
            })
            if let index = index {
                if self.cars.count > index {
                    self.cars[index] = car
                }
            }
        }
        nearestCarCopy?.nearest = true
        self.nearestCar.value = nearestCarCopy
    }
    
    // MARK: - Action methods
    
    /**
     This method open car
     - Parameter car: The car that has to be opened
     */
    public func openCar(car: Car, action: String, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?) ->()) {
        self.apiController.openCar(car: car, action: action)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200 {
                        completionClosure(true, nil)
                    } else {
                        completionClosure(false, nil)
                    }
                case .error(let error):
                    completionClosure(false, error)
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method book car
     - Parameter car: The car that has to be booked
     */
    public func bookCar(car: Car, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?, _ data: JSON?) ->()) {
        var userLatitude: CLLocationDegrees = 0
        var userLongitude: CLLocationDegrees = 0
        let locationManager = LocationManager.sharedInstance
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let userLocation = locationManager.lastLocationCopy.value {
                userLatitude = userLocation.coordinate.latitude
                userLongitude = userLocation.coordinate.longitude
            }
        }
        self.apiController.bookCar(car: car, userLatitude: userLatitude, userLongitude: userLongitude)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        completionClosure(true, nil, data)
                    } else {
                        let json: JSON = ["reason": response.reason!]
                        completionClosure(false, nil,json)
                    }
                case .error(let error):
                    completionClosure(false, error, nil)
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method get car booking
     - Parameter id: The id of car booking used to get informations
    */
    public func getCarBooking(id: Int, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?, _ data: [JSON]?) ->()) {
        self.apiController.getCarBooking(id: id)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        completionClosure(true, nil, data)
                    } else {
                        completionClosure(false, nil, nil)
                    }
                case .error(let error):
                    completionClosure(false, error, nil)
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method delete car booking
     - Parameter carBooking: The car booking that has to be deleted
     */
    public func deleteCarBooking(carBooking: CarBooking, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?) ->()) {
        self.apiController.deleteCarBooking(carBooking: carBooking)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200 {
                        completionClosure(true, nil)
                    } else {
                        completionClosure(false, nil)
                    }
                case .error(let error):
                    completionClosure(false, error)
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Route methods
    
    public func getRoute(destination: CLLocation, completionClosure: @escaping (_ steps: [RouteStep]) ->()) {
        let locationManager = LocationManager.sharedInstance
        if let userLocation = locationManager.lastLocationCopy.value {
            let distance = destination.distance(from: userLocation)
            if distance <= 10000 {
                let dispatchTime = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.googleApiController.searchRoute(destination: destination)
                        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe { event in
                            switch event {
                            case .next(let steps):
                                completionClosure(steps)
                            case .error(_):
                                completionClosure([])
                            default:
                                break
                            }
                        }.addDisposableTo(self.disposeBag)
                }
            } else {
                completionClosure([])
            }
        } else {
            completionClosure([])
        }
    }
}
