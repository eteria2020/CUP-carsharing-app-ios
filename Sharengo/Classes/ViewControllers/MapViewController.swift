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

import Action
import MapKit
import DeviceKit
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
    
    /// User can open doors 300 meters down
    public let carPopupDistanceOpenDoors: Int = 800
    /// Map has to show cities 35000 meters up
    public let clusteringRadius: Double = 35000
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
    //    public var routeSteps: [RouteStep] = []
    public var stepPolyline: GMSPolyline? = nil
    /// Variable used to save route polylines
    public var routePolylines: [GMSPolyline] = []
    /// Variable used to save old location
    public var lastLocation: CLLocation?
    /// Variable used to save nearest car
    public var lastNearestCar: Car?
    /// Variable used to save nearest car route steps
    //    public var nearestCarRouteSteps: [RouteStep] = []
    public var nearestCarRoutePolyline: GMSPolyline? = nil
    ///car url for external open app
    public var carUrl : Car?
    /// Variable used to save if the login is already showed
    public var loginIsShowed: Bool = false
    /// Variable used to save if the intro is already showed
    public var introIsShowed: Bool = false
    /// Variable used to save if the tutorial is already showed
    public var tutorialIsShowed: Bool = true
    
    public var selectedPlate: String = ""
    
    func updatePolylineInfo()
    {
        if stepPolyline != nil
        {
            //  TODO: Rewrite here
            //            if  let distance = routeSteps[0].distance,
            //                let duration = routeSteps[0].duration
            //            {
            //                view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
            //            }
        }
    }
    
    func getRoute(fromLocation location: CLLocation)
    {
        viewModel?.getRoute(destination: location, completionClosure: { [weak self] polyline in
            self?.nearestCarRoutePolyline = nil
            self?.updateRoute(polyline)
        })
    }
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MapViewModel else {
            return
        }
        self.viewModel = viewModel
        // NearestCar
        viewModel.nearestCar.asObservable()
            .subscribe(onNext: {[weak self] (nearestCar) in
                
                if nearestCar == nil
                {
                    self?.nearestCarRoutePolyline = nil
                    if self?.viewModel?.carTrip == nil && self?.viewModel?.carBooking == nil
                    {
                        self?.updateRoute(nil)
                    }
                }
                else if self?.lastNearestCar?.location?.coordinate.latitude != nearestCar?.location?.coordinate.latitude && self?.lastNearestCar?.location?.coordinate.longitude != nearestCar?.location?.coordinate.longitude {
                    self?.lastNearestCar = nearestCar
                    
                    self?.nearestCarRoutePolyline = nil
                    if self?.viewModel?.carTrip == nil && self?.viewModel?.carBooking == nil
                    {
                        self?.getRoute(fromLocation: nearestCar!.location!)
                    }
                }
            }).disposed(by: disposeBag)
        viewModel.deepCar.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (deepCar) in
                if let car = deepCar{
                    var userLatitude: CLLocationDegrees = 0
                    var userLongitude: CLLocationDegrees = 0
                    let locationManager = LocationManager.sharedInstance
                    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        if let userLocation = locationManager.lastLocationCopy.value {
                            userLatitude = userLocation.coordinate.latitude
                            userLongitude = userLocation.coordinate.longitude
                        }
                    }
                    //CHIAMATA SOLO PER NOTIFICA A SERVER DELLA CALLING APP
                    CoreController.shared.apiController.searchCarURL(userLatitude: userLatitude, userLongitude:  userLongitude, plate: car.plate!, callingApp: CoreController.shared.callingApp as String, email: KeychainSwift().get("Username")?.removingPercentEncoding)
                        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe {event in
                            switch event {
                            case .next(let response):
                                if response.status == 200 {
                                    print("OK")
                                }
                                break
                            case .error(_):
                                print("errore bruttissimo")
                                break
                            case .completed:
                                self?.selectedPlate = ""
                                break
                            }}
                        .disposed(by: CoreController.shared.disposeBag)
                    
                    //self.viewModel?.deepCar.value = nil
                    if car.plate != self?.selectedCar?.plate
                    {
                        self?.drawRoutes(polyline: self?.stepPolyline)
                    }
                    if let location = car.location
                    {
                        let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        self?.centerMap(on: newLocation, zoom: 18.5, animated: true)
                    }
                    self?.view_carPopup.updateWithCar(car: car)
                    self?.updatePolylineInfo()
                    
                    self?.view_carPopup.viewModel?.type.value = .car
                    self?.view.layoutIfNeeded()
                    UIView .animate(withDuration: 0.2, animations: {
                        if car.type.isEmpty {
                            self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)!
                        } else if car.type.contains("\n") {
                            self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)! + 55//55
                        } else {
                            self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)! + 40//40
                        }
                        self?.view_carPopup.alpha = 1.0
                        self?.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                        self?.view.layoutIfNeeded()
                        self?.selectedCar = car
                        if let location = car.location
                        {
                            self?.getRoute(fromLocation: location)
                        }
                    })
                }
            }).disposed(by: disposeBag)
        // Annotations
        viewModel.array_annotations.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    if self?.clusteringInProgress == true {
                        self?.mapView.clear()
                        self?.clusterManager.clearItems()
                        self?.drawRoutes(polyline: self?.stepPolyline)
                        
                        for annotation in array {
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
                        self?.updatePolylineInfo()
                    }
                    if let allCars = self?.viewModel?.allCars {
                        self?.view_searchBar.viewModel?.allCars = allCars
                    }
                }
            }).disposed(by: disposeBag)
        // CarPopup
        self.btn_closeCarPopup.rx.tap.asObservable()
            .subscribe(onNext:{
                self.closeCarPopup()
            }).disposed(by: disposeBag)
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
            case .assistence:
                self?.launchAssistence()
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
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
        // NavigationBar
        // self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .empty, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                self?.view_searchBar.stopSearchBar()
                Router.exit(self!)
                self?.closeCarPopup()
                
            case .menu:
                self?.present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
                self?.closeCarPopup()
                
            case .empty: break
            }
        }).disposed(by: self.disposeBag)
        
        //checkUrlCar for external open APP
        if(selectedPlate != ""){
            
            CoreController.shared.apiController.searchCar(plate: selectedPlate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            self.carUrl = Car(json: data)
                            self.selectedCar = self.carUrl
                            self.view_carPopup.updateWithCar(car: self.carUrl!)
                            
                        }
                        break
                    case .error(_):
                        self.selectedPlate = ""
                        break
                    case .completed:
                        self.selectedPlate = ""
                        break
                    }
                }.disposed(by: CoreController.shared.disposeBag)
        }
        // CarPopup
        self.view_carPopup.bind(to: ViewModelFactory.carPopup(type: .car))
        self.view_carPopup.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .open(let car):
                
                
                // apri corsa da prenotazione popup basso
                var isBonus = false;
                if let dictionary = UserDefaults.standard.object(forKey: "keyReservationCar") as? [String: String] {
                    if car.plate == car.plate {
                        let carOnlyPlate: Car = Car()
                        if let bonusReservation = dictionary["bonusType"], let bonusValue = dictionary["bonusValue"]{
                            //bonus
                            var message = "aler_carPopupOpenDoorMessage".localized()
                            
                             if(bonusReservation != ""){
                                if bonusReservation == "unplug" {
                                    //settare messaggio con bonus
                                    message = "aler_carPopupOpenDoorMessageUnplug".localized()
                                }else{
                                    message = String(format: "aler_carPopupOpenDoorMessageBonus".localized(), bonusValue)
                                }
                                isBonus = true
                            }
                            
                            carOnlyPlate.plate = car.plate
                            
                            DispatchQueue.main.async {
                                let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                        okButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                            self?.openCar(car: carOnlyPlate, action: "open")
                                                            
                                },
                                                        cancelButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                if (isBonus){
                                    dialog.alertView.backgroundColor = ColorBrand.green.value
                                    isBonus = false
                                }
                                
                                dialog.show()
                                
                                
                            }
                        }
                        
                    }else {
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupBookedMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertViewTripped in
                                alertViewTripped.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                        return
                        
                    }
                }
                else {
                    
                    var message = "aler_carPopupOpenDoorMessage".localized()
                    
                    if(UserDefaults.standard.object(forKey: "keyReservationCar") == nil){
                        
                        self?.getCarDetail(plate: car.plate!, completionClosure: { (car1) in
                            debugPrint("Chiamata carDetail -->")
                            if let 🚙 = car1 {
                                let bonusFree = 🚙.bonus.filter({ (bonus) -> Bool in
                                    return bonus.status == true && bonus.value > 0
                                })
                                if bonusFree.count > 0  && bonusFree[0].value > 0{
                                    //cambiare messaggio con minuti
                                    message = String(format: "aler_carPopupOpenDoorMessageBonus".localized(), String(bonusFree[0].value))
                                    if bonusFree[0].type == "unplug"{
                                        message = "aler_carPopupOpenDoorMessageUnplug".localized()
                                        
                                    }
                                    isBonus = true
                                }
                                
                           
                            DispatchQueue.main.async {
                                let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                        okButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                            self?.openCar(car: 🚙, action: "open")
                                                            
                                },
                                                        cancelButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                if (isBonus){
                                    dialog.alertView.backgroundColor = ColorBrand.green.value
                                    
                                    isBonus = false
                                }
                                // dialog.messageAttributedString = NSMutableAttributedString().justify(text: message)
                                
                                dialog.show()
                            }
                            }
                        })
                        
                    }
                    
                }
                
                
                
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
        }).disposed(by: self.disposeBag)
        self.view_carPopup.alpha = 0.0
        self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
        switch Device.current.diagonal {
        case 3.5:
            self.closeCarPopupHeight = 160//160
        case 4:
            self.closeCarPopupHeight = 170//170
        case 4.7:
            self.closeCarPopupHeight = 185//185
        case 5.5:
            self.closeCarPopupHeight = 195//195
        case 5.8:
            self.closeCarPopupHeight = 200//200
        default:
            self.closeCarPopupHeight = 200//185
        }
        // CarBookingPopup
        self.view_carBookingPopup.bind(to: ViewModelFactory.carBookingPopup())
        self.view_carBookingPopup.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .open(let car):
                var isBonus = false;
                //apri macchina dopo la sosta
                if self?.viewModel?.carTrip?.car.value?.parking == true {
                    //                    self?.openCar(car: car, action: "unpark")
                    let message = "aler_carPopupOpenDoorUnparkMessage".localized()
                    let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                            okButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                self?.openCar(car: car, action: "unpark")
                                                
                    },
                                            cancelButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    
                } else {
                    // apri porte senza prenotazione da popup alto
                    var message = "aler_carPopupOpenDoorMessage".localized()
                    
                    if(UserDefaults.standard.object(forKey: "keyReservationCar") == nil){
                        
                        self?.getCarDetail(plate: car.plate!, completionClosure: { (car1) in
                            debugPrint("Chiamata carDetail -->")
                            if let 🚙 = car1 {
                                let bonusFree = 🚙.bonus.filter({ (bonus) -> Bool in
                                    return bonus.status == true && bonus.value > 0
                                })
                                if bonusFree.count > 0  && bonusFree[0].value > 0{
                                    //cambiare messaggio con minuti
                                    message = String(format: "aler_carPopupOpenDoorMessageBonus".localized(), String(bonusFree[0].value))
                                    if bonusFree[0].type == "unplug"{
                                        message = "aler_carPopupOpenDoorMessageUnplug".localized()
                                        
                                    }
                                    isBonus = true
                                }
                                
                            
                            DispatchQueue.main.async {
                                let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                        okButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                            self?.openCar(car: 🚙, action: "open")
                                                            
                                },
                                                        cancelButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                if (isBonus){
                                    dialog.alertView.backgroundColor = ColorBrand.green.value
                                    
                                    isBonus = false
                                }
                                dialog.show()
                                }
                            }
                        })
                        
                    }else{
                        if let dictionary = UserDefaults.standard.object(forKey: "keyReservationCar") as? [String: String] {
                            var message = "aler_carPopupOpenDoorMessage".localized()
                            let carOnlyPlate: Car = Car()
                            if car.plate == dictionary["carPlate"] {
                                if let bonusReservation = dictionary["bonusType"],let bonusValue = dictionary["bonusValue"] {
                                    //bonus
                                    
                                    if(bonusReservation != ""){
                                        if bonusReservation == "unplug" {
                                            //settare messaggio con bonus
                                            message = "aler_carPopupOpenDoorMessageUnplug".localized()
                                        }else{
                                            message = String(format: "aler_carPopupOpenDoorMessageBonus".localized(), bonusValue)
                                        }
                                    
                                        isBonus = true
                                    }
                                }
                                 carOnlyPlate.plate = dictionary["carPlate"]
                            }
                            
                            DispatchQueue.main.async {
                                let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                        okButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                            self?.openCar(car: carOnlyPlate, action: "open")
                                                            
                                },
                                                        cancelButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                })
                                dialog.allowTouchOutsideToDismiss = false
                                if (isBonus){
                                    dialog.alertView.backgroundColor = ColorBrand.green.value
                                    
                                    isBonus = false
                                }
                                dialog.show()
                                
                            }
                        }
                        
                    }
                    // self?.openCar(car: car, action: "open"
                }
            case .delete:
                self?.deleteBookCar()
            case .close(let car):
                self?.closeCar(car: car, action: "close")
            default: break
            }
        }).disposed(by: self.disposeBag)
        self.view_carBookingPopup.backgroundColor = Color.carBookingPopupBackground.value
        self.view_carBookingPopup.alpha = 0.0
        switch Device.current.diagonal {
        case 3.5:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 180
        case 4:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 200//195
        case 4.7:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 210
        case 5.5:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
        case 5.8:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
        default:
            self.view_carBookingPopup.constraint(withIdentifier: "carBookingPopupHeight", searchInSubviews: false)?.constant = 230
        }
        // SearchBar
        if(Device.current.diagonal > 5.5 || Device.current.diagonal < 0){
            //self.view_searchBar.isHidden = true
        }
 
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
                self?.updatePolylineInfo()
                self?.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)!  //0
                    } else if car.type.contains("\n") {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)! + 55//55
                    } else {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self?.closeCarPopupHeight)! + 40//40
                    }
                    self?.view_carPopup.alpha = 1.0
                    self?.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self?.view.layoutIfNeeded()
                    
                    if let location = car.location {
                        self?.getRoute(fromLocation: location)
                    }
                })
                self?.updateSpeechSearchBar()
            default: break
            }
        }).disposed(by: self.disposeBag)
        
        // Map
        self.setupMap()
        
        // NotificationCenter
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [unowned self] _ in
            self.checkUserPositionFromForeground()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateData"), object: nil, queue: OperationQueue.main) { [unowned self] _ in
            self.updateCarData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.closeCarBookingPopupView), name: NSNotification.Name(rawValue: "closeCarBookingPopupView"), object: nil)
        
        self.setCarsButtonVisible(false)

        if (Config().langAndCountry == "it_IT") {
            let message = "popup_message".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "MYSHARENGO", cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        self.launchFaq()
                                    },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                    })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
        
        /*if let car = viewModel?.allCars.filter({ (car) -> Bool in
         return car.plate?.lowercased().contains(plate) ?? false}){
         
         if let location = car[0].location {
         let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.00015, longitude: location.coordinate.longitude)
         self.centerMap(on: newLocation, zoom: 18.5, animated: true)
         }
         self.view_carPopup.updateWithCar(car: car[0])
         if self.routeSteps.count > 0 {
         if let distance = self.routeSteps[0].distance, let duration = self.routeSteps[0].duration {
         self.view_carPopup.updateWithDistanceAndDuration(distance: distance, duration: duration)
         }
         }
         self.view.layoutIfNeeded()
         UIView.animate(withDuration: 0.2, animations: {
         if car[0].type.isEmpty {
         self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self.closeCarPopupHeight)  //0
         } else if car[0].type.contains("\n") {
         self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self.closeCarPopupHeight) + 55//55
         } else {
         self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = (self.closeCarPopupHeight) + 40//40
         }
         self.view_carPopup.alpha = 1.0
         self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
         self.view.layoutIfNeeded()
         if let location = car[0].location {
         self.viewModel?.getRoute(destination: location, completionClosure: { (steps) in
         self.routeSteps = steps
         self.drawRoutes(steps: steps)
         })
         }
         })
         //self.updateSpeechSearchBar()
         
         }*/
        
        
        
    }
    
    func getCarDetail(plate : String, completionClosure: @escaping (Car?) ->()) {
        
        CoreController.shared.apiController.searchCar(plate: plate)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        let car = Car(json: data)
                        
                        completionClosure(car)
                        
                    }
                    else{
                        completionClosure(nil)
                        
                    }
                case .error(_):
                    completionClosure(nil)
                default:
                    break
                }
            }.disposed(by: CoreController.shared.disposeBag)
    }
    
    override public func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if !self.checkedUserPosition
        {
            self.checkUserPosition()
        }
        else
        {
            self.checkedUserPosition = true
        }
        
        if let plate = CoreController.shared.urlDeepLink
        {
            viewModel?.searchPlateAvailable(plate: plate)
            CoreController.shared.urlDeepLink = nil
        }
        
        CoreController.shared.tryToShowPushRequest()
        
        PushNotificationController.shared.requestPushNotifications()
        PushNotificationController.shared.evaluateLastNotification(from: self)
    }
    
    override public func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.updateCarData()
        
        if !self.loginIsShowed
        {
            self.loginIsShowed = true
            if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
                KeychainSwift().clear()
                let destination: OnBoardViewController = (Storyboard.main.scene(.onBoard))
                destination.bind(to: ViewModelFactory.onBoard(), afterLoad: true)
                self.navigationController?.pushViewController(destination, animated: false)
                self.introIsShowed = true
                
                return
            }
        }
        if !self.introIsShowed {
            let destination: IntroViewController  = (Storyboard.main.scene(.intro))
            destination.bind(to: ViewModelFactory.intro(), afterLoad: true)
            self.addChild(destination)
            self.view.addSubview(destination.view)
            self.view.layoutIfNeeded()
            let dispatchTime = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    if !self.tutorialIsShowed {
                        self.tutorialIsShowed = true
                        if UserDefaults.standard.bool(forKey: "TutorialShowed") == false {
                            let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
                            let viewModel = ViewModelFactory.tutorial()
                            destination.bind(to: viewModel, afterLoad: true)
                            self.present(destination, animated: true, completion: nil)
                            UserDefaults.standard.set(true, forKey: "TutorialShowed")
                        }
                    }
                }
            }
        }
        self.introIsShowed = true
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
    @objc public func updateCarData()
    {
        if let carTrip = CoreController.shared.allCarTrips.first
        {
            self.carTripTimeStart = carTrip.timeStart
            
            carTrip.updateCar {
                
                if let car = carTrip.car.value
                {
                    let notBookedAndNotShowing = self.viewModel?.carBooked != nil && self.viewModel?.showCars == false
                    
                    if carTrip.id != self.viewModel?.carTrip?.id
                    {
                        // Show
                        car.booked = true
                        car.opened = true
                        self.view_carBookingPopup.alpha = 1.0
                        self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                        self.viewModel?.carBooked = car
                        self.viewModel?.carTrip = carTrip
                        self.getResultsWithoutLoading()
                        
                        if car.parking == true
                        {
                            if let location = car.location
                            {
                                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                                self.centerMap(on: newLocation, zoom: 18.5, animated: true)
                            }
                            if let location = car.location
                            {
                                self.getRoute(fromLocation: location)
                            }
                        }
                        
                        if notBookedAndNotShowing
                        {
                            self.setCarsButtonVisible(true)
                            self.viewModel?.showCars = true
                            self.updateResults()
                        }
                    }
                    else
                    {
                        // Update
                        car.booked = true
                        car.opened = true
                        self.view_carBookingPopup.updateWithCarTrip(carTrip: carTrip)
                        self.viewModel?.carBooked = car
                        self.viewModel?.carTrip = carTrip
                        self.getResultsWithoutLoading()
                        
                        if notBookedAndNotShowing
                        {
                            self.setCarsButtonVisible(true)
                            self.viewModel?.showCars = true
                            self.updateResults()
                        }
                    }
                }
            }
        }
        else if self.view_carBookingPopup.alpha == 1.0 &&
            self.view_carBookingPopup?.viewModel?.carTrip != nil &&
            (!(self.view_carBookingPopup?.viewModel?.carTrip?.fake)! || (self.view_carBookingPopup?.viewModel?.carTrip?.seconds)! > 60)
        {
            let dispatchTime = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                
                if self.view_carBookingPopup?.viewModel?.carTrip != nil
                {
                    let carTrip = self.view_carBookingPopup!.viewModel!.carTrip!
                    carTrip.timeStart = self.carTripTimeStart
                    
                    // Hide
                    if let car = self.view_carBookingPopup?.viewModel?.carTrip?.car.value
                    {
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
                    
                    self.stepPolyline = self.nearestCarRoutePolyline        //  yes but why?
                    self.updateRoute(self.stepPolyline)
                }
            }
            
        }
        
        if let carBooking = CoreController.shared.allCarBookings.first
        {
           // if(self.view_carBookingPopup?.viewModel?.carTrip == nil){
            carBooking.car.asObservable().subscribe(onNext: {[weak self] (car) in
                
                DispatchQueue.main.async {
                    if let car = car
                    {
                        if carBooking.id != self?.viewModel?.carBooking?.id
                        {
                            if carBooking.timer != "<bold>00:00</bold> \("lbl_carBookingPopupTimeMinutes".localized())"
                            {
                                // Show
                                car.booked = true
                                
                                self?.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                self?.view_carBookingPopup.alpha = 1.0
                                self?.viewModel?.carBooked = car
                                self?.viewModel?.carBooking = carBooking
                                self?.getResultsWithoutLoading()
                                
                                let locationManager = LocationManager.sharedInstance
                                
                                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse
                                {
                                    if let userLocation = locationManager.lastLocationCopy.value
                                    {
                                        self?.centerMap(on: userLocation, zoom: 16.5, animated: false)
                                    }
                                }
                                
                                if let location = car.location
                                {
                                    self?.getRoute(fromLocation: location)
                                }
                                
                                if self?.viewModel?.carBooked != nil && self?.viewModel?.showCars == false
                                {
                                    self?.setCarsButtonVisible(true)
                                    self?.viewModel?.showCars = true
                                    self?.updateResults()
                                }
                            }
                        }
                        else
                        {
                            // Update
                            car.booked = true
                            self?.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                            self?.viewModel?.carBooked = car
                            self?.viewModel?.carBooking = carBooking
                            self?.getResultsWithoutLoading()
                            
                            if self?.viewModel?.carBooked != nil && self?.viewModel?.showCars == false
                            {
                                self?.setCarsButtonVisible(true)
                                self?.viewModel?.showCars = true
                                self?.updateResults()
                            }
                        }
                    }
                }
                
            }).disposed(by: self.disposeBag)
            //}
        }
        else if self.view_carBookingPopup.alpha == 1.0 &&
            self.view_carBookingPopup?.viewModel?.carBooking != nil
        {
            // Hide
            self.closeCarBookingPopupView()
        }
        
        if let car = self.selectedCar
        {
            self.view_carPopup.updateWithCar(car: car)
            self.updatePolylineInfo()
            
            self.view.layoutIfNeeded()
        }
        
        if  self.viewModel?.carBooked != nil &&
            self.viewModel?.showCars == false
        {
            self.setCarsButtonVisible(true)
            self.viewModel?.showCars = true
            self.updateResults()
        }
    }
    
    @objc public func updateTripData() {
        if let carTrip = CoreController.shared.allCarTrips.first {
            // CoreController.shared.stopFetchTrip()
            self.viewModel?.carTrip = carTrip
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
                                    self.getRoute(fromLocation: location)
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
        } else {
            
            self.viewModel?.carTrip = nil
            
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
                
                self.stepPolyline = self.nearestCarRoutePolyline    //  yes but why?
                self.updateRoute(self.stepPolyline)
                
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
            
            self.stepPolyline = self.nearestCarRoutePolyline    //  yes but why?
            self.updateRoute(self.stepPolyline)
            
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
            self.updatePolylineInfo()
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
        /*if let distance = car.distance {
         /* #if ISDEBUG
         #elseif ISRELEASE
         if Int(distance.rounded()) > self.carPopupDistanceOpenDoors {
         let dialog = ZAlertView(title: nil, message: "alert_carPopupDistanceMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
         alertView.dismissAlertView()
         })
         dialog.allowTouchOutsideToDismiss = false
         dialog.show()
         return
         }
         #endif*/
         } else {
         self.showLocalizationAlert(message: "alert_carPopupLocalizationMessage".localized())
         return
         }*/
        //self.showLoader()
        
        if let tripped = self.viewModel?.carTrip {
            if tripped.car.value?.plate != car.plate{
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupActiveTripOnOpenCar".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertViewTripped in
                        alertViewTripped.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
                return
            }
        }
        
        
        
        
        self.viewModel?.openCar(car: car, action: action, completionClosure: { (success, error,dataType) in
            
            if error != nil
            {
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
                }
            }
            else
            {
                if success
                {
                    CoreController.shared.startCheckOpenTripOperation()
                    
                    if let plate = car.plate
                    {
                        CoreController.shared.apiController.searchCar(plate: plate)
                            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                            .subscribe { event in
                                switch event {
                                case .next(let response):
                                    if response.status == 200, let data = response.dic_data
                                    {
                                        let car2 = Car(json: data)
                                        if action == "unpark" && self.viewModel?.carTrip != nil
                                        {
                                            car2?.parking = false
                                            car2?.opened = true
                                            car2?.booked = true
                                            DispatchQueue.main.async {
                                                self.viewModel!.carTrip!.car.value = car2
                                                self.view_carBookingPopup.updateWithCarTrip(carTrip: self.viewModel!.carTrip!)
                                            }
                                        }
                                        else
                                        {
                                            let carTrip = CarTrip(car: car2 ?? car)
                                            carTrip.setFake(fake: true)
                                            DispatchQueue.main.async {
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
                                                
                                                self.stepPolyline = self.nearestCarRoutePolyline    //  yes but why?
                                                self.updateRoute(self.stepPolyline)
                                            }
                                        }
                                    }
                                default:
                                    break
                                }
                            }.disposed(by: CoreController.shared.disposeBag)
                    }
                    else
                    {
                        let carTrip = CarTrip(car: car)
                        DispatchQueue.main.async {
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
                        }
                    }
                }
                else
                {
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        self.showGeneralAlert(type: dataType)
                    }
                }
            }
        })
    }
    
    public func closeCar(car: Car, action: String)
    {
        let dialog = ZAlertView(title: nil, message: "alert_closeCarPopoupConfirm".localized(), isOkButtonLeft: false, okButtonText: "btn_yes".localized(), cancelButtonText: "btn_no".localized(), okButtonHandler: { [unowned self] alertView in
            
            alertView.dismissAlertView()
            
            self.view_carBookingPopup.viewModel?.isCarClosing.value = true
            
            //  Control here re-enabling this button. We have no control externally
            //disable closeButton ivan
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: {
                self.view_carBookingPopup.viewModel?.isCarClosing.value = false
            })
            
            self.viewModel?.closeCar(car: car, action: action, completionClosure: { (success, error,dataType) in
                if error != nil
                {
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
                    }
                }
                else
                {
                    if success
                    {
                        CoreController.shared.startCheckCloseTripOperation(withCar: car)
                        
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            let confirmDialog = ZAlertView(title: nil, message: "alert_closeCarPopoup".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                
                                //CoreController.shared.updateCarBookings()
                                alertView.dismissAlertView()
                                self.closeCarBookingPopupView()
                                CoreController.shared.currentCarBooking = nil
                            })
                            confirmDialog.allowTouchOutsideToDismiss = false
                            confirmDialog.show()
                        }
                    }
                    else
                    {
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    }
                }
            })
            
            },  cancelButtonHandler: { alertView in
                alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
        
        
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
        
        if (self.viewModel?.carTrip) != nil {
            let dispatchTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupActiveTripOnReservation".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertViewTripped in
                    alertViewTripped.dismissAlertView()
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
            return
        }
        if let bookedCar = self.viewModel?.carBooked {
            if car.plate != bookedCar.plate {
                let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupBookedMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                    alertView.dismissAlertView()
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
            
            return
        }
        
        
        //self.showLoader()
        self.viewModel?.bookCar(car: car, completionClosure: { (success, error, data) in
            if error != nil {
                let dispatchTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    //self.hideLoader(completionClosure: { () in
                    var message = "alert_generalError".localized()
                    if Reachability()?.isReachable == false {
                        message = "alert_connectionError".localized()
                    }
                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    //})
                }
            } else {
                if success {
                    if let id = data!["reservation_id"] as? Int {
                        self.viewModel?.getCarBooking(id: id, completionClosure: { (success, error, data) in
                            if error != nil {
                                let dispatchTime = DispatchTime.now() + 0.5
                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                    //self.hideLoader(completionClosure: { () in
                                    var message = "alert_generalError".localized()
                                    if Reachability()?.isReachable == false {
                                        message = "alert_connectionError".localized()
                                    }
                                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                    })
                                    dialog.allowTouchOutsideToDismiss = false
                                    dialog.show()
                                    //})
                                }
                            } else {
                                if success {
                                    if let carBookings = [CarBooking].from(jsonArray: data!) {
                                        if let carBooking = carBookings.first {
                                            DispatchQueue.main.async {
                                                //self.hideLoader(completionClosure: { () in
                                                // salvo la car per userdefault.
                                                
                                                let bonusFree = car.bonus.filter({ (bonus) -> Bool in
                                                    return bonus.status == true && bonus.value > 0
                                                })
                                                if bonusFree.count > 0 {
                                                    let bonus = bonusFree[0]
                                                    let dict: [String: String] = ["carPlate" : car.plate!, "bonusType": bonus.type, "bonusValue": String(bonus.value)]
                                                    UserDefaults.standard.set(dict, forKey: "keyReservationCar")
                                                 
                                                }
                                                if( UserDefaults.standard.object(forKey: "keyReservationCar") == nil){
                                                    let dict: [String: String] = ["carPlate" : car.plate!, "bonusType": "", "bonusValue": ""]
                                                    UserDefaults.standard.set(dict, forKey: "keyReservationCar")
                                                   
                                                }
                                                
                                                //UserDefaults.standard.set(Int((carBooking.timeStart?.timeIntervalSince1970)!) + carBooking.timeLength, forKey: "timeStampReservation"  )
                                                car.booked = true
                                                carBooking.car.value = car
                                                self.closeCarPopup()
                                                self.view_carBookingPopup.alpha = 1.0
                                                self.view_carBookingPopup.updateWithCarBooking(carBooking: carBooking)
                                                self.viewModel?.carBooked = car
                                                self.viewModel?.carBooking = carBooking
                                                self.getResultsWithoutLoading()
                                                if let location = car.location {
                                                    self.getRoute(fromLocation: location)
                                                }
                                                let locationManager = LocationManager.sharedInstance
                                                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                                                    if let userLocation = locationManager.lastLocationCopy.value {
                                                        self.centerMap(on: userLocation, zoom: 16.5, animated: false)
                                                    }
                                                }
                                                //})
                                            }
                                        }
                                    } else {
                                        //self.hideLoader(completionClosure: { () in
                                        self.showGeneralAlert(type: "")
                                        //})
                                    }
                                } else {
                                    //self.hideLoader(completionClosure: { () in
                                    self.showGeneralAlert(type: "")
                                    //})
                                }
                            }
                        })
                        /* let message = "Prenotazione inviata correttamente"
                         let dispatchTime = DispatchTime.now() + 3000.0
                         let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                         alertView.dismissAlertView()
                         })
                         dialog.allowTouchOutsideToDismiss = false
                         dialog.show()
                         DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                         
                         dialog.dismissAlertView()
                         
                         }*/
                    }
                } else {
                    
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        //self.hideLoader(completionClosure: { () in
                        let disableData =  data?["reason"] as? String
                        if disableData == "user_disabled"{
                            self.getDisableReasonMessage()
                        }else{
                            let dialog = ZAlertView(title: nil, message: self.splitMessage(data: data?["reason"] as? String), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                            
                            //})
                        }
                        
                    }
                }
            }
        })
    }
    public func getDisableReasonMessage(){
        
        let disableReason = KeychainSwift().get("DisableReason")!
        
        switch disableReason {
        case "FIRST_PAYMENT_NOT_COMPLETED":
            // let message = "alert_loginUserNotEnabled".localized()
            let message = "first_payment_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        case "FAILED_PAYMENT":
            //let message = "alert_loginUserNotEnabled".localized()
            let message = "failed_payment_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
            
        case "INVALID_DRIVERS_LICENSE":
            //let message = "alert_loginUserNotEnabled".localized()
            let message = "invalid_driver_license_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        case "DISABLED_BY_WEBUSER":
            //let message = "alert_loginUserNotEnabled".localized()
            let message = "disabled_webuser_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        MapViewController().launchAssistence()
                                        
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        case "EXPIRED_DRIVERS_LICENSE":
            //  let message = "alert_loginUserNotEnabled".localized()
            let message = "expired_driver_license_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
            
        case "EXPIRED_CREDIT_CARD":
            //  let message = "alert_loginUserNotEnabled".localized()
            let message = "expired_credit_card_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
            
        case "FAILED_EXTRA_PAYMENT":
            //let message = "alert_loginUserNotEnabled".localized()
            let message = "failed_extra_payment_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        MapViewController().launchAssistence()
                                        
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        case "REGISTRATION_NOT_COMPLETED":
            //let message = "alert_loginUserNotEnabled".localized()
            let message = "registration_not_completed_login_alert".localized()
            let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                    okButtonHandler: { alertView in
                                        alertView.dismissAlertView()
                                        LoginViewModel().launchUserArea()
                                        //Router.from(self,viewModel: ViewModelFactory.userArea()).execute()
            },
                                    cancelButtonHandler: { alertView in
                                        alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        default:
            let message = "alert_loginUserNotEnabled".localized()
            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
            
        }
        /*switch disableReason {
         case "FIRST_PAYMENT_NOT_COMPLETED":
         return  "Primo pagamento non effettuato"
         
         case "FAILED_PAYMENT":
         return "Pagamento fallito"
         
         case "INVALID_DRIVERS_LICENSE":
         return "Patente non valida"
         
         case "DISABLED_BY_WEBUSER":
         return "Disabilitato manualmente"
         
         case "EXPIRED_DRIVERS_LICENSE":
         return "Patente scaduta"
         
         case "EXPIRED_CREDIT_CARD":
         return "Carta di credito scaduta"
         
         default:
         return "Errore Generico"
         
         }*/
    }
    
    public func splitMessage(data: String?) -> String{
        
        /*if(data == "user_disabled"){
         
         return "Non puoi prenotare questa sharen'go. Utente disabilitato motivo: \(getDisableReasonMessage())"
         
         }else{*/
        
        let array:[String]? = data!.components(separatedBy: "-")
        var result=""
        if let length:Int = array?.count{
            for index in 0..<length{
                let reason:[String]? = array?[index].components(separatedBy: ":")
                if (reason?[reason!.count-1].trimmingCharacters(in: CharacterSet.whitespaces).toBool())!{
                    
                    let key:String? = reason?[reason!.count-2].trimmingCharacters(in: CharacterSet.whitespaces)
                    
                    if  (key?.caseInsensitiveCompare("status")==ComparisonResult.orderedSame)
                    {
                        result = "alert_carBookingPopupStatus".localized()///[NSError errorWithDomain:@"SngRestClientManager.UnaviableCar" code:[operation.response statusCode] userInfo:nil];
                    }
                    else if (key?.caseInsensitiveCompare("reservation")==ComparisonResult.orderedSame)
                    {
                        result = "alert_carBookingPopupOnTrip".localized()// [NSError errorWithDomain:@"SngRestClientManager.AlreadyReserved" code:[operation.response statusCode] userInfo:nil];
                    }
                    else if (key?.caseInsensitiveCompare("trip")==ComparisonResult.orderedSame)
                    {
                        result = "alert_carBookingPopupOnTrip".localized()//[NSError errorWithDomain:@"SngRestClientManager.TripOn" code:[operation.response statusCode] userInfo:nil];
                    }else if (key?.caseInsensitiveCompare("limit")==ComparisonResult.orderedSame)
                    {
                        result = "alert_carBookingPopupAlreadyBooked".localized()//[NSError errorWithDomain:@"SngRestClientManager.LimitReservation" code:[operation.response statusCode] userInfo:nil];
                    }else if (key?.caseInsensitiveCompare("limit_archive")==ComparisonResult.orderedSame)
                    {
                        result = "alert_carBookingPopupAlreadyBooked".localized()//[NSError errorWithDomain:@"SngRestClientManager.LimitReservation" code:[operation.response statusCode] userInfo:nil];
                    }else {
                        result = "alert_carBookingPopupGeneric".localized()//[NSError errorWithDomain:@"SngRestClientManager.GetActiveBooking" code:kSngClientManagerInvalidBookingObject userInfo:nil];
                    }
                }
                
            }
        }
        return result
        //  }
        
    }
    
    /**
     This method delete car booking
     */
    public func deleteBookCar() {
        let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupDeleteMessage".localized(), isOkButtonLeft: false, okButtonText: "btn_yes".localized(), cancelButtonText: "btn_no".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    if let carBooking = self.viewModel?.carBooking {
                                        //self.showLoader()
                                        self.viewModel?.deleteCarBooking(carBooking: carBooking, completionClosure: { (success, error) in
                                            if error != nil {
                                                let dispatchTime = DispatchTime.now() + 0.5
                                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                    //self.hideLoader(completionClosure: { () in
                                                    var message = "alert_generalError".localized()
                                                    if Reachability()?.isReachable == false {
                                                        message = "alert_connectionError".localized()
                                                    }
                                                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                        alertView.dismissAlertView()
                                                    })
                                                    dialog.allowTouchOutsideToDismiss = false
                                                    dialog.show()
                                                    //})
                                                }
                                            } else {
                                                if success {
                                                    let dispatchTime = DispatchTime.now() + 0.5
                                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                        //self.hideLoader(completionClosure: { () in
                                                        let confirmDialog = ZAlertView(title: nil, message: "alert_carBookingPopupConfirmDeleteMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                            self.closeCarBookingPopupView()
                                                            CoreController.shared.currentCarBooking = nil
                                                            UserDefaults.standard.removeObject(forKey: "keyReservationCar")
                                                        })
                                                        confirmDialog.allowTouchOutsideToDismiss = false
                                                        confirmDialog.show()
                                                        //})
                                                    }
                                                } else {
                                                    let dispatchTime = DispatchTime.now() + 0.5
                                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                        //self.hideLoader(completionClosure: { () in
                                                        let dialog = ZAlertView(title: nil, message: "alert_carBookingPopupAlreadyBooked".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                            alertView.dismissAlertView()
                                                        })
                                                        dialog.allowTouchOutsideToDismiss = false
                                                        dialog.show()
                                                        //})
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
     This method checks radius with animation. If radius is less than clusteringRadius application asks new results from server, if radius is over application shows cities
     */
    public func getResults() {
        self.stopRequest()
        if let radius = self.getRadius() {
            if radius < self.clusteringRadius {
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
            if radius < self.clusteringRadius {
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
        self.mapView.settings.rotateGestures = false
        // User
        self.userAnnotation.icon = userAnnotation.image
        let locationManager = LocationManager.sharedInstance
        locationManager.lastLocationCopy.asObservable()
            .subscribe(onNext: {[weak self] (_) in
                DispatchQueue.main.async {
                    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                        self?.showUserPositionVisible(true)
                        if self?.lastLocation?.coordinate.latitude != locationManager.lastLocationCopy.value?.coordinate.latitude && self?.lastLocation?.coordinate.longitude != locationManager.lastLocationCopy.value?.coordinate.longitude {
                            if let location = self?.selectedCar?.location {
                                self?.getRoute(fromLocation: location)
                            } else if self?.viewModel?.carTrip != nil && self?.viewModel?.carTrip?.car.value?.parking == true {
                                if let location = self!.viewModel?.carTrip?.car.value?.location {
                                    self?.getRoute(fromLocation: location)
                                }
                            } else if self?.viewModel?.carBooking != nil {
                                if let location = self!.viewModel?.carBooking?.car.value?.location {
                                    self?.getRoute(fromLocation: location)
                                }
                            }
                        }
                        self?.lastLocation = locationManager.lastLocationCopy.value
                    } else {
                        self?.showUserPositionVisible(false)
                    }
                }
            }).disposed(by: disposeBag)
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
     This method launch page assistence the same type of menu.
     */
    public func launchAssistence() {
        let destination: SupportViewController = (Storyboard.main.scene(.support))
        destination.bind(to: viewModel, afterLoad: true)
        CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
    }
    /**
     This method launch page FAQ the same type of menu.
     */
    public func launchFaq() {
        let destination: FaqViewController = (Storyboard.main.scene(.faq))
        destination.bind(to: FaqViewModel(), afterLoad: true)
        CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
    }
    /**
     This method shows or hide user position
     - Parameter visible: Visible determinates if user position is shown or not
     */
    public func showUserPositionVisible(_ visible: Bool) {
        if visible {
            if let radius = self.getRadius() {
                if radius < clusteringRadius || (self.viewModel?.carTrip == nil || self.viewModel?.carTrip?.car.value?.parking == true) {
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
    public func showGeneralAlert(type: String) {
        if type == ""{
            let dialog = ZAlertView(title: nil, message: "alert_generalError".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }else if type == "user_disabled"{
            getDisableReasonMessage()
        }
    }
    /**
     This method shows a localization alert message (user can open settings from it)
     */
    public func showLocalizationAlert(message: String) {
        let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                okButtonHandler: { alertView in
                                    alertView.dismissAlertView()
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                                    } else {
                                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
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
    
    public func updateRoute(_ polyline: GMSPolyline?)
    {
        //  Remove old oldlines from the map
        stepPolyline?.map = nil
        
        // Needed is NOT in parking mode
        if let parking = viewModel?.carTrip?.car.value?.parking
        {
            guard !parking else { return }
        }
        
        //  If needed update polyline
        stepPolyline = polyline
        drawRoutes(polyline: stepPolyline)
    }
    
    public func drawRoutes(polyline: GMSPolyline?) {
        
        guard let polyline = polyline else { return }
        
        DispatchQueue.main.async {
            polyline.strokeColor = UIColor(hexString: "#336633")
            polyline.strokeWidth = 10
            polyline.spans = GMSStyleSpans(polyline.path!, [GMSStrokeStyle.solidColor(UIColor(hexString: "#336633")), GMSStrokeStyle.solidColor(UIColor.clear)], [5, 5], GMSLengthKind.projected)
            polyline.map = self.mapView
        }
    }
}
extension NSMutableAttributedString {
    @discardableResult func bold( text:String) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key:AnyObject] = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal( text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
    
    @discardableResult func justify( text:String) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        let attrs: [NSAttributedString.Key : AnyObject] = [NSAttributedString.Key.paragraphStyle: paragraph]
        let justifyString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(justifyString)
        return self
    }
    
    
    
    
}
extension MapViewController: GMSMapViewDelegate
{
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
    {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.view_searchBar.stopSearchBar()
        if clusteringInProgress == true
        {
            self.setUpdateButtonAnimated(true)
        }
    }
    
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.view_searchBar.stopSearchBar()
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.bearing))
        self.getResults()
    }
    
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        let plateOfPopUp =  self.view_carBookingPopup.viewModel?.carBooking?.carPlate//self.view_carPopup.viewModel?.plate.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        if let cityAnnotation = marker as? CityAnnotation {
            self.updateRoute(self.stepPolyline)
            if let location = cityAnnotation.city?.location {
                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: 11.5, animated: true)
            }
        } else if let carAnnotation = marker.userData as? CarAnnotation {
            let car = carAnnotation.car
            /*if let bookedCar = self.viewModel?.carBooked {
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
             }*/
            if car.plate != self.selectedCar?.plate {
                self.updateRoute(self.stepPolyline)
            }
            if let location = car.location {
                let newLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self.centerMap(on: newLocation, zoom: 18.5, animated: true)
            }
            self.view_carPopup.updateWithCar(car: car)
            self.viewModel?.updateCarPopUp(car: car, carPopUp : self.view_carPopup)
            self.updatePolylineInfo()
            self.view_carPopup.viewModel?.type.value = .car
           
            self.view.layoutIfNeeded()
            UIView .animate(withDuration: 0.2, animations: {
                if car.plate != plateOfPopUp {
                    if car.type.isEmpty {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight
                    } else if car.type.contains("\n") {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 55//55
                    } else {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 40//40
                    }
              
               
                self.view_carPopup.alpha = 1.0
            
                self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                self.view.layoutIfNeeded()
                }
                self.selectedCar = car
                if let location = car.location {
                    self.getRoute(fromLocation: location)
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

