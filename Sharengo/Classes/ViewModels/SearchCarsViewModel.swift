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

final class SearchCarsViewModel: ViewModelType {
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var oldNearestCar: Car?
    fileprivate var nearestCar: Car?
    fileprivate var timerCars: Timer?
    fileprivate var cars: [Car] = []
    var allCars: [Car] = []
    var carBooked: Car?
    var carBooking: CarBooking?
    var carTrip: CarTrip?
    
    var array_annotations: Variable<[CarAnnotation]> = Variable([])

    init() {
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
        self.array_annotations.value = []
        self.manageAnnotations()
    }
    
    func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    func reloadResults(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
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
    }
    
    func manageAnnotations() {
        var carBookedFounded: Bool = false
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
        var annotations: [CarAnnotation] = []
        for car in self.cars {
            if let coordinate = car.location?.coordinate {
                let annotation = CarAnnotation()
                annotation.coordinate = coordinate
                annotation.car = car
                annotations.append(annotation)
            }
        }
        if carBookedFounded == false && self.carBooked != nil {
            if let coordinate = self.carBooked!.location?.coordinate {
                let annotation = CarAnnotation()
                annotation.coordinate = coordinate
                annotation.car = self.carBooked!
                annotations.append(annotation)
            }
        }
        self.array_annotations.value = annotations
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
