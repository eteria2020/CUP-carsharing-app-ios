//
//  CarPopupViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

/**
 Enum that specifies selection input
 */
public enum CarPopupInput: SelectionInput {
    case open
    case book
    case detail
    case car
}

/**
 Enum that specifies selection output
 */
public enum CarPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case book(Car)
    case detail(Feed)
    case car
}

/**
 Enum that specifies car popup types
 */
public enum CarPopupType {
    case car
    case feed
}

/**
 The CarPopup viewmodel provides data related to display car data in CarPopupView
 */
public class CarPopupViewModel: ViewModelTypeSelectable {
    fileprivate var car: Car?
    fileprivate var feed: Feed?
    var carType: Variable<String> = Variable("")
    var plate: String = ""
    var capacity: String = ""
    var distance: String = ""
    var walkingDistance: String = ""
    var address: Variable<String?> = Variable(nil)
    let type: Variable<CarPopupType> = Variable(.car)
    var date: String?
    var claim: String?
    var bottomText: String = ""
    var category: String = ""
    var icon: String?
    var color: UIColor?
    var advantageColor: UIColor?
    var image: String?
    var favourited = false
    /// Selection variable
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - Init methods
    
    public init(type: CarPopupType) {
        self.type.value = type
        self.selection = Action { input in
            switch input {
            case .open:
                if let car = self.car {
                    return .just(.open(car))
                }
            case .book:
                if let car = self.car {
                    return .just(.book(car))
                }
            case .detail:
                if let feed = self.feed {
                    Router.from(CoreController.shared.currentViewController ?? UIViewController(),viewModel: ViewModelFactory.feedDetail(fromModel: feed)).execute()
                    return .just(.empty)
                }
            case .car:
                return .just(.car)
            }
            return .just(.empty)
        }
    }
    
    /**
     This method update data with a new car
     */
    public func updateWithCar(car: Car, carNearest: Car?) {
        self.car = car
        self.carType.value = car.getType(carNearest: carNearest)
        self.plate = String(format: "lbl_carPopupPlate".localized(), car.plate ?? "")
        if var capacity = car.capacity {
            if capacity < 50 {
                capacity = capacity - 10
            }
            self.capacity = String(format: "lbl_carPopupCapacity".localized(), "\(capacity)")
        } else if let plate = car.plate {
            let key = "capacity-\(plate)"
            if let c = UserDefaults.standard.object(forKey: key) as? String {
                self.capacity = String(format: "lbl_carPopupCapacity".localized(), "\(c)")
            } else {
                self.capacity = String(format: "lbl_carPopupCapacity".localized(), "")
            }
            CoreController.shared.apiController.searchCar(plate: plate)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.dic_data {
                            let car = Car(json: data)
                            if var c = car?.capacity {
                                if c < 50 {
                                    c = c - 10
                                }
                                self.capacity = String(format: "lbl_carPopupCapacity".localized(), "\(c)")
                                UserDefaults.standard.set("\(c)", forKey: key)
                            }
                        }
                    default:
                        break
                    }
                }.addDisposableTo(CoreController.shared.disposeBag)
        }
        if let distance = car.distance {
            let restultDistance = getDistanceFromMeters(inputedMeters: Int(distance.rounded(.up)))
            if restultDistance.kilometers > 0 {
                self.distance = String(format: "lbl_carPopupDistance_km".localized(), restultDistance.kilometers)
            } else if restultDistance.meters > 0 {
                if restultDistance.meters < 10 {
                    self.distance = String(format: "lbl_carPopupDistance_mt1".localized(), restultDistance.meters)
                } else if restultDistance.meters < 100 {
                    self.distance = String(format: "lbl_carPopupDistance_mt2".localized(), restultDistance.meters)
                } else {
                    self.distance = String(format: "lbl_carPopupDistance_mt3".localized(), restultDistance.meters)
                }
            }
            let minutes: Float = Float(distance.rounded(.up)/100.0)
            let restultWalkingDistance = getTimeFromMinutes(inputedMinutes: Int(minutes.rounded(.up)))
            if restultWalkingDistance.hours > 0 {
                if restultWalkingDistance.minutes > 0 {
                    self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_h_m".localized(), restultWalkingDistance.hours, restultWalkingDistance.minutes < 10 ? "0\(restultWalkingDistance.minutes)" : "\(restultWalkingDistance.minutes)")
                } else {
                    self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_h".localized(), restultWalkingDistance.hours)
                }
            } else if restultWalkingDistance.minutes > 0 {
                self.walkingDistance = String(format: "lbl_carPopupWalkingDistance_m".localized(), restultWalkingDistance.minutes)
            }
        } else {
            self.distance = "lbl_noDistance".localized()
        }
    }
    
    /**
     This method set address from car object
     */
    public func getAddress(car: Car) {
        if let address = car.address.value {
            self.address.value = address
        } else {
            car.getAddress()
            car.address.asObservable()
                .subscribe(onNext: {[weak self] (address) in
                    DispatchQueue.main.async {
                        if address != nil {
                            self?.address.value = address
                        }
                    }
                }).addDisposableTo(disposeBag)
        }
    }
    
    /**
     This method update with a Feed
     */
    public func updateWithFeed(feed: Feed) {
        self.feed = feed
        
        self.category = ""
        self.bottomText = ""
        
        if feed.launchTitle != nil && feed.launchTitle?.isEmpty == false {
            self.category.append("<title>\(feed.launchTitle!.uppercased())</title>\n")
        }
        
        if feed.date != nil && feed.date?.isEmpty == false {
            self.bottomText.append("<date>\(feed.date!)</date>\n")
        }
        
        if feed.title != nil && feed.title?.isEmpty == false {
            self.bottomText.append("<subtitle>\(feed.title!)</subtitle>\n")
        }
        
        if feed.location != nil && feed.location?.isEmpty == false && feed.address != nil && feed.address?.isEmpty == false && feed.city != nil && feed.city?.isEmpty == false {
            self.bottomText.append("<description>\(feed.location!), \(feed.address!), \(feed.city!)</description>\n")
        }
        
        if feed.advantage != nil && feed.advantage?.isEmpty == false {
            self.bottomText.append("<advantage>\(feed.advantage!)</advantage>")
        }
        
        self.claim = feed.claim
        self.icon = feed.icon
        self.color = UIColor(hexString: feed.color ?? "")
        self.image = feed.image
        
        if feed.forceColor {
            advantageColor = UIColor(hexString: feed.color ?? "")
        } else {
            advantageColor = UIColor(hexString: "#888888")
        }
        
        self.favourited = false
        
        if var dictionary = UserDefaults.standard.object(forKey: "favouritesFeedDic") as? [String: Data] {
            if let username = KeychainSwift().get("Username") {
                if let array = dictionary[username] {
                    if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteFeed] {
                        let index = unarchivedArray.index(where: { (f) -> Bool in
                            return feed.identifier == f.identifier
                        })
                        if index != nil {
                            self.favourited = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Utility methods
    
    /**
     This method return formatted distance
     - Parameter inputedMeters: distance as meters
     */
    public func getDistanceFromMeters(inputedMeters: Int) -> (kilometers: Float, meters: Int)
    {
        if (Int(inputedMeters) / 1000) == 0
        {
            let kilometers = 0
            let meters = Float(inputedMeters).truncatingRemainder(dividingBy: 1000)
            
            return (Float(kilometers), Int(meters))
        }
        else
        {
            let kilometers = (Float(inputedMeters) / 1000)
            let meters = Float(inputedMeters).truncatingRemainder(dividingBy: 1000)
            
            return (Float(kilometers), Int(meters))
        }
    }
    
    /**
     This method return formatted time
     - Parameter inputedMinutes: time as minutes
     */
    public func getTimeFromMinutes(inputedMinutes: Int) -> (hours: Int, minutes: Int)
    {
        let hours = (Float(inputedMinutes) / 60).rounded(.towardZero)
        let minutes = Float(inputedMinutes).truncatingRemainder(dividingBy: 60)
        
        return (Int(hours), Int(minutes))
    }
}
