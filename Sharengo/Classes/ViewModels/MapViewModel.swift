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
    //Variable used to store deepLink car
    public var deepCar: Variable<Car?> = Variable<Car?>(nil)
    /// Variable used to save cars (visible car sin the map, or cars found is the radius)
    public var cars: [Car] = []
    /// Variable used to save all cars in share'ngo system (all the cars found by the system)
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
    
    @objc public func searchPlateAvailable(plate: String) {
        self.apiController.searchCars()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let cars = [Car].from(jsonArray: data) {
                            self.allCars = cars
                            var finalCar: Car? = nil
                            let carSelcted:[Car?] = self.allCars.filter({ (car) -> Bool in
                                return car.plate?.lowercased().contains(plate.lowercased()) ?? false})
                            
                            // Distance
                            if let car = carSelcted[0]{
                                
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
                            finalCar = car
                            }
                            self.manageAnnotations()
                            self.deepCar.value = finalCar
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
    public func manageAnnotations()
    {
        var annotations: [GMUClusterItem] = []
        let locationIsAuthorized = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        let locationManager = LocationManager.sharedInstance
        let userLocation = locationManager.lastLocationCopy.value
        
        if type == .searchCars || showCars == true
        {
            var carBookedFounded: Bool = false
            
            // Update distance from me and booked car and update the same car in the cars array
            
            if let carBooked = carBooked
            {
                if  let userLocation = userLocation,
                    let carLocation = carBooked.location,
                    locationIsAuthorized
                {
                    carBooked.distance = carLocation.distance(from: userLocation)
                    
                    if  let index = cars.index(where: { carBooked.plate == $0.plate })
                    {
                        cars[index].distance = carBooked.distance
                    }
                }
            }
            
            //  Update all cars distances and updated "allCars" cars
            
            for car in cars
            {
                if  let userLocation = userLocation,
                    let carLocation = car.location,
                    locationIsAuthorized
                {
                    car.distance = carLocation.distance(from: userLocation)
                    
                    if let index = allCars.index(where: { car.plate == $0.plate })
                    {
                        allCars[index].distance = car.distance
                    }
                }
                
                //  Check for car booked found
                
                if car.plate == carBooked?.plate
                {
                    carBookedFounded = true
                }
            }
            
            //  Update all cars distances and then... update cars array distances.. I don't know why
            
            for car in allCars
            {
                if  let userLocation = userLocation,
                    let carLocation = car.location,
                    locationIsAuthorized
                {
                    car.distance = carLocation.distance(from: userLocation)
                    
                    if let index = cars.index(where: { car.plate == $0.plate })
                    {
                        cars[index].distance = car.distance
                    }
                }
            }
            
            //  Updated cars properties
            
            updateCarsProperties()
            
            //  Add cars annotations
            
            for car in cars
            {
                if let coordinate = car.location?.coordinate
                {
                    let annotation = CarAnnotation(position: coordinate, car: car, carBooked: carBooked, carTrip: carTrip)
                    annotations.append(annotation)
                }
            }
            
            //  If there is a car booked, add car bokoed annotation
            
            if  let carBooked = carBooked,
                carBookedFounded == false,
                (carTrip == nil || carTrip?.car.value?.parking == true),
                let coordinate = carBooked.location?.coordinate
            {
                let annotation = CarAnnotation(position: coordinate, car: carBooked, carBooked:  carBooked, carTrip: carTrip)
                annotations.append(annotation)
            }
            
            //  ... don't know
            
            if type == .searchCars
            {
                array_annotations.value = annotations
            }
        }
        
        //  Type feeds... don't know...
        
        if type == .feeds
        {
            updateCarsProperties()
            
            if  errorEvents == false &&
                errorOffers == false
            {
                DispatchQueue.main.async {
                    for feed in self.feeds
                    {
                        if let coordinate = feed.feedLocation?.coordinate
                        {
                            let annotation = FeedAnnotation(position: coordinate, feed: feed)
                            annotations.append(annotation)
                        }
                    }
                    self.array_annotations.value = annotations
                }
                
            }
            else if errorEvents == true ||
                    errorOffers == true
            {
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    
                    var message = "alert_generalError".localized()
                    if Reachability()?.isReachable == false { message = "alert_connectionError".localized() }
                    
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
    public func updateCarsProperties ()
    {
        var nearestCarCopy: Car? = nil
        
        for car in allCars
        {
            car.nearest = false
            car.booked = false
            car.opened = false
            
            //  Search booked car
            
            if let carBooked = carBooked
            {
                if car.plate == carBooked.plate
                {
                    car.booked = true
                    car.opened = carBooked.opened
                }
            }
            
            //  Search and define nearest car
            
            if car.distance ?? 0 > 0
            {
                if nearestCarCopy == nil
                {
                    nearestCarCopy = car
                }
                else if let nearestCar = nearestCarCopy
                {
                    if let nearestCarDistance = nearestCar.distance, let carDistance = car.distance
                    {
                        if nearestCarDistance > carDistance
                        {
                            nearestCarCopy = car
                        }
                    }
                }
            }
            
            //  Update cars array with allCars cars... I don't know why
            
            if let index = cars.index(where: { car.plate == $0.plate })
            {
                if cars.count > index
                {
                    cars[index] = car
                }
            }
        }
        
        //  Updated neares car
        
        nearestCarCopy?.nearest = true
        nearestCar.value = nearestCarCopy
    }
    
    // MARK: - Action methods
    
    /**
     This method open car
     - Parameter car: The car that has to be opened
     */
    public func openCar(car: Car, action: String, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?,_ data: String) ->()) {
        self.apiController.openCar(car: car, action: action)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200 {
                        completionClosure(true, nil,"")
                    }else if response.status == 403{
                        completionClosure(false, nil,response.code!)
                    }else {
                        completionClosure(false, nil,"")
                    }
                case .error(let error):
                    completionClosure(false, error,"")
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    // This method handle close car
    public func closeCar(car: Car, action: String, completionClosure: @escaping (_ success: Bool, _ error: Swift.Error?,_ data: String) ->()) {
        self.apiController.closeCar(car: car, action: action)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200 {
                        completionClosure(true, nil,"")
                    }else if response.status == 403{
                        completionClosure(false, nil,response.code!)
                    }else {
                        completionClosure(false, nil,"")
                    }
                case .error(let error):
                    completionClosure(false, error,"")
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
                    } else if response.status == 403 {
                        
                        if let code = response.code{
                             let json: JSON = ["reason": code]
                            completionClosure(false, nil,json)
                        }
                    }
                    else{
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
    
    public func getRoute(destination: CLLocation, completionClosure: @escaping (_ steps: GMSPolyline?) ->()) {
        let locationManager = LocationManager.sharedInstance
        if let userLocation = locationManager.lastLocationCopy.value {
            let distance = destination.distance(from: userLocation)
            if distance <= 10000 {
                let dispatchTime = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    
                    let source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate, addressDictionary: nil))
                    let destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate, addressDictionary: nil))
                    
                    let request: MKDirectionsRequest = MKDirectionsRequest()
                    
                    request.source = source
                    request.destination = destination
                    request.requestsAlternateRoutes = true
                    request.transportType = .walking
                    
                    let directions = MKDirections(request: request)
                    
                    directions.calculate { response, error in
                        if let route = response?.routes.first
                        {
                            let path = GMSMutablePath()
                            let coordinates = route.steps.map { $0.polyline.coordinate }
                            coordinates.forEach { coord in
                                path.add(coord)
                            }
                            let polyline = GMSPolyline(path: path)
                            completionClosure(polyline)
                        }
                        else
                        {
                            completionClosure(nil)
                        }
                    }
                    
                }
            } else {
                completionClosure(nil)
            }
        } else {
            completionClosure(nil)
        }
    }
    
    public func updateCarPopUp(car : Car, carPopUp : CarPopupView)
    {
        let nearestCar = car.nearest
        if let plate = car.plate
        {
        self.apiController.searchCar(plate: plate)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {

                        if let car = Car(json: data){
                        var arrayCar : [GMUClusterItem] = self.array_annotations.value

                                            let index = arrayCar.index(where: { (singleCar) -> Bool in
                                                if  singleCar is CarAnnotation{
                                                    let carAnn = singleCar as! CarAnnotation
                                                    return car.plate == carAnn.car.plate
                                                }else {
                                                    return false
                                                }

                                            })
                                            if let index = index {
                                                if let coordinate = car.location?.coordinate{

                                                   
                                                    self.array_annotations.value = arrayCar
                                                    if let index = self.allCars.index(where: { car.plate == $0.plate })
                                                    {
                                                        car.nearest = nearestCar
                                                        self.allCars[index] = car
                                                    } else{
                                                        self.allCars.append(car)
                                                    }
                                                    arrayCar[index] = CarAnnotation(position: coordinate, car: car, carBooked: nil, carTrip: nil)
                                                    carPopUp.updateWithCar(car: car)
                                                   
                                                }
                    
                                            }
                                            else{
                                                if let coordinate = car.location?.coordinate{
                                                    
                                                  
                                                    self.array_annotations.value = arrayCar
                                                    if let index = self.allCars.index(where: { car.plate == $0.plate })
                                                    {
                                                        car.nearest = nearestCar
                                                        self.allCars[index] = car
                                                    }
                                                    else{
                                                         self.allCars.append(car)
                                                    }
                                                    arrayCar.append(CarAnnotation(position: coordinate, car: car, carBooked: nil, carTrip: nil))
                                                    carPopUp.updateWithCar(car: car)
                                                }
                                            }
                             }
                    }
                            return
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
        }
    }
}
