//
//  ApiController.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import Moya
import Gloss
import Moya_Gloss
import RxSwift
import MapKit
import Alamofire
import KeychainSwift

// NetworkLoggerPlugin(verbose: true, cURL: true)

/**
 ApiController class is controller that manage sharengo web services (https://api.sharengo.it:8023/)
 */
public class ApiController {
    /// Session Manager
    public var manager: SessionManager?
   
    // MARK: - Init methods
    
    public init() {
        let cert = PKCS12.init(mainBundleResource: "client", resourceType: "p12", password: "oi8dmf0");
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "api.sharengo.it": .disableEvaluation
        ]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20        
        self.manager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        self.manager!.delegate.sessionDidReceiveChallenge = { session, challenge in
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                return (URLSession.AuthChallengeDisposition.useCredential, cert.urlCredential());
            }
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                return (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!));
            }
            return (URLSession.AuthChallengeDisposition.performDefaultHandling, Optional.none);
        }
    }
    
    /**
     This method returns user data from username and password
     - Parameter username: username of user
     - Parameter password: password of user
     */
    public func getUser(username: String, password: String) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.getUserWith(username: username, password: password))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }

    /**
     This method returns all cars from server
     - Parameter userLatitude: latitude of user location
     - Parameter userLongitude: longitude of user location
     */
    public func searchCars(userLatitude: CLLocationDegrees = 0, userLongitude: CLLocationDegrees = 0) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchAllCars(userLatitude: userLatitude, userLongitude: userLongitude))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
    This method returns cars visible in map
    - Parameter latitude: one of the coordinate that determines the center of the map
    - Parameter longitude: one of the coordinate that determines the center of the map
    - Parameter radius: the distance from the center of the map to the edge of the map
    - Parameter userLatitude: latitude of user location
    - Parameter userLongitude: longitude of user location
    */
    public func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance, userLatitude: CLLocationDegrees = 0, userLongitude: CLLocationDegrees = 0) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius, userLatitude: userLatitude, userLongitude: userLongitude))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns car
     - Parameter plate: car's plate
     */
    public func searchCar(plate: String) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchCar(plate: plate))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns list of booking
     */
    public func bookingList() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.bookingList())
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns car trips
     */
    public func tripsList() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.tripsList())
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns archived car trips
     */
    func archivedTripsList() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.archivedTripsList())
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method books a car
     - Parameter car: car object that user wants to book
     - Parameter userLatitude: latitude of user location
     - Parameter userLongitude: longitude of user location
     */
    func bookCar(car: Car, userLatitude: CLLocationDegrees = 0, userLongitude: CLLocationDegrees = 0) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.bookCar(car: car, userLatitude: userLatitude, userLongitude: userLongitude))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method deletes a car booking
     - Parameter carBooking: car booking object that user wants to delete
     */
    public func deleteCarBooking(carBooking: CarBooking) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.deleteCarBooking(carBooking: carBooking))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns a car booking
     - Parameter id: car booking's id
     */
    public func getCarBooking(id: Int) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.getCarBooking(id: id))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method executes an action on a car
     - Parameter car: car that user wants to open, unpark, ...
     - Parameter action: action ("open", "unpark", ...)
     */
    public func openCar(car: Car, action: String) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.openCar(car: car, action: action))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns trip data
     - Parameter trip: car trip object
     */
    public func getTrip(trip: CarTrip) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.getTrip(trip: trip))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
    
    /**
     This method returns current trip data
     */
    public func getCurrentTrip() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.getCurrentTrip())
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
                    default:
                        break
                    }
            }
        }
    }
}

fileprivate enum API {
    case getUserWith(username: String, password: String)
    case searchAllCars(userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees)
    case searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance, userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees)
    case searchCar(plate: String)
    case bookingList()
    case bookCar(car: Car, userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees)
    case deleteCarBooking(carBooking: CarBooking)
    case getCarBooking(id: Int)
    case openCar(car: Car, action: String)
    case tripsList()
    case archivedTripsList()
    case getTrip(trip: CarTrip)
    case getCurrentTrip()
}

extension API: TargetType {
    var baseURL: URL {
        switch self {
        case .tripsList(), .archivedTripsList():
            let username = KeychainSwift().get("Username")!
            let password = KeychainSwift().get("Password")!
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v3")!
        case .searchCars(_, _, _, _, _), .searchAllCars(_, _):
            return URL(string: "https://api.sharengo.it:8023/v3")!
        case .bookingList(), .bookCar(_), .deleteCarBooking(_), .openCar(_, _), .getCurrentTrip():
            let username = KeychainSwift().get("Username")!
            let password = KeychainSwift().get("Password")!
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v2")!
        case .getUserWith(let username, let password):
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v2")!
        default:
            return URL(string: "https://api.sharengo.it:8023/v2")!
        }
    }
    
    var path: String {
        switch self {
        case .getUserWith(_, _):
            return "user"
        case .searchAllCars(_, _), .searchCars(_, _, _, _, _), .searchCar(_):
            return "cars"
        case .bookingList(), .bookCar(_), .getCarBooking(_):
            return "reservations"
        case .deleteCarBooking(let carBooking):
            return "reservations/\(carBooking.id ?? 0)"
        case .openCar(let car, _):
            return "cars/\(car.plate ?? "")"
        case .tripsList(), .archivedTripsList():
            return "trips"
        case .getTrip(let trip):
            return "trips/\(trip.id ?? 0)"
        case .getCurrentTrip():
            return "trips/current"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .bookCar(_):
            return .post
        case .deleteCarBooking(_):
            return .delete
        case .openCar(_):
            return .put
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchCars(let latitude, let longitude, let radius, let userLatitude, let userLongitude):
            return ["lat": latitude, "lon": longitude, "radius": Int(radius), "user_lat": userLatitude, "user_lon": userLongitude]
        case .searchAllCars(let userLatitude, let userLongitude):
            return ["user_lat": userLatitude, "user_lon": userLongitude]
        case .searchCar(let plate):
            return ["plate": plate]
        case .bookCar(let car, let userLatitude, let userLongitude):
            return ["plate": car.plate ?? "", "user_lat": userLatitude, "user_lon": userLongitude]
        case .getCarBooking(let id):
            return ["reservation_id": id]
        case .openCar(_, let action):
            return ["action": action]
        case .tripsList(), .bookingList():
            return ["active": "true"]
        case .archivedTripsList():
            return ["active": "false"]
        default:
            return [:]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "Blah blah!".data(using: .utf8)!
    }
    
    var task: Task {
        return .request
    }
}
