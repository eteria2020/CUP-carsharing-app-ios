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

enum SearchCarSelectionInput: SelectionInput {
    case item(IndexPath)
}

enum SearchCarSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class SearchCarsViewModel: ViewModelTypeSelectable {
    fileprivate var dic_carAnnotations:[String:CarAnnotation] = [:]
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var oldNearestCar: Car?
    fileprivate var nearestCar: Car?
    fileprivate var cars: [Car] = []
    
    var array_annotationsToAdd: Variable<[CarAnnotation]> = Variable([])
    var array_annotationsToRemove: Variable<[CarAnnotation]> = Variable([])
    
    lazy var selection:Action<SearchCarSelectionInput,SearchCarSelectionOutput> = Action { input in
        return .empty()
    }
    
    init() {
    }
    
    // MARK: - Cars methods
    
    func resetCars() {
        self.cars = []
        var annotationsToRemove: [CarAnnotation] = []
        self.array_annotationsToAdd.value = []
        self.dic_carAnnotations.forEach({ (key, value) in
            annotationsToRemove.append(value)
        })
        self.array_annotationsToRemove.value = annotationsToRemove
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
                        self.cars = []
                        self.manageAnnotations()
                    case .error(_):
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            if Reachability()?.isReachable == false {
                                let dialog = ZAlertView(title: nil, message: "lbl_connectionError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                            else {
                                let dialog = ZAlertView(title: nil, message: "lbl_generalError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                            self.cars = []
                            self.manageAnnotations()
                        }
                    default:
                        break
                    }
        }.addDisposableTo(resultsDispose!)
    }
    
    fileprivate func manageAnnotations() {
        self.nearestCar = nil
        var annotationsToAdd: [CarAnnotation] = []
        var annotationsToRemove: [CarAnnotation] = []
        var dic_carAnnotationsKeys = Array(dic_carAnnotations.keys)
        for car in self.cars {
            // Distance
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
            if let key = car.plate {
                if car.plate == oldNearestCar?.plate || car.plate == nearestCar?.plate {
                    if let coordinate = car.location?.coordinate {
                        let annotation = CarAnnotation()
                        annotation.coordinate = coordinate
                        annotation.car = car
                        annotationsToAdd.append(annotation)
                        if let annotation = dic_carAnnotations[key] {
                            annotationsToRemove.append(annotation)
                            dic_carAnnotationsKeys.remove(key)
                        }
                        self.dic_carAnnotations[key] = annotation
                    }
                } else if dic_carAnnotationsKeys.contains(key) {
                    dic_carAnnotationsKeys.remove(key)
                } else if let coordinate = car.location?.coordinate {
                    let annotation = CarAnnotation()
                    annotation.coordinate = coordinate
                    annotation.car = car
                    annotationsToAdd.append(annotation)
                    self.dic_carAnnotations[key] = annotation
                }
            }
        }
        for key in dic_carAnnotationsKeys {
            if let annotation = dic_carAnnotations[key] {
                annotationsToRemove.append(annotation)
                self.dic_carAnnotations.removeValue(forKey: key)
            }
        }
        self.array_annotationsToAdd.value = annotationsToAdd
        self.array_annotationsToRemove.value = annotationsToRemove
        self.oldNearestCar = self.nearestCar
    }
}
