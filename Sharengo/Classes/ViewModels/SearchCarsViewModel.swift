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
    fileprivate var cars: [Car] = []
    
    var array_annotations: Variable<[CarAnnotation]> = Variable([])

    init() {
    }
    
    // MARK: - Cars methods
    
    func resetCars() {
        self.cars.removeAll()
        self.array_annotations.value = []
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
                    if response.status == 200, let data = response.data {
                        if let cars = [Car].from(jsonArray: data) {
                            self.cars = cars.filter({ (car) -> Bool in
                                return car.status == .operative
                            })
                            self.manageAnnotations()
                            return
                        }
                    }
                    self.cars.removeAll()
                    self.manageAnnotations()
                case .error(_):
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        var message = "lbl_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "lbl_connectionError".localized()
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
        self.nearestCar = nil
        var annotations: [CarAnnotation] = []
        // Distance
        for car in self.cars {
            let locationController = LocationController.shared
            if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
                if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                    car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                    car.nearest = false
                    if self.nearestCar == nil {
                        self.nearestCar = car
                    } else if let nearestCar = nearestCar {
                        if let nearestCarDistance = nearestCar.distance, let carDistance = car.distance {
                            if nearestCarDistance > carDistance {
                                self.nearestCar = car
                            }
                        }
                    }
                }
            }
        }
        self.nearestCar?.nearest = true
        // Annotations
        for car in self.cars {
            if let coordinate = car.location?.coordinate {
                let annotation = CarAnnotation()
                annotation.coordinate = coordinate
                annotation.car = car
                annotations.append(annotation)
            }
        }
        self.array_annotations.value = annotations
    }
}
