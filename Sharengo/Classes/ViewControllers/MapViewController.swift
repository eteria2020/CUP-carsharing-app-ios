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

/** The Map class provides features related to display content on a map. These includes:
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
    fileprivate var closeCarPopupHeight: CGFloat = 0.0
    fileprivate var checkedUserPosition: Bool = false
    fileprivate let carPopupDistanceOpenDoors: Int = 50
    fileprivate let clusteringRadius: Double = 35000
    fileprivate var clusteringInProgress: Bool = false
    fileprivate var selectedCar: Car?
    fileprivate var selectedFeed: Feed?
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var clusterManager: GMUClusterManager!
    var viewModel: MapViewModel?
    var carTripTimeStart: Date?
    
    // MARK: - ViewModel methods
    
    /**
     Lorem ipsum dolor sit amet.
     
     @param bar Consectetur adipisicing elit.
     
     @return Sed do eiusmod tempor.
    */
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MapViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.array_annotations.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    if self?.clusteringInProgress == true {
                        self?.mapView.clear()
                        self?.clusterManager.clearItems()
                        for annotation in array {
                            self?.clusterManager.add(annotation)
                        }
                        self?.clusterManager.cluster()
                    }
                    self?.setUpdateButtonAnimated(false)
                    if let car = self?.selectedCar {
                        self?.view_carPopup.updateWithCar(car: car)
                    }
                    if let allCars = self?.viewModel?.allCars {
                        self?.view_searchBar.viewModel?.allCars = allCars
                    }
                }
            }).addDisposableTo(disposeBag)
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
                if self?.viewModel?.carBooked != nil {
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
    
    override func viewDidLoad() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                if self != nil {
                    Router.exit(self!)
                }
                self?.view_searchBar.endEditing(true)
                self?.closeCarPopup()
            case .menu:
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
                self?.view_searchBar.endEditing(true)
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
                if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
                    self?.showLoginAlert()
                    return
                }
                if let distance = car.distance, let distanceOpenDoors = self?.carPopupDistanceOpenDoors {
                    if Int(distance.rounded()) <= distanceOpenDoors {
                        self?.openCar(car: car)
                    } else {
                        let dialog = ZAlertView(title: nil, message: "alert_carPopupDistanceMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                } else {
                    self?.showLocalizationAlert(message: "alert_carPopupLocalizationMessage".localized())
                }
            case .book(let car):
                self?.bookCar(car: car)
            case .car:
                if let location = self?.viewModel?.nearestCar?.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self?.centerMap(on: newLocation, zoom: 20)
                    self?.viewModel?.showCars = true
                    self?.setCarsButtonVisible(true)
                    self?.updateResults()
                } else {
                    let locationController = LocationController.shared
                    if locationController.isAuthorized == true && locationController.currentLocation != nil {
                    } else {
                        self?.showLocalizationAlert(message: "alert_centerMapMessage".localized())
                    }
                }
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
                if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
                    self?.showLoginAlert()
                    return
                }
                if let distance = car.distance, let distanceOpenDoors = self?.carPopupDistanceOpenDoors {
                    if Int(distance.rounded()) <= distanceOpenDoors {
                        self?.openCar(car: car)
                    } else {
                        let dialog = ZAlertView(title: nil, message: "alert_carPopupDistanceMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                } else {
                    self?.showLocalizationAlert(message: "alert_carPopupLocalizationMessage".localized())
                }
            case .delete:
                let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupDeleteMessage".localized(), isOkButtonLeft: false, okButtonText: "btn_yes".localized(), cancelButtonText: "btn_no".localized(),
                                        okButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                                            self?.deleteBookCar()
                },
                                        cancelButtonHandler: { alertView in
                                            alertView.dismissAlertView()
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
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
                    self?.centerMap(on: location, zoom: 17)
                }
                self?.view_searchBar.updateCollectionView(show: false)
                if self?.view_searchBar.viewModel?.speechInProgress.value == true {
                    self?.view_searchBar.viewModel?.speechInProgress.value = false
                    if #available(iOS 10.0, *) {
                        self?.view_searchBar.viewModel?.speechController.manageRecording()
                    }
                }
            case .car(let car):
                if let location = car.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.00015, longitude: location.coordinate.longitude)
                    self?.centerMap(on: newLocation, zoom: 20)
                }
                self?.view_carPopup.updateWithCar(car: car)
                self?.view.layoutIfNeeded()
                UIView .animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0
                    } else {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0 + 40
                    }
                    self?.view_carPopup.alpha = 1.0
                    self?.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self?.view.layoutIfNeeded()
                })
                self?.view_searchBar.updateCollectionView(show: false)
                if self?.view_searchBar.viewModel?.speechInProgress.value == true {
                    self?.view_searchBar.viewModel?.speechInProgress.value = false
                    if #available(iOS 10.0, *) {
                        self?.view_searchBar.viewModel?.speechController.manageRecording()
                    }
                }
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // Map
        self.setupMap()
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.didAuthorized) { [weak self] _ in
            let locationController = LocationController.shared
            if locationController.isAuthorized, let userLocation = locationController.currentLocation {
                self?.mapView?.isMyLocationEnabled = true
                self?.setUserPositionButtonVisible(true)
                self?.centerMap(on: userLocation, zoom: 20)
            }
        }
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.didUnAuthorized) { [weak self] _ in
            let locationController = LocationController.shared
            if !locationController.isAuthorized && UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
                self?.mapView?.isMyLocationEnabled = false
                self?.setUserPositionButtonVisible(false)
            }
        }
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.locationDidUpdate) { [weak self] _ in
            self?.viewModel?.manageAnnotations()
            if let carAnnotation = self?.mapView.selectedMarker as? CarAnnotation {
                if let car = carAnnotation.car {
                    self?.view_carPopup.updateWithCar(car: car)
                    self?.view.layoutIfNeeded()
                }
            }
        }
        NotificationCenter.default.addObserver(forName:
        NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.view_searchBar.updateInterface()
            let locationController = LocationController.shared
            if locationController.isAuthorized && locationController.currentLocation != nil {
                self.mapView?.isMyLocationEnabled = true
                self.setUserPositionButtonVisible(true)
            } else {
                self.mapView?.isMyLocationEnabled = false
                self.setUserPositionButtonVisible(false)
            }
            self.getResults()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.updateCarData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.closeCarBookingPopupView), name: NSNotification.Name(rawValue: "closeCarBookingPopupView"), object: nil)
        self.setCarsButtonVisible(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.checkedUserPosition {
            self.checkUserPosition()
        } else {
            self.checkedUserPosition = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCarData()
        if let feed = self.selectedFeed {
            self.view_carPopup.updateWithFeed(feed: feed)
        }
    }
    
    // MARK: - Update methods
    
    @objc fileprivate func updateCarData() {
        if let carTrip = CoreController.shared.allCarTrips.first {
            self.carTripTimeStart = carTrip.timeStart
            carTrip.car.asObservable()
                .subscribe(onNext: {[weak self] (car) in
                    DispatchQueue.main.async {
                        if let car = car {
                            if carTrip.id != self?.viewModel?.carTrip?.id {
                                // Open
                                car.booked = true
                                car.opened = true
                                self?.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                self?.view_carBookingPopup.alpha = 1.0
                                self?.viewModel?.carBooked = car
                                self?.viewModel?.carTrip = carTrip
                                self?.getResultsWithoutLoading()
                                if let location = car.location {
                                    let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                    self?.centerMap(on: newLocation, zoom: 20)
                                }
                                if self?.viewModel?.carBooked != nil && self?.viewModel?.showCars == false {
                                    DispatchQueue.main.async {
                                        self?.setCarsButtonVisible(true)
                                        self?.viewModel?.showCars = true
                                        self?.updateResults()
                                    }
                                }
                            } else {
                                // Update
                                car.booked = true
                                car.opened = true
                                self?.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                                self?.viewModel?.carBooked = car
                                self?.viewModel?.carTrip = carTrip
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
        } else if self.view_carBookingPopup.alpha == 1.0 && self.view_carBookingPopup?.viewModel?.carTrip != nil {
            let dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                if self.view_carBookingPopup?.viewModel?.carTrip != nil {
                    let carTrip = self.view_carBookingPopup!.viewModel!.carTrip!
                    carTrip.timeStart = self.carTripTimeStart
                    // Close
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
                    self.getResultsWithoutLoading()
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
                                    // Open
                                    car.booked = true
                                    self?.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                    self?.view_carBookingPopup.alpha = 1.0
                                    self?.viewModel?.carBooked = car
                                    self?.viewModel?.carBooking = carBooking
                                    self?.getResultsWithoutLoading()
                                    if let location = car.location {
                                        let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                         self?.centerMap(on: newLocation, zoom: 20)
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
            self.closeCarBookingPopupView()
        }
        
        if let selectedMarker = self.mapView.selectedMarker
        {
            if let carAnnotation = selectedMarker as? CarAnnotation {
                if let car = carAnnotation.car {
                    self.view_carPopup.updateWithCar(car: car)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        if self.viewModel?.carBooked != nil && self.viewModel?.showCars == false {
            DispatchQueue.main.async {
                self.setCarsButtonVisible(true)
                self.viewModel?.showCars = true
                self.updateResults()
            }
        }
    }
    
    @objc func closeCarBookingPopupView() {
        if self.view_carBookingPopup.alpha == 1.0 && self.view_carBookingPopup?.viewModel?.carBooking != nil {
            let dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                // Close
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
                self.getResultsWithoutLoading()
            }
        }
    }
    
    // MARK: - CarPopup methods
    
    fileprivate func closeCarPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.selectedCar = nil
            self.view_carPopup.alpha = 0.0
            self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - CarBookingPopup methods
    
    fileprivate func openCar(car: Car) {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.showLoginAlert()
            return
        }
        self.showLoader()
        self.apiController.openCar(car: car)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200 {
                        let carTrip = CarTrip(car: car)
                        DispatchQueue.main.async {
                            self.hideLoader()
                            car.booked = true
                            car.opened = true
                            carTrip.car.value = car
                            self.closeCarPopup()
                            self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                            self.view_carBookingPopup.alpha = 1.0
                            self.viewModel?.carBooked = car
                            self.viewModel?.carTrip = carTrip
                            self.getResultsWithoutLoading()
                            CoreController.shared.updateData()
                        }
                    }
                case .error(_):
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.hideLoader()
                        var message = "alert_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "alert_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func bookCar(car: Car) {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.showLoginAlert()
            return
        }
        self.showLoader()
        self.apiController.bookCar(car: car)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        if let id = data["reservation_id"] as? Int {
                            self.apiController.getCarBooking(id: id)
                                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                                .subscribe { event in
                                    switch event {
                                    case .next(let response):
                                        let dispatchTime = DispatchTime.now() + 0.5
                                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                            if response.status == 200, let data = response.array_data {
                                                if let carBookings = [CarBooking].from(jsonArray: data) {
                                                    if let carBooking = carBookings.first {
                                                        DispatchQueue.main.async {
                                                            self.hideLoader()
                                                            car.booked = true
                                                            carBooking.car.value = car
                                                            self.closeCarPopup()
                                                            self.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                                            self.view_carBookingPopup.alpha = 1.0
                                                            self.viewModel?.carBooked = car
                                                            self.viewModel?.carBooking = carBooking
                                                            self.getResultsWithoutLoading()
                                                            CoreController.shared.updateData()
                                                        }
                                                    } else {
                                                        self.hideLoader()
                                                        self.showGeneralAlert()
                                                    }
                                                } else {
                                                    self.hideLoader()
                                                    self.showGeneralAlert()
                                                }
                                            } else {
                                                self.hideLoader()
                                                self.showGeneralAlert()
                                            }
                                        }
                                    default:
                                        break
                                    }
                                }.addDisposableTo(CoreController.shared.disposeBag)
                        } else {
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                self.hideLoader()
                                self.showGeneralAlert()
                            }
                        }
                    } else {
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            self.hideLoader()
                            let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    }
                case .error(_):
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.hideLoader()
                        var message = "alert_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "alert_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    fileprivate func deleteBookCar() {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.showLoginAlert()
            return
        }
        if let carBooking = self.viewModel?.carBooking {
            self.showLoader()
            self.apiController.deleteCarBooking(carBooking: carBooking)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200 {
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                self.hideLoader()
                                let confirmDialog = ZAlertView(title: nil, message: "alert_carBookingPopupConfirmDeleteMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    self.closeCarBookingPopupView()
                                    CoreController.shared.currentCarBooking = nil
                                    CoreController.shared.updateData()
                                })
                                confirmDialog.allowTouchOutsideToDismiss = false
                                confirmDialog.show()
                            }
                        } else {
                            let dispatchTime = DispatchTime.now() + 0.5
                            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                self.hideLoader()
                                let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                dialog.show()
                            }
                        }
                    case .error(_):
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            self.hideLoader()
                            var message = "alert_generalError".localized()
                            if Reachability()?.isReachable == false {
                                message = "alert_connectionError".localized()
                            }
                            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    default:
                        break
                    }
                }.addDisposableTo(self.disposeBag)
        }
    }
    
    // MARK: - CircularMenu methods
    
    fileprivate func setUserPositionButtonVisible(_ visible: Bool) {
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
    
    fileprivate func setCarsButtonVisible(_ visible: Bool) {
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
    
    fileprivate func setUpdateButtonAnimated(_ animated: Bool) {
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
    
    fileprivate func setTurnButtonDegrees(_ degrees: CGFloat) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .compass {
                        UIView.animate(withDuration: 0.2, animations: {
                            button.transform = CGAffineTransform(rotationAngle: -(degrees.degreesToRadians))
                        })
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Data methods
    
    fileprivate func updateResults() {
        self.getResults()
    }
    
    fileprivate func stopRequest() {
        self.setUpdateButtonAnimated(false)
        self.viewModel?.stopRequest()
    }
    
    fileprivate func getResults() {
        self.stopRequest()
        if let radius = self.getRadius() {
            if radius < clusteringRadius {
                // TODO GOOGLE
                self.clusteringInProgress = true
                if let mapView = self.mapView {
                    self.setUpdateButtonAnimated(true)
                    self.viewModel?.reloadResults(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude, radius: radius)
                    return
                }
            } else {
                self.clusteringInProgress = false
                self.addCityAnnotations()
                self.clusteringInProgress = false
            }
        }
        self.viewModel?.resetCars()
    }
    
    fileprivate func getResultsWithoutLoading() {
        if let radius = self.getRadius() {
            if radius < self.clusteringRadius {
                self.viewModel?.reloadResults(latitude: self.mapView.camera.target.latitude, longitude: self.mapView.camera.target.longitude, radius: radius)
            }
        }
    }
    
    fileprivate func addCityAnnotations() {
        if clusteringInProgress == false {
            self.mapView.clear()
            self.clusterManager.clearItems()
            var annotationsArray: [CityAnnotation] = []
            for city in CoreController.shared.cities {
                if let location = city.location {
                    let annotation = CityAnnotation(position: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                    annotation.city = city
                    annotation.icon = annotation.getImage()
                    annotation.map = mapView
                    annotationsArray.append(annotation)
                }
            }
        }
    }
    
    // MARK: - Map methods
    
    fileprivate func setupMap() {
        self.mapView.delegate = self
        if UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
            self.mapView.isMyLocationEnabled = false
            self.setUserPositionButtonVisible(false)
        }
    }
    
    fileprivate func checkUserPosition() {
        let locationController = LocationController.shared
        if locationController.isAuthorized, let userLocation = locationController.currentLocation {
            self.mapView?.isMyLocationEnabled = true
            self.setUserPositionButtonVisible(true)
            self.checkedUserPosition = true
            if self.viewModel?.carTrip == nil && self.viewModel?.carBooking == nil {
                self.centerMap(on: userLocation, zoom: 20)
            }
        } else if !UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
            locationController.requestLocationAuthorization(handler: { (status) in
                UserDefaults.standard.set(true, forKey: "FirstCheckUserPosition")
                self.checkedUserPosition = true
            })
        }
    }
    
    fileprivate func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.mapView.center
        let centerCoordinate = self.mapView.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    fileprivate func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        let topCenterCoor = self.mapView.convert(CGPoint(x: self.mapView.frame.size.width / 2.0, y: 0), from: self.mapView)
        let point = self.mapView.projection.coordinate(for: topCenterCoor)
        return point
    }

    fileprivate func getRadius() -> CLLocationDistance? {
        let centerCoordinate = self.getCenterCoordinate()
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        return round(radius)
    }
    
    fileprivate func centerMap() {
        let locationController = LocationController.shared
        if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
            self.centerMap(on: userLocation, zoom: 20)
        } else {
            self.showLocalizationAlert(message: "alert_centerMapMessage".localized())
        }
    }
    
    fileprivate func centerMap(on position: CLLocation, zoom: Float) {
        // TODO GOOGLE: manca lo span!
        let location = CLLocationCoordinate2DMake(position.coordinate.latitude, position.coordinate.longitude)
//        let bounds = GMSCoordinateBounds(coordinate: location, coordinate: location)
//        let update = GMSCameraUpdate.fit(bounds)
        
//        self.mapView.animate(toLocation: location)
//        let dispatchTime = DispatchTime.now() + 0.2
//        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
//            self.mapView?.animate(toZoom: zoom)
//        }
        //self.mapView?.moveCamera(update)
        
        let newCamera = GMSCameraPosition.camera(withTarget: location,
                                                           zoom: zoom)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    fileprivate func turnMap() {
        let newCamera = GMSCameraPosition.camera(withLatitude: self.mapView.camera.target.latitude,
                                             longitude: self.mapView.camera.target.longitude,
                                             zoom: self.mapView.camera.zoom,
                                             bearing: 0,
                                             viewingAngle: self.mapView.camera.viewingAngle)
        self.mapView.animate(to: newCamera)
    }
    
    // MARK: - Alert methods
    
    fileprivate func showGeneralAlert() {
        let dialog = ZAlertView(title: nil, message: "alert_generalError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
            alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
    }
    
    fileprivate func showLocalizationAlert(message: String) {
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
    
    fileprivate func showLoginAlert() {
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
}

// MARK: - Map delegate

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.stopRequest()
        self.view_searchBar.stopSearchBar()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.getResults()
    }
    
    // TODO GOOGLE (cambiare grafica utente)
    // TODO GOOGLE (se c'è l'auto prenotata niente auto vicina in big)
    // TODO GOOGLE (pulse)
    // TODO GOOGLE (sistemare feeds)
    
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if annotation is FBAnnotationCluster {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.custom())
            } else {
                clusterView?.annotation = annotation
            }
            return clusterView
        } else {
            let annotationIdentifier = "AnnotationIdentifier"
            var annotationView: SVPulsingAnnotationView?
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? SVPulsingAnnotationView {
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            } else {
                annotationView = SVPulsingAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            annotationView?.outerPulseAnimationDuration = 1.5
            annotationView?.delayBetweenPulseCycles = 0.5
            annotationView?.annotationColor = UIColor.clear
            if let annotationView = annotationView {
                if let carAnnotation = annotationView.annotation as? CarAnnotation {
                    annotationView.image = carAnnotation.image
                    if carAnnotation.car?.nearest == true || carAnnotation.car?.booked == true || carAnnotation.car?.opened == true {
                        if carAnnotation.car?.booked == true || carAnnotation.car?.opened == true {
                            annotationView.annotationColor = Color.searchCarsBookedCar.value
                        } else if carAnnotation.car?.nearest == true {
                            if self.viewModel?.carBooked != nil {
                                annotationView.image = UIImage(named: "ic_auto")
                            } else {
                                annotationView.annotationColor = Color.searchCarsNearestCar.value
                            }
                        }
                    }
                } else if let feedAnnotation = annotationView.annotation as? FeedAnnotation {
                    annotationView.image = feedAnnotation.image
                } else if let cityAnnotation = annotationView.annotation as? CityAnnotation {
                    annotationView.image = cityAnnotation.image
                } else if annotationView.annotation is MKUserLocation {
                    annotationView.image = UIImage(named: "ic_user")
                }
            }
            return annotationView
        }
    }
    */
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cityAnnotation = marker as? CityAnnotation {
            if let location = cityAnnotation.city?.location {
                var zoom = self.mapView.camera.zoom
                zoom += 2
                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: zoom)
            }
        } else if let carAnnotation = marker.userData as? CarAnnotation {
            if let car = carAnnotation.car {
                if let bookedCar = self.viewModel?.carBooked {
                    if car.plate != bookedCar.plate {
                        let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupBookedMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                    return true
                }
                if let location = car.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.centerMap(on: newLocation, zoom: 20)
                }
                self.view_carPopup.updateWithCar(car: car)
                self.view_carPopup.viewModel?.type.value = .car
                self.view.layoutIfNeeded()
                UIView .animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight
                    } else {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 40
                    }
                    self.view_carPopup.alpha = 1.0
                    self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self.view.layoutIfNeeded()
                    self.selectedCar = car
                })
            }
        } else if let feedAnnotation = marker.userData as? FeedAnnotation {
            if let feed = feedAnnotation.feed {
                if let location = feed.feedLocation {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    self.centerMap(on: newLocation, zoom: 20)
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
            }
        } else {
            let location = marker.position
                var zoom = self.mapView.camera.zoom
                zoom += 2
                let newLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                self.centerMap(on: newLocation, zoom: zoom)
        }
        
        return true
    }
}
