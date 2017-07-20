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

public enum CarPopupInput: SelectionInput {
    case open
    case book
    case detail
    case car
}

public enum CarPopupOutput: SelectionInput {
    case empty
    case open(Car)
    case book(Car)
    case detail(Feed)
    case car
}

enum CarPopupType {
    case car
    case feed
}

final class CarPopupViewModel: ViewModelTypeSelectable {
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
    
    public var selection: Action<CarPopupInput, CarPopupOutput> = Action { _ in
        return .just(.empty)
    }
    
    init(type: CarPopupType) {
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
    
    func updateWithCar(car: Car) {
        self.car = car
        self.carType.value = car.type
        self.plate = String(format: "lbl_carPopupPlate".localized(), car.plate ?? "")
        self.capacity = String(format: "lbl_carPopupCapacity".localized(), car.capacity != nil ? "\(car.capacity!)%" : "")
        if let distance = car.distance {
            let restultDistance = getDistanceFromMeters(inputedMeters: Int(distance.rounded(.up)))
            if restultDistance.kilometers > 0 {
                self.distance = String(format: "lbl_carPopupDistance_km".localized(), restultDistance.kilometers)
            } else if restultDistance.meters > 0 {
                self.distance = String(format: "lbl_carPopupDistance_mt".localized(), restultDistance.meters)
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
        }
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
    
    func updateWithFeed(feed: Feed) {
        self.feed = feed
        
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
    
    func getDistanceFromMeters(inputedMeters: Int) -> (kilometers: Float, meters: Int)
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
    
    func getTimeFromMinutes(inputedMinutes: Int) -> (hours: Int, minutes: Int)
    {
        let hours = (Float(inputedMinutes) / 60).rounded(.towardZero)
        let minutes = Float(inputedMinutes).truncatingRemainder(dividingBy: 60)
        
        return (Int(hours), Int(minutes))
    }
}
