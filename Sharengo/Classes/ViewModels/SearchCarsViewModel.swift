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
    fileprivate var nearestCar: Car?
    
    var array_annotationsToAdd: Variable<[CarAnnotation]> = Variable([])
    var array_annotationsToRemove: Variable<[CarAnnotation]> = Variable([])
    var cars: [Car] = []
    
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
        self.apiController.searchCars(latitude: latitude, longitude: longitude, radius: radius).subscribe { event in
            switch event {
            case .next(let cars):
                self.cars = cars.filter({ (car) -> Bool in
                    return car.status == .operative
                })
                self.manageAnnotations() 
            case .error(let error):
                print(error)
            default:
                break
            }
        }.addDisposableTo(resultsDispose!)
    }
    
    fileprivate func manageAnnotations() {
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
            // Annotations
            if let key = car.plate {
                if dic_carAnnotationsKeys.contains(key) {
                    dic_carAnnotationsKeys.remove(key)
                } else if let coordinate = car.location?.coordinate {
                    let annotation = CarAnnotation()
                    annotation.coordinate = coordinate
                    annotation.car = car
                    annotationsToAdd.append(annotation)
                    dic_carAnnotations[key] = annotation
                }
            }
        }
        self.nearestCar?.nearest = true
        for key in dic_carAnnotationsKeys {
            if let annotation = dic_carAnnotations[key] {
                annotationsToRemove.append(annotation)
                dic_carAnnotations.removeValue(forKey: key)
            }
        }
        self.array_annotationsToAdd.value = annotationsToAdd
        self.array_annotationsToRemove.value = annotationsToRemove
    }
}
