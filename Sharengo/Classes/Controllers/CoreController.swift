//
//  CoreController.swift
//  Sharengo
//
//  Created by Dedecube on 08/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Boomerang
import KeychainSwift
import Localize_Swift
import Reachability

/**
 CoreController class is a singleton class accessible from other classes with support variables, methods, ...
 */
public class CoreController {
    /// Shared instance
    public static let shared = CoreController()
    /// Current screen that user sees
    public var currentViewController: UIViewController?
    /// Instance of ApiController
    public let apiController: ApiController = ApiController()
    /// Instance of PublishersApiController
    public let publishersApiController: PublishersAPIController = PublishersAPIController()
    /// Instance of SharengoApiController
    public let sharengoApiController: SharengoApiController = SharengoApiController()
    /// Update timer used to update application
    public var updateTimer: Timer?
    /// Update car timer used to update current car trip
    public var updateCarTripTimer: Timer?
    /// Boolean that indicate if there is an update in progress
    public var updateInProgress = false
    /// Array of car bookings
    public var allCarBookings: [CarBooking] = []
    /// Array of car trips
    public var allCarTrips: [CarTrip] = []
    /// Current car booking
    public var currentCarBooking: CarBooking?
    /// Current car trip
    public var currentCarTrip: CarTrip?
    /// Boolean that indicate if there is a notification showed in this moment or not
    public var notificationIsShowed: Bool = false
    /// Array of cities
    public var cities: [City] = []
    /// Array of polygons
    public var polygons: [Polygon] = []
    /// Support variabile for pulse yellow gif
    public lazy var pulseYellow: UIImage = CoreController.shared.getPulseYellow()
    /// Support variabile for pulse green gif
    public lazy var pulseGreen: UIImage = CoreController.shared.getPulseGreen()
    /// Array of archived car trips
    public var archivedCarTrips: [CarTrip] = []
    /// Boolean used to save connection value
    public var connection: Bool = true
    
    private struct AssociatedKeys {
        static var disposeBag = "vc_disposeBag"
    }
    
    /// Dispose bag used from RxSwift
    public var disposeBag: DisposeBag {
        var disposeBag: DisposeBag
        if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
            disposeBag = lookup
        } else {
            disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return disposeBag
    }
    
    // MARK: - Init methods
    
    public init() {
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60*1, target: self, selector: #selector(self.updateData), userInfo: nil, repeats: true)
        self.updateCarTripTimer = Timer.scheduledTimer(timeInterval: 10*1, target: self, selector: #selector(self.updateCarTripData), userInfo: nil, repeats: true)
    }
    
    // MARK: - Update methods
    
    /**
     This method updates list of archived car trips
     */
    public func updateArchivedCarTrips() {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        ApiController().archivedTripsList()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let carTrips = [CarTrip].from(jsonArray: data) {
                            self.archivedCarTrips = carTrips
                        }
                    }
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method updates application data like cities, polygons, user info, ...
     */
    @objc public func updateData() {
        self.updateCities()
        self.updatePolygons()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        self.notificationIsShowed = false
        self.updateUser()
    }
    
    /**
     This method updates polygons
     */
    public func updatePolygons() {
        self.sharengoApiController.getPolygons()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let polygons):
                    self.polygons = polygons
                    var cache: [PolygonCache] = [PolygonCache]()
                    for polygon in self.polygons {
                        cache.append(polygon.getPolygonCache())
                    }
                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: cache as Array)
                    UserDefaults.standard.set(archivedArray, forKey: "cachePolygons")
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }

    /**
     This method updates cities
     */
    public func updateCities() {
        self.publishersApiController.getCities()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status_bool == true, let data = response.array_data {
                        if let cities = [City].from(jsonArray: data) {
                            self.cities = cities
                            var cache: [CityCache] = [CityCache]()
                            for city in self.cities {
                                cache.append(city.getCityCache())
                            }
                            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: cache as Array)
                            UserDefaults.standard.set(archivedArray, forKey: "cacheCities")
                        }
                    }
                case .error(_):
                    break
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }

    /**
     This method updates user info like pin, firstname, ...
     */
    public func updateUser() {
        if let username = KeychainSwift().get("Username"), let password = KeychainSwift().get("Password") {
        self.apiController.getUser(username: username, password: password)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        if let pin = data["pin"] {
                            KeychainSwift().set("\(String(describing: pin))", forKey: "UserPin")
                        }
                        if let firstname = data["name"] {
                            KeychainSwift().set("\(String(describing: firstname))", forKey: "UserFirstname")
                        }
                        if let bonus = data["bonus"] {
                            KeychainSwift().set("\(String(describing: bonus))", forKey: "UserBonus")
                        }
                        if let gender = data["gender"] {
                            KeychainSwift().set("\(String(describing: gender))", forKey: "UserGender")
                        }
                        if let discountRate = data["discount_rate"] {
                            KeychainSwift().set("\(String(describing: discountRate))", forKey: "UserDiscountRate")
                        }
                        self.updateCarBookings()
                    }
                    else if response.status == 404, let code = response.code {
                        if code == "not_found" {
                            self.executeLogout()
                        }
                    }
                    else if let msg = response.msg {
                        if msg == "invalid_credentials" {
                            self.executeLogout()
                        } else if msg == "user_disabled" {
                            self.executeLogout()
                        }
                    }
                case .error(_):
                    self.updateCarBookings()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
        }
    }
    
    /**
     This method executes logout of current user
     */
    public func executeLogout() {
        var languageid = "en"
        if Locale.preferredLanguages[0] == "it-IT" {
            languageid = "it"
        }
        Localize.setCurrentLanguage(languageid)
        KeychainSwift().clear()
        CoreController.shared.currentCarBooking = nil
        CoreController.shared.currentCarTrip = nil
        CoreController.shared.allCarBookings = []
        CoreController.shared.allCarTrips = []
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
        Router.exit(CoreController.shared.currentViewController ?? UIViewController())
        let dispatchTime = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
        let dialog = ZAlertView(title: nil, message: "alert_logoutError".localized(), isOkButtonLeft: false, okButtonText: "btn_login".localized(), cancelButtonText: "btn_back".localized(),
                                okButtonHandler: { alertView in
                                    let destination: LoginViewController = (Storyboard.main.scene(.login))
                                    let viewModel = ViewModelFactory.login()
                                    destination.bind(to: viewModel, afterLoad: true)
                                    (CoreController.shared.currentViewController ?? UIViewController()).navigationController?.pushViewController(destination, animated: true)
                                    alertView.dismissAlertView()
        },
                                cancelButtonHandler: { alertView in
                                    alertView.dismissAlertView()
        })
        dialog.allowTouchOutsideToDismiss = false
        dialog.show()
        }
    }
    
    /**
     This method updates array of car bookings
     */
    public func updateCarBookings() {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        if let currentViewController = CoreController.shared.currentViewController as? MapViewController {
            if let carBooking = currentViewController.viewModel?.carBooking {
                if carBooking.minutes < 1 {
                    self.allCarBookings = [carBooking]
                    self.updateCarTrips()
                    return
                }
            } else if let carTrip = currentViewController.viewModel?.carTrip {
                if carTrip.minutes < 1 {
                    self.updateCarTrips()
                    return
                } else if carTrip.changedStatus != nil {
                    if carTrip.changedStatusMinutes < 1 {
                        self.updateCarTrips()
                        return
                    }
                }
            }
        }
        self.apiController.bookingList()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let carBookings = [CarBooking].from(jsonArray: data) {
                            self.allCarBookings = carBookings.filter({ (carBooking) -> Bool in
                                return carBooking.isActive == true
                            })
                            self.updateCarTrips()
                            return
                        }
                    }
                    self.allCarBookings = []
                    self.updateCarTrips()
                case .error(_):
                    CoreController.shared.notificationIsShowed = true
                    self.allCarBookings = []
                    self.updateCarTrips()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method updates current car trip data
     */
    @objc public func updateCarTripData() {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        if Reachability()?.isReachable == false {
            self.connection = false
            self.updateData()
        } else {
            if !self.connection {
                self.updateData()
            }
            self.connection = true
            if let currentViewController = CoreController.shared.currentViewController as? MapViewController {
                if let carTrip = currentViewController.viewModel?.carTrip {
                    if carTrip.minutes < 1 {
                        self.allCarTrips = [carTrip]
                        self.stopUpdateData()
                        return
                    } else if carTrip.changedStatus != nil {
                        if carTrip.changedStatusMinutes < 1 {
                            self.allCarTrips = [carTrip]
                            self.stopUpdateData()
                            return
                        }
                    }
                    self.apiController.getCurrentTrip()
                        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                        .subscribe { event in
                            switch event {
                            case .next(let response):
                                if response.status == 200, let data = response.array_data {
                                    if let carTrips = [CarTrip].from(jsonArray: data) {
                                        self.allCarTrips = carTrips
                                        self.stopUpdateData()
                                        return
                                    }
                                }
                                self.allCarTrips = []
                                self.stopUpdateData()
                            case .error(_):
                                CoreController.shared.notificationIsShowed = true
                                self.allCarTrips = []
                                self.stopUpdateData()
                            default:
                                break
                            }
                        }.addDisposableTo(self.disposeBag)
                }
            }
        }
    }
    
    /**
     This method updates array of car trips
     */
    public func updateCarTrips() {
        if  KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            return
        }
        if let currentViewController = CoreController.shared.currentViewController as? MapViewController {
            if let carTrip = currentViewController.viewModel?.carTrip {
                if carTrip.minutes < 1 {
                    self.allCarTrips = [carTrip]
                    self.stopUpdateData()
                    return
                } else if carTrip.changedStatus != nil {
                    if carTrip.changedStatusMinutes < 1 {
                        self.allCarTrips = [carTrip]
                        self.stopUpdateData()
                        return
                    }
                }
            }
        }
        self.apiController.getCurrentTrip()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let carTrips = [CarTrip].from(jsonArray: data) {
                            self.allCarTrips = carTrips
                            self.stopUpdateData()
                            return
                        }
                    }
                    self.allCarTrips = []
                    self.stopUpdateData()
                case .error(_):
                    CoreController.shared.notificationIsShowed = true
                    self.allCarTrips = []
                    self.stopUpdateData()
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    /**
     This method updates application sending a notification to all classes
     */
    public func stopUpdateData() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
        self.currentCarBooking = self.allCarBookings.first
        self.currentCarTrip = self.allCarTrips.first
    }
    
    // MARK: - Pulse methods
    
    /**
     This method returns yellow pulse gif
     */
    public func getPulseYellow() -> UIImage {
        var frames: [UIImage] = [UIImage]()
        for i in 1...47 {
            let image = self.resizeImageForPulse(image: UIImage(named: "Giallo_loop_000\(i)")!, newSize: CGSize(width: 200, height: 200))
            frames.append(image)
        }
        return UIImage.animatedImage(with: frames, duration: 3)!
    }
    
    /**
     This method returns green pulse gif
     */
    public func getPulseGreen() -> UIImage {
        var frames: [UIImage] = [UIImage]()
        for i in 1...47 {
            let image = self.resizeImageForPulse(image: UIImage(named: "Verde_loop_000\(i)")!, newSize: CGSize(width: 200, height: 200))
            frames.append(image)
        }
        return UIImage.animatedImage(with: frames, duration: 3)!
    }
    
    /**
     This method is a support method for pulse gif. It resizes images with size given in parameters.
     - Parameter image: image to be resized
     - Parameter newSize: size of new image
     */
    public func resizeImageForPulse(image: UIImage, newSize: CGSize) -> (UIImage) {
        let scale = min(image.size.width/newSize.width, image.size.height/newSize.height)
        let newSize = CGSize(width: image.size.width/scale, height: image.size.height/scale)
        let newOrigin = CGPoint(x: (newSize.width - newSize.width)/2, y: (newSize.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: thumbRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
