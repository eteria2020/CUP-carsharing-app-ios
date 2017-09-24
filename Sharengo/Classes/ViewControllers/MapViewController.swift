//
//  MapViewController.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action
import MapKit
import StoryboardConstraint
import DeviceKit
import ReachabilitySwift
import KeychainSwift
import SideMenu
import GoogleMaps

/**
 The Map class provides features related to display content on a map. These include:
 - show cars
 - show feeds
 */
public class MapViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_carPopup: CarPopupView!
    @IBOutlet fileprivate weak var view_carBookingPopup: CarBookingPopupView!
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_searchBar: SearchBarView!
    @IBOutlet fileprivate weak var mapView: GMSMapView!
    @IBOutlet fileprivate weak var btn_closeCarPopup: UIButton!
    /// User can open doors 50 meters down
    public let carPopupDistanceOpenDoors: Int = 50
    /// Map has to show cities 35000 meters up
    public let citiesRadius: Double = 35000
    /// Map has to show callout 6000 meters up
    public let clusteringRadius: Double = 7500
    /// Variable used to save height of popup
    public var closeCarPopupHeight: CGFloat = 0.0
    /// Variable used to save if the position of the user is checked
    public var checkedUserPosition: Bool = false
    /// Variable used to save if cities are shown or not
    public var clusteringInProgress: Bool = false
    /// Variable used to save car selected in popup
    public var selectedCar: Car?
    /// Variable used to save feed selected in popup
    public var selectedFeed: Feed?
    /// Google Maps cluster manager to manage clustering
    public var clusterManager: GMUClusterManager!
    /// ViewModel variable used to represents the data
    public var viewModel: MapViewModel?
    /// Variable used to save time start of a car trip
    public var carTripTimeStart: Date?
    /// Variable used to save user annotation
    public var userAnnotation: UserAnnotation = UserAnnotation()
    /// Variable used to save route steps
    public var routeSteps: [RouteStep] = []
    /// Variable used to save route polylines
    public var routePolylines: [GMSPolyline] = []
    /// Variable used to save old location
    public var lastLocation: CLLocation?
    /// Variable used to save nearest car
    public var lastNearestCar: Car?
    /// Variable used to save nearest car route steps
    public var nearestCarRouteSteps: [RouteStep] = []
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MapViewModel else {
            return
        }
        self.viewModel = viewModel
        // NearestCar
        viewModel.nearestCar.asObservable()
            .subscribe(onNext: {[weak self] (nearestCar) in
                if nearestCar == nil {
                    self?.nearestCarRouteSteps = []
                    if self?.viewModel?.carTrip == nil && self?.viewModel?.carBooking == nil {
                        self?.routeSteps = []
                        self?.drawRoutes(steps: [])
                    }
                }
                else if self?.lastNearestCar?.location?.coordinate.latitude != nearestCar?.location?.coordinate.latitude && self?.lastNearestCar?.location?.coordinate.longitude != nearestCar?.location?.coordinate.longitude {
                    self?.lastNearestCar = nearestCar
                    self?.viewModel?.getRoute(destination: nearestCar!.location!, completionClosure: { (steps) in
                        self?.nearestCarRouteSteps = steps
                        if self?.viewModel?.carTrip == nil && self?.viewModel?.carBooking == nil {
                            self?.routeSteps = steps
                            self?.drawRoutes(steps: steps)
                        }
                    })
                }
            })
        // Annotations
        viewModel.array_annotations.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    if self?.clusteringInProgress == true {
                        self?.mapView.clear()
                        self?.clusterManager.clearItems()
                        if let steps = self?.routeSteps {
                            self?.drawRoutes(steps: steps)
                        }
                        var canCluster = true
                        if let radius = self?.getRadius() {
                            if radius < self!.clusteringRadius {
                                canCluster = false
                            }
                        }
                        for annotation in array {
                            annotation.canCluster = canCluster
                            if let carAnnotation = annotation as? CarAnnotation {
                                if viewModel.carBooked?.plate == carAnnotation.car.plate && viewModel.carTrip != nil && viewModel.carTrip?.car.value?.parking == false
                                { }
                                else {
                                    self?.clusterManager.add(annotation)
                                }
                            } else {
                                self?.clusterManager.add(annotation)
                            }
                        }
                        self?.clusterManager.cluster()
                        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                            self?.showUserPositionVisible(true)
                        } else {
                            self?.showUserPositionVisible(false)
                        }
                        self?.addPolygons()
                    }
                    if viewModel.type == .feeds {
                        self?.setUpdateButtonAnimated(false)
                    } else {
                        let dispatchTime = DispatchTime.now() + 0.3
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            self?.setUpdateButtonAnimated(false)
                        }
                    }
                    if let car = self?.selectedCar {
                        self?.view_carPopup.updateWithCar(car: car)
                        if self!.routeSteps.count > 0 {
                            if let distance = self?.routeSteps[0].distance, let duration = self?.routeSteps[0].duration {
                                self?.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                            }
                        }
                    }
                    if let allCars = self?.viewModel?.allCars {
                        self?.view_searchBar.viewModel?.allCars = allCars
                    }
                }
            }).addDisposableTo(disposeBag)
        // CarPopup
        self.btn_closeCarPopup.rx.tap.asObservable()
            .subscribe(onNext:{
                self.closeCarPopup()
            }).addDisposableTo(disposeBag)
        // CircularMenu
        self.view_circularMenu.bind(to: ViewModelFactory.circularMenu(type: viewModel.type.getCircularMenuType()))
        self.view_circularMenu.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .refresh:
                self?.updateResults()
            case .center:
                self?.centerMap()
            case .compass:
                self?.turnMap()
            case .cars:
                if viewModel.carBooked != nil {
                    let dialog = ZAlertView(title: nil, message: "alert_showCarsDisabledMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    return
                }
                if viewModel.showCars {
                    viewModel.showCars = false
                    self?.setCarsButtonVisible(false)
                    self?.updateResults()
                } else {
                    viewModel.showCars = true
                    self?.setCarsButtonVisible(true)
                    self?.updateResults()
                }
            default: break
            }
        }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                self?.view_searchBar.stopSearchBar()
                Router.exit(self!)
                self?.closeCarPopup()
            case .menu:
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
                self?.closeCarPopup()
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        // CarPopup
        self.view_carPopup.bind(to: ViewModelFactory.carPopup(type: .car))
        self.view_carPopup.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .open(let car):
                self?.openCar(car: car, action: "open")
            case .book(let car):
                self?.bookCar(car: car)
            case .car:
                if self?.viewModel?.carBooked != nil {
                    let dialog = ZAlertView(title: nil, message: "alert_showCarsDisabledMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    return
                }
                self?.showNearestCar()
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.view_carPopup.alpha = 0.0
        self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
        switch Device().diagonal {
        case 3.5:
            self.closeCarPopupHeight = 160
        case 4:
            self.closeCarPopupHeight = 170
        case 4.7:
            self.closeCarPopupHeight = 185
        case 5.5:
            self.closeCarPopupHeight = 195
        default:
            break
        }
        // CarBookingPopup
        self.view_carBookingPopup.bind(to: ViewModelFactory.carBookingPopup())
        self.view_carBookingPopup.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .open(let car):
                if self?.viewModel?.carTrip?.car.value?.parking == true {
                    self?.openCar(car: car, action: "unpark")
                } else {
                    self?.openCar(car: car, action: "open")
                }
            case .delete:
                self?.deleteBookCar()
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.view_carBookingPopup.backgroundColor = Color.carBookingPopupBackground.value
        self.view_carBookingPopup.alpha = 0.0
        switch Device().diagonal {
        case 3.5:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 180
        case 4:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 195
        case 4.7:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 205
        case 5.5:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 215
        default:
            break
        }
        // SearchBar
        self.view_searchBar.bind(to: ViewModelFactory.searchBar())
        self.view_searchBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .reload:
                self?.view_searchBar.updateCollectionView(show: true)
            case .address(let address):
                if let location = address.location {
                    self?.centerMap(on: location, zoom: 16.5, animated: true)
                }
                self?.updateSpeechSearchBar()
            case .car(let car):
                if let location = car.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.00015, longitude: location.coordinate.longitude)
                    self?.centerMap(on: newLocation, zoom: 18.5, animated: true)
                }
                self?.view_carPopup.updateWithCar(car: car)
                if self!.routeSteps.count > 0 {
                    if let distance = self?.routeSteps[0].distance, let duration = self?.routeSteps[0].duration {
                        self?.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                    }
                }
                self?.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0
                    } else if car.type.contains("\n") {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0 + 55
                    } else {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0 + 40
                    }
                    self?.view_carPopup.alpha = 1.0
                    self?.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self?.view.layoutIfNeeded()
                    if let location = car.location {
                        self?.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                            self?.routeSteps = steps
                            self?.drawRoutes(steps: steps)
                        })
                    }
                })
                self?.updateSpeechSearchBar()
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // Map
        self.setupMap()
        // NotificationCenter
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            if let car = self.view_carBookingPopup?.viewModel?.carTrip?.car.value {
                car.booked = false
                car.opened = false
            }
            if let car = self.view_carBookingPopup?.viewModel?.carBooking?.car.value {
                car.booked = false
                car.opened = false
            }
            self.view_carBookingPopup.alpha = 0.0
            self.view_carBookingPopup?.viewModel?.carTrip = nil
            self.view_carBookingPopup?.viewModel?.carBooking = nil
            self.viewModel?.carBooked = nil
            self.viewModel?.carTrip = nil
            self.viewModel?.carBooking = nil
            CoreController.shared.allCarBookings = []
            CoreController.shared.currentCarBooking = nil
            CoreController.shared.allCarTrips = []
            CoreController.shared.currentCarTrip = nil
            self.getResultsWithoutLoading()
            self.routeSteps = self.nearestCarRouteSteps
            self.drawRoutes(steps: self.nearestCarRouteSteps)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.checkUserPositionFromForeground()
            CoreController.shared.updateData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.updateCarData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.closeCarBookingPopupView), name: NSNotification.Name(rawValue: "closeCarBookingPopupView"), object: nil)
        self.setCarsButtonVisible(false)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.checkedUserPosition {
            self.checkUserPosition()
        } else {
            self.checkedUserPosition = true
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCarData()
        if let feed = self.selectedFeed {
            self.view_carPopup.updateWithFeed(feed: feed)
        }
    }
    
    // MARK: - Update methods
    
    /**
     This method checks car trip and car booking (car trip is checked before car booking) after the application is updated in background
     
     ## Important Notes ##
     1. If there is a car trip/car booking and there is no saved car trip/car booking the application shows popup
     2. If there is a car trip/car booking and there is a saved car trip/car booking the application updated popup
     3. If there isn't a car trip/car booking and there is a saved car trip/car booking the application hides popup
     */
    @objc public func updateCarData() {
        if let carTrip = CoreController.shared.allCarTrips.first {
            self.carTripTimeStart = carTrip.timeStart
            carTrip.updateCar {
                    DispatchQueue.main.async {
                        if let car = carTrip.car.value {
                            if carTrip.id != self.viewModel?.carTrip?.id {
                                // Show
                                car.booked = true
                                car.opened = true
                                self.view_carBookingPopup.alpha = 1.0
                                self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                self.viewModel?.carBooked = car
                                self.viewModel?.carTrip = carTrip
                                self.getResultsWithoutLoading()
                                if car.parking == true {
                                    if let location = car.location {
                                        let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                        self.centerMap(on: newLocation, zoom: 18.5, animated: true)
                                    }
                                    if let location = car.location {
                                        self.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                            self.routeSteps = steps
                                            self.drawRoutes(steps: steps)
                                        })
                                    }
                                }
                                if self.viewModel?.carBooked != nil && self.viewModel?.showCars == false {
                                    DispatchQueue.main.async {
                                        self.setCarsButtonVisible(true)
                                        self.viewModel?.showCars = true
                                        self.updateResults()
                                    }
                                }
                            } else {
                                // Update
                                car.booked = true
                                car.opened = true
                                self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                self.viewModel?.carBooked = car
                                self.viewModel?.carTrip = carTrip
                                self.getResultsWithoutLoading()
                                if self.viewModel?.carBooked != nil && self.viewModel?.showCars == false {
                                    DispatchQueue.main.async {
                                        self.setCarsButtonVisible(true)
                                        self.viewModel?.showCars = true
                                        self.updateResults()
                                    }
                                }
                            }
                        }
                    }
                }
        } else if self.view_carBookingPopup.alpha == 1.0 && self.view_carBookingPopup?.viewModel?.carTrip != nil {
            let dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                if self.view_carBookingPopup?.viewModel?.carTrip != nil {
                    let carTrip = self.view_carBookingPopup!.viewModel!.carTrip!
                    carTrip.timeStart = self.carTripTimeStart
                    // Hide
                    if let car = self.view_carBookingPopup?.viewModel?.carTrip?.car.value {
                        car.booked = false
                        car.opened = false
                    }
                    self.view_carBookingPopup.alpha = 0.0
                    self.view_carBookingPopup?.viewModel?.carTrip = nil
                    self.view_carBookingPopup?.viewModel?.carBooking = nil
                    self.viewModel?.carBooked = nil
                    self.viewModel?.carTrip = nil
                    self.viewModel?.carBooking = nil
                    CoreController.shared.allCarTrips = []
                    CoreController.shared.currentCarTrip = nil
                    self.getResultsWithoutLoading()
                    self.routeSteps = self.nearestCarRouteSteps
                    self.drawRoutes(steps: self.nearestCarRouteSteps)
                }
            }
        }
        if let carBooking = CoreController.shared.allCarBookings.first {
            carBooking.car.asObservable()
                .subscribe(onNext: {[weak self] (car) in
                    DispatchQueue.main.async {
                        if let car = car {
                            if carBooking.id != self?.viewModel?.carBooking?.id {
                                if carBooking.timer != "<bold>00:00</bold> \("lbl_carBookingPopupTimeMinutes".localized())" {
                                    // Show
                                    car.booked = true
                                    self?.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                    self?.view_carBookingPopup.alpha = 1.0
                                    self?.viewModel?.carBooked = car
                                    self?.viewModel?.carBooking = carBooking
                                    self?.getResultsWithoutLoading()
                                    let locationManager = LocationManager.sharedInstance
                                    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                                        if let userLocation = locationManager.lastLocationCopy.value {
                                            self?.centerMap(on: userLocation, zoom: 16.5, animated: false)
                                        }
                                    }
                                    if let location = car.location {
                                        self?.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                            self?.routeSteps = steps
                                            self?.drawRoutes(steps: steps)
                                        })
                                    }
                                    if self?.viewModel?.carBooked != nil && self?.viewModel?.showCars == false {
                                        DispatchQueue.main.async {
                                            self?.setCarsButtonVisible(true)
                                            self?.viewModel?.showCars = true
                                            self?.updateResults()
                                        }
                                    }
                                }
                            } else {
                                // Update
                                car.booked = true
                                self?.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                self?.viewModel?.carBooked = car
                                self?.viewModel?.carBooking = carBooking
                                self?.getResultsWithoutLoading()
                                if self?.viewModel?.carBooked != nil && self?.viewModel?.showCars == false {
                                    DispatchQueue.main.async {
                                        self?.setCarsButtonVisible(true)
                                        self?.viewModel?.showCars = true
                                        self?.updateResults()
                                    }
                                }
                            }
                        }
                    }
                }).addDisposableTo(disposeBag)
        } else if self.view_carBookingPopup.alpha == 1.0 && self.view_carBookingPopup?.viewModel?.carBooking != nil {
            // Hide
            self.closeCarBookingPopupView()
        }
        if let car = self.selectedCar {
            self.view_carPopup.updateWithCar(car: car)
            if routeSteps.count > 0 {
                if let distance = routeSteps[0].distance, let duration = routeSteps[0].duration {
                    self.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                }
            }
            self.view.layoutIfNeeded()
        }
        if self.viewModel?.carBooked != nil && self.viewModel?.showCars == false {
            DispatchQueue.main.async {
                self.setCarsButtonVisible(true)
                self.viewModel?.showCars = true
                self.updateResults()
            }
        }
    }
    
    /**
     This method updates search bar speech controller
     */
    public func updateSpeechSearchBar() {
        self.view_searchBar.updateCollectionView(show: false)
        if self.view_searchBar.viewModel?.speechInProgress.value == true {
            self.view_searchBar.viewModel?.speechInProgress.value = false
            if #available(iOS 10.0, *) {
                self.view_searchBar.viewModel?.speechController.manageRecording()
            }
        }
    }
    
    /**
     This method hides popup and reset variables
     */
    @objc public func closeCarBookingPopupView() {
        if self.view_carBookingPopup.alpha == 1.0 && self.view_carBookingPopup?.viewModel?.carBooking != nil {
            let dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                if let car = self.view_carBookingPopup?.viewModel?.carBooking?.car.value {
                    car.booked = false
                    car.opened = false
                }
                self.view_carBookingPopup.alpha = 0.0
                self.view_carBookingPopup?.viewModel?.carTrip = nil
                self.view_carBookingPopup?.viewModel?.carBooking = nil
                self.viewModel?.carBooked = nil
                self.viewModel?.carTrip = nil
                self.viewModel?.carBooking = nil
                CoreController.shared.allCarBookings = []
                CoreController.shared.currentCarBooking = nil
                self.getResultsWithoutLoading()
                self.routeSteps = self.nearestCarRouteSteps
                self.drawRoutes(steps: self.nearestCarRouteSteps)
                DispatchQueue.main.async {
                    self.updateResults()
                }
            }
        }
    }
    
    // MARK: - CarPopup & CarBookingPopup methods
    
    /**
     This method hides popup
     */
    public func closeCarPopup() {
        self.view_searchBar.endEditing(true)
        UIView.animate(withDuration: 0.2, animations: {
            self.selectedCar = nil
            self.view_carPopup.alpha = 0.0
            self.routeSteps = self.nearestCarRouteSteps
            self.drawRoutes(steps: self.nearestCarRouteSteps)
            self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
            self.view.layoutIfNeeded()
        })
    }
    
    /**
     This method shows nearest car
     */
    public func showNearestCar() {
        if let location = self.viewModel?.nearestCar.value?.location {
            let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.centerMap(on: newLocation, zoom: 18.5, animated: true)
            self.view_carPopup.updateWithCar(car: self.viewModel!.nearestCar.value!)
            if routeSteps.count > 0 {
                if let distance = routeSteps[0].distance, let duration = routeSteps[0].duration {
                    self.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                }
            }
            self.view_carPopup.viewModel?.type.value = .car
            self.viewModel?.showCars = true
            self.setCarsButtonVisible(true)
            self.updateResults()
        } else {
            let locationManager = LocationManager.sharedInstance
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                if locationManager.lastLocationCopy.value != nil {
                    return
                }}
            self.showLocalizationAlert(message: "alert_centerMapMessage".localized())
        }
    }
    
    /**
     This method open car after checked if the user is logged in and if the distance between him and the car is less than carPopupDistanceOpenDoors
     - Parameter car: The car that has to be opened
     */
    public func openCar(car: Car, action: String) {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.showLoginAlert()
            return
        }
        if let distance = car.distance {
            #if ISDEBUG
            #elseif ISRELEASE
                if Int(distance.rounded()) > self.carPopupDistanceOpenDoors {
                    let dialog = ZAlertView(title: nil, message: "alert_carPopupDistanceMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    return
                }
            #endif
        } else {
            self.showLocalizationAlert(message: "alert_carPopupLocalizationMessage".localized())
            return
        }
        self.showLoader()
        self.viewModel?.openCar(car: car, action: action, completionClosure: { (success, error) in
            if error != nil {
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.hideLoader(completionClosure: { () in
                        var message = "alert_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "alert_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    })
                }
            } else {
                if success {
                    if let plate = car.plate {
                    CoreController.shared.apiController.searchCar(plate: plate)
                        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe { event in
                            switch event {
                            case .next(let response):
                                if response.status == 200, let data = response.dic_data {
                                    let car2 = Car(json: data)
                                    if action == "unpark" && self.viewModel?.carTrip != nil {
                                        car2?.parking = false
                                        car2?.opened = true
                                        car2?.booked = true
                                        DispatchQueue.main.async {
                                            self.hideLoader(completionClosure: { () in
                                                self.viewModel!.carTrip!.car.value = car2
                                                self.view_carBookingPopup.updateWithCarTrip(carTrip: self.viewModel!.carTrip!)
                                            })
                                        }
                                    } else {
                                        let carTrip = CarTrip(car: car2 ?? car)
                                        DispatchQueue.main.async {
                                            self.hideLoader(completionClosure: { () in
                                                carTrip.car.value?.booked = true
                                                carTrip.car.value?.opened = true
                                                carTrip.timeStart = Date()
                                                self.closeCarPopup()
                                                self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                                self.view_carBookingPopup.alpha = 1.0
                                                self.viewModel?.carBooked = car
                                                self.viewModel?.carTrip = carTrip
                                                self.viewModel?.carBooking = nil
                                                self.getResultsWithoutLoading()
                                                self.routeSteps = self.nearestCarRouteSteps
                                                self.drawRoutes(steps: self.nearestCarRouteSteps)
                                            })
                                        }
                                    }
                                }
                            default:
                                break
                            }
                        }.addDisposableTo(CoreController.shared.disposeBag)
                    } else {
                        let carTrip = CarTrip(car: car)
                        DispatchQueue.main.async {
                            self.hideLoader(completionClosure: { () in
                                car.booked = true
                                car.opened = true
                                carTrip.car.value = car
                                carTrip.timeStart = Date()
                                self.closeCarPopup()
                                self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                self.view_carBookingPopup.alpha = 1.0
                                self.viewModel?.carBooked = car
                                self.viewModel?.carTrip = carTrip
                                self.viewModel?.carBooking = nil
                                self.getResultsWithoutLoading()
                                self.routeSteps = self.nearestCarRouteSteps
                                self.drawRoutes(steps: self.nearestCarRouteSteps)
                            })
                        }
                    }
                } else {
                    self.hideLoader(completionClosure: { () in
                        self.showGeneralAlert()
                    })
                }
            }
        })
    }
    
    /**
     This method book car after checked if the user is logged in
     - Parameter car: The car that has to be booked
     */
    public func bookCar(car: Car) {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.showLoginAlert()
            return
        }
        self.showLoader()
        self.viewModel?.bookCar(car: car, completionClosure: { (success, error, data) in
            if error != nil {
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.hideLoader(completionClosure: { () in
                        var message = "alert_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "alert_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    })
                }
            } else {
                if success {
                    if let id = data!["reservation_id"] as? Int {
                        self.viewModel?.getCarBooking(id: id, completionClosure: { (success, error, data) in
                            if error != nil {
                                let dispatchTime = DispatchTime.now() + 0.5
                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                    self.hideLoader(completionClosure: { () in
                                        var message = "alert_generalError".localized()
                                        if Reachability()?.isReachable == false {
                                            message = "alert_connectionError".localized()
                                        }
                                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                                        })
                                        dialog.allowTouchOutsideToDismiss = false
                                        dialog.show()
                                    })
                                }
                            } else {
                                if success {
                                    if let carBookings = [CarBooking].from(jsonArray: data!) {
                                        if let carBooking = carBookings.first {
                                            DispatchQueue.main.async {
                                                self.hideLoader(completionClosure: { () in
                                                    car.booked = true
                                                    carBooking.car.value = car
                                                    self.closeCarPopup()
                                                    self.view_carBookingPopup.alpha = 1.0
                                                    self.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                                    self.viewModel?.carBooked = car
                                                    self.viewModel?.carBooking = carBooking
                                                    self.getResultsWithoutLoading()
                                                    if let location = car.location {
                                                        self.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                                            self.routeSteps = steps
                                                            self.drawRoutes(steps: steps)
                                                        })
                                                    }
                                                    let locationManager = LocationManager.sharedInstance
                                                    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                                                        if let userLocation = locationManager.lastLocationCopy.value {
                                                            self.centerMap(on: userLocation, zoom: 16.5, animated: false)
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    } else {
                                        self.hideLoader(completionClosure: { () in
                                            self.showGeneralAlert()
                                        })
                                    }
                                } else {
                                    self.hideLoader(completionClosure: { () in
                                        self.showGeneralAlert()
                                    })
                                }
                            }
                        })
                    }
                } else {
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.hideLoader(completionClosure: { () in
                            let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        })
                    }
                }
            }
        })
    }
    
    /**
     This method delete car booking
     */
    public func deleteBookCar() {
        let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupDeleteMessage".localized(), isOkButtonLeft: false, okButtonText: "btn_yes".localized(), cancelButtonText: "btn_no".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    if let carBooking = self.viewModel?.carBooking {
                                        self.showLoader()
                                        self.viewModel?.deleteCarBooking(carBooking: carBooking, completionClosure: { (success, error) in
                                            if error != nil {
                                                let dispatchTime = DispatchTime.now() + 0.5
                                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                    self.hideLoader(completionClosure: { () in
                                                        var message = "alert_generalError".localized()
                                                        if Reachability()?.isReachable == false {
                                                            message = "alert_connectionError".localized()
                                                        }
                                                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                        })
                                                        dialog.allowTouchOutsideToDismiss = false
                                                        dialog.show()
                                                    })
                                                }
                                            } else {
                                                if success {
                                                    let dispatchTime = DispatchTime.now() + 0.5
                                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                        self.hideLoader(completionClosure: { () in
                                                            let confirmDialog = ZAlertView(title: nil, message: "alert_carBookingPopupConfirmDeleteMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                                alertView.dismissAlertView()
                                                                self.closeCarBookingPopupView()
                                                                CoreController.shared.currentCarBooking = nil
                                                            })
                                                            confirmDialog.allowTouchOutsideToDismiss = false
                                                            confirmDialog.show()
                                                        })
                                                    }
                                                } else {
                                                    let dispatchTime = DispatchTime.now() + 0.5
                                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                        self.hideLoader(completionClosure: { () in
                                                            let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                                alertView.dismissAlertView()
                                                            })
                                                            dialog.allowTouchOutsideToDismiss = false
                                                            dialog.show()
                                                        })
                                                    }
                                                }
                                            }
                                        })
                                    }
        },
                                cancelButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    // MARK: - CircularMenu methods
    
    /**
     This method enables or disables user position button in circular menu
     - Parameter visible: Visible determinates if user position button is enabled or disabled
     */
    public func setUserPositionButtonVisible(_ visible: Bool) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .center {
                        if visible {
                            button.alpha = 1
                        } else {
                            button.alpha = 0.5
                        }
                        return
                    }
                }
            }
        }
    }
    
    /**
     This method enables or disables cars button in circular menu
     - Parameter visible: Visible determinates if car button is enabled or disabled
     */
    public func setCarsButtonVisible(_ visible: Bool) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .cars {
                        if visible {
                            button.alpha = 1
                        } else {
                            button.alpha = 0.5
                        }
                        return
                    }
                }
            }
        }
    }
    
    /**
     This method starts or stops update button animation in circular menu
     - Parameter animated: Animated determinates if update button is animated or not
     */
    public func setUpdateButtonAnimated(_ animated: Bool) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .refresh {
                        if animated {
                            button.startZRotation()
                        } else {
                            button.stopZRotation()
                        }
                        return
                    }
                }
            }
        }
    }
    
    /**
     This method update turn button rotation in circular menu
     - Parameter degrees: Degrees of rotation
     */
    public func setTurnButtonDegrees(_ degrees: CGFloat) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .compass {
                        UIView.animate(withDuration: 0.2, animations: {
                            button.transform = CGAffineTransform(rotationAngle: -(degrees.degreesToRadians+CGFloat(self.view_circularMenu.rotationAngle)))
                        })
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Data methods
    
    /**
     This method updates results
     */
    public func updateResults() {
        self.getResults()
    }
    
    /**
     This method stops update results
     */
    public func stopRequest() {
        self.setUpdateButtonAnimated(false)
        self.viewModel?.stopRequest()
    }
    
    /**
     This method checks radius with animation. If radius is less than citiesRadius application asks new results from server, if radius is over application shows cities
     */
    public func getResults() {
        self.stopRequest()
        if let radius = self.getRadius() {
            if radius < self.citiesRadius {
                self.clusteringInProgress = true
                if let mapView = self.mapView {
                    self.setUpdateButtonAnimated(true)
                    self.viewModel?.reloadResults(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude, radius: radius)
                    return
                }
            } else {
                self.clusteringInProgress = false
                self.addCityAnnotations()
            }
        }
        self.viewModel?.resetCars()
    }
    
    /**
     This method checks radius without animation
     */
    public func getResultsWithoutLoading() {
        if let radius = self.getRadius() {
            if radius < self.citiesRadius {
                self.clusteringInProgress = true
                self.viewModel?.reloadResults(latitude: self.mapView.camera.target.latitude, longitude: self.mapView.camera.target.longitude, radius: radius)
            } else {
                self.clusteringInProgress = false
                self.addCityAnnotations()
            }
        }
    }
    
    /**
     This method adds city annotations
     */
    public func addCityAnnotations() {
        if clusteringInProgress == false {
            self.mapView.clear()
            self.clusterManager.clearItems()
            var annotationsArray: [CityAnnotation] = []
            var bookedCity: City?
            var nearestCity: City?
            if let carBooked = self.viewModel?.carBooked {
                var bookedDistance: CLLocationDistance?
                for city in CoreController.shared.cities {
                    if viewModel?.carTrip != nil {
                        if viewModel?.carTrip?.car.value?.parking == false {
                        let locationManager = LocationManager.sharedInstance
                        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                            if let location = city.location, let location2 = locationManager.lastLocationCopy.value {
                                let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).distance(from:  CLLocation(latitude: location2.coordinate.latitude, longitude: location2.coordinate.longitude))
                                if bookedDistance == nil {
                                    bookedDistance = distance
                                    bookedCity = city
                                } else {
                                    if bookedDistance ?? 0 > distance {
                                        bookedDistance = distance
                                        bookedCity = city
                                    }
                                }
                            }
                        }
                        } else {
                                if let location = city.location, let location2 = viewModel?.carTrip?.car.value?.location {
                                    let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).distance(from:  CLLocation(latitude: location2.coordinate.latitude, longitude: location2.coordinate.longitude))
                                    if bookedDistance == nil {
                                        bookedDistance = distance
                                        bookedCity = city
                                    } else {
                                        if bookedDistance ?? 0 > distance {
                                            bookedDistance = distance
                                            bookedCity = city
                                        }
                                    }
                                }
                        }
                    } else {
                        if let location = city.location, let location2 = carBooked.location {
                            let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).distance(from:  CLLocation(latitude: location2.coordinate.latitude, longitude: location2.coordinate.longitude))
                            if bookedDistance == nil {
                                bookedDistance = distance
                                bookedCity = city
                            } else {
                                if bookedDistance ?? 0 > distance {
                                    bookedDistance = distance
                                    bookedCity = city
                                }
                            }
                        }
                    }
                }
            }
            if let nearestCar = self.viewModel?.nearestCar.value {
                var nearestDistance: CLLocationDistance?
                for city in CoreController.shared.cities {
                    if let location = city.location, let location2 = nearestCar.location {
                        let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude).distance(from:  CLLocation(latitude: location2.coordinate.latitude, longitude: location2.coordinate.longitude))
                        if nearestDistance == nil {
                            nearestDistance = distance
                            nearestCity = city
                        } else {
                            if nearestDistance ?? 0 > distance {
                                nearestDistance = distance
                                nearestCity = city
                            }
                        }
                    }
                }
            }
            for city in CoreController.shared.cities {
                if let location = city.location {
                    let annotation = CityAnnotation(position: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                    annotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                    annotation.city = city
                    annotation.icon = annotation.getImage(bookedCity: bookedCity?.identifier == city.identifier ? true : false, nearestCity: nearestCity?.identifier == city.identifier && viewModel?.carBooked == nil ? true : false)
                    annotation.map = mapView
                    annotationsArray.append(annotation)
                }
            }
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                self.showUserPositionVisible(true)
            } else {
                self.showUserPositionVisible(false)
            }
        }
    }
    
    /**
     This method adds city polygons
     */
    public func addPolygons()
    {
        if clusteringInProgress == true
        {
            for polygon in CoreController.shared.polygons {
                let rect = GMSMutablePath()
                
                for coordinate in polygon.coordinates
                {
                    rect.add(coordinate)
                }
                
                let polygon = GMSPolygon(path: rect)
                polygon.fillColor = ColorBrand.green.value.withAlphaComponent(0.1)
                polygon.strokeColor = ColorBrand.green.value
                polygon.strokeWidth = 2
                polygon.map = self.mapView
            }
        }
    }
    
    
    // MARK: - Map methods
    
    /**
     This method setups map and cluster manager
     */
    public func setupMap() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
        self.mapView.delegate = self
        self.showUserPositionVisible(false)
        self.setUserPositionButtonVisible(false)
        // User
        self.userAnnotation.icon = userAnnotation.image
        self.userAnnotation.zIndex = 2
        let locationManager = LocationManager.sharedInstance
        locationManager.lastLocationCopy.asObservable()
            .subscribe(onNext: {[weak self] (_) in
                DispatchQueue.main.async {
                    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        self?.showUserPositionVisible(true)
                        if self?.lastLocation?.coordinate.latitude != locationManager.lastLocationCopy.value?.coordinate.latitude && self?.lastLocation?.coordinate.longitude != locationManager.lastLocationCopy.value?.coordinate.longitude {
                            if let location = self?.selectedCar?.location {
                                self?.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                    self?.routeSteps = steps
                                    self?.drawRoutes(steps: steps)
                                })
                            } else if self?.viewModel?.carTrip != nil && self?.viewModel?.carTrip?.car.value?.parking == true {
                                if let location = self!.viewModel?.carTrip?.car.value?.location {
                                    self?.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                        self?.routeSteps = steps
                                        self?.drawRoutes(steps: steps)
                                    })
                                }
                            } else if self?.viewModel?.carBooking != nil {
                                if let location = self!.viewModel?.carBooking?.car.value?.location {
                                    self?.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                                        self?.routeSteps = steps
                                        self?.drawRoutes(steps: steps)
                                    })
                                }
                            }
                        }
                        self?.lastLocation = locationManager.lastLocationCopy.value
                    } else {
                        self?.showUserPositionVisible(false)
                    }
                }
            })
        // Italy
        let coordinateNorthEast = CLLocationCoordinate2DMake(35.4897, 6.62672)
        let coordinateSouthWest = CLLocationCoordinate2DMake(47.092, 18.7976)
        let bounds = GMSCoordinateBounds(coordinate: coordinateNorthEast, coordinate: coordinateSouthWest)
        let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        self.mapView.moveCamera(cameraUpdate)
        self.getResults()
    }
    
    /**
     This method checks user position. The application shows his position if user has already authorized the application and he hasn't a car trip or a car booking
     */
    public func checkUserPosition() {
        let locationManager = LocationManager.sharedInstance
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let userLocation = locationManager.lastLocationCopy.value {
                self.showUserPositionVisible(true)
                self.setUserPositionButtonVisible(true)
                self.checkedUserPosition = true
                if self.viewModel?.carTrip?.car.value?.parking == true { }
                else {
                    self.centerMap(on: userLocation, zoom: 16.5, animated: false)
                }
                return
            }
        }
        self.checkedUserPosition = true
        locationManager.getLocation(completionHandler: { (location, error) in
            if location != nil {
                self.showUserPositionVisible(true)
                self.setUserPositionButtonVisible(true)
                if self.viewModel?.carTrip?.car.value?.parking == true { }
                else {
                    self.centerMap(on: location!, zoom: 16.5, animated: false)
                }

            }
        })
    }
    
    /**
     This method checks user position when user opens the app from foreground
     */
    public func checkUserPositionFromForeground() {
        self.view_searchBar.updateInterface()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.showUserPositionVisible(true)
            self.setUserPositionButtonVisible(true)
        } else {
            self.showUserPositionVisible(false)
            self.setUserPositionButtonVisible(false)
        }
        self.getResults()
    }
    
    /**
     This method gets map center coordinate
     */
    public func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.mapView.center
        let centerCoordinate = self.mapView.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    /**
     This method gets map top center coordinate
     */
    public func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        let topCenterCoor = self.mapView.convert(CGPoint(x: self.mapView.frame.size.width / 2.0, y: 0), from: self.mapView)
        let point = self.mapView.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    /**
     This method gets map radius
     */
    public func getRadius() -> CLLocationDistance? {
        let centerCoordinate = self.getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
    
    /**
     This method centers map on user position or shows an error message
     */
    public func centerMap() {
        let locationManager = LocationManager.sharedInstance
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let userLocation = locationManager.lastLocationCopy.value {
                self.centerMap(on: userLocation, zoom: 16.5, animated: true)
                return
            }}
        self.showLocalizationAlert(message: "alert_centerMapMessage".localized())
    }
    
    /**
     This method centers map on position with zoom
     - Parameter position: Location in which the map has to be centered
     - Parameter zoom: Zoom level of the map
     - Parameter animated: Animated determinates if the action is animated or not
     */
    public func centerMap(on position: CLLocation, zoom: Float, animated: Bool) {
        let location = CLLocationCoordinate2DMake(position.coordinate.latitude, position.coordinate.longitude)
        let newCamera = GMSCameraPosition.camera(withTarget: location, zoom: zoom)
        let update = GMSCameraUpdate.setCamera(newCamera)
        if animated {
            self.mapView.animate(with: update)
        } else {
            self.mapView.moveCamera(update)
        }
    }
    
    /**
     This method turns map toward the north
     */
    public func turnMap() {
        let newCamera = GMSCameraPosition.camera(withLatitude: self.mapView.camera.target.latitude,
                                                 longitude: self.mapView.camera.target.longitude,
                                                 zoom: self.mapView.camera.zoom,
                                                 bearing: 0,
                                                 viewingAngle: self.mapView.camera.viewingAngle)
        self.mapView.animate(to: newCamera)
    }
    
    /**
     This method shows or hide user position
     - Parameter visible: Visible determinates if user position is shown or not
     */
    public func showUserPositionVisible(_ visible: Bool) {
        if visible {
            if let radius = self.getRadius() {
                if radius < citiesRadius || (self.viewModel?.carTrip == nil || self.viewModel?.carTrip?.car.value?.parking == true) {
                    let locationManager = LocationManager.sharedInstance
                    if let userLocation = locationManager.lastLocationCopy.value {
                        self.userAnnotation.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                        self.userAnnotation.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                        self.userAnnotation.updateImage(carTrip: self.viewModel?.carTrip)
                        self.userAnnotation.icon = userAnnotation.image
                        self.userAnnotation.map = self.mapView
                        return
                    }
                }
            }
        }
        self.userAnnotation.map = nil
    }
    
    // MARK: - Alert methods
    
    /**
     This method shows a general error message
     */
    public func showGeneralAlert() {
        let dialog = ZAlertView(title: nil, message: "alert_generalError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
            alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    /**
     This method shows a localization alert message (user can open settings from it)
     */
    public func showLocalizationAlert(message: String) {
        let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                                    }
        },
                                cancelButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    /**
     This method shows a login alert message (user can open login from it)
     */
    public func showLoginAlert() {
        let dialog = ZAlertView(title: nil, message: "alert_loginError".localized(), isOkButtonLeft: false, okButtonText: "btn_login".localized(), cancelButtonText: "btn_cancel".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    Router.from(self,viewModel: ViewModelFactory.login()).execute()
        },
                                cancelButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    // MARK: - Route methods
    
    public func drawRoutes(steps: [RouteStep]) {
        DispatchQueue.main.async {
            self.routeSteps = steps
            for polyline in self.routePolylines {
                polyline.map = nil
            }
            self.routePolylines = []
            if self.viewModel?.carTrip?.car.value?.parking == false {
                return
            }
            if steps.count > 0 {
                let points = steps[0].points
                if let distance = steps[0].distance, let duration = steps[0].duration {
                    self.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                }
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor(hexString: "#336633")
                polyline.strokeWidth = 10
                polyline.spans = GMSStyleSpans(polyline.path!, [GMSStrokeStyle.solidColor(UIColor(hexString: "#336633")), GMSStrokeStyle.solidColor(UIColor.clear)], [5, 5], GMSLengthKind.rhumb)
                polyline.map = self.mapView
                self.routePolylines.append(polyline)
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    // MARK: - Map delegate
    
    /**
     This method is called when map is moved: it updates turn button in circular menu and stop request and research
     */
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.view_searchBar.stopSearchBar()
        if clusteringInProgress == true {
            self.setUpdateButtonAnimated(true)
        }
    }
    
    /**
     This method is called when map is moved: it updates turn button in circular menu and stop request and research
     */
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.view_searchBar.stopSearchBar()
    }
    
    /**
     This method is called when map ended moving: it updates turn button in circular menu and get results
     */
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.getResults()
    }
    
    /**
     This method is called when user taps marker: depending on the type of marker zoom actions or popup displays are performed
     */
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cityAnnotation = marker as? CityAnnotation {
            self.drawRoutes(steps: self.routeSteps)
            if let location = cityAnnotation.city?.location {
                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: 11.5, animated: true)
            }
        } else if let carAnnotation = marker.userData as? CarAnnotation {
            let car = carAnnotation.car
            if let bookedCar = self.viewModel?.carBooked {
                if car.plate != bookedCar.plate {
                    let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupBookedMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                } else {
                    if let location = car.location {
                        let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        self.centerMap(on: newLocation, zoom: 18.5, animated: true)
                    }
                }
                return true
            }
            if car.plate != self.selectedCar?.plate {
                self.drawRoutes(steps: self.routeSteps)
            }
            if let location = car.location {
                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: 18.5, animated: true)
            }
            self.view_carPopup.updateWithCar(car: car)
            if routeSteps.count > 0 {
                if let distance = routeSteps[0].distance, let duration = routeSteps[0].duration {
                    self.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
                }
            }
            self.view_carPopup.viewModel?.type.value = .car
            self.view.layoutIfNeeded()
            UIView .animate(withDuration: 0.2, animations: {
                if car.type.isEmpty {
                    self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight
                } else if car.type.contains("\n") {
                    self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 55
                } else {
                    self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 40
                }
                self.view_carPopup.alpha = 1.0
                self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                self.view.layoutIfNeeded()
                self.selectedCar = car
                if let location = car.location {
                    self.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
                        self.routeSteps = steps
                        self.drawRoutes(steps: steps)
                    })
                }
            })
        } else if let feedAnnotation = marker.userData as? FeedAnnotation {
            let feed = feedAnnotation.feed
            if let location = feed.feedLocation {
                let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.0002, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: 18.5, animated: true)
            }
            self.view_carPopup.updateWithFeed(feed: feed)
            self.view_carPopup.viewModel?.type.value = .feed
            self.view.layoutIfNeeded()
            UIView .animate(withDuration: 0.2, animations: {
                self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 90
                self.view_carPopup.alpha = 1.0
                self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                self.view.layoutIfNeeded()
                self.selectedFeed = feed
            })
        } else {
            let location = marker.position
            var zoom = self.mapView.camera.zoom
            zoom += 2
            let newLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.centerMap(on: newLocation, zoom: zoom, animated: true)
        }
        return true
    }
}
