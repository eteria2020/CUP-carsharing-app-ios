//
//  PublishersAPIController.swift
//
//  Created by Dedecube on 31/05/17.
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
 PublishersAPIController class is a controller that manage publishers services.
 */
public class PublishersAPIController {
    /// Session Manager
    public var manager: SessionManager?
   
    // MARK: - Init methods
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20        
        self.manager = Alamofire.SessionManager(
            configuration: configuration
        )
    }
    
    // MARK: - Get methods
    
    /**
     This method return cities related to publishers.
     */
    public func getCities() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.cities())
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
     This method return categories relative to publishers.
     */
    public func getCategories() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.categories())
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
     This method return offers of a category.
     - Parameter category: category that can be nil if we want return all offers
     */
    public func getOffers(category: Category? = nil) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.offers(category: category))
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
     This method return offers visible in map that user see
     - Parameter latitude: The latitude is one of the coordinate that determines the center of the map
     - Parameter longitude: The longitude is one of the coordinate that determines the center of the map
     - Parameter radius: The radius is the distance from the center of the map to the edge of the map
     */
    public func getMapOffers(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.mapOffers(latitude: latitude, longitude: longitude, radius: radius))
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
     This method return events of a category.
     - Parameter category: category that can be nil if we want return all events
     */
    public func getEvents(category: Category? = nil) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.events(category: category))
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
     This method return events visible in map that user see
     - Parameter latitude: The latitude is one of the coordinate that determines the center of the map
     - Parameter longitude: The longitude is one of the coordinate that determines the center of the map
     - Parameter radius: The radius is the distance from the center of the map to the edge of the map
     */
    public func getMapEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.mapEvents(latitude: latitude, longitude: longitude, radius: radius))
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
    case cities()
    case categories()
    case offers(category: Category?)
    case mapOffers(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
    case events(category: Category?)
    case mapEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
}

extension API: TargetType {
    var baseURL: URL { return URL(string: "https://www.sharengo.it/feed")! }
    
    var path: String {
        switch self {
        case .cities():
            return "cities/list"
        case .categories():
            return "categories/list"
        case .offers(let category):
            let cid = category?.identifier ?? "0"
            var cityid = "0"
            if var dictionary = UserDefaults.standard.object(forKey: "cityDic") as? [String: String] {
                if let username = KeychainSwift().get("Username") {
                    cityid = dictionary[username] ?? "0"
                }
            }
            return "category/\(cid)/city/\(cityid)/offers"
        case .mapOffers(let latitude, let longitude, let radius):
            return String(format: "latitude/%0.6f/longitude/%0.6f/radius/%0.f/offers", latitude, longitude, radius)
        case .events(let category):
            let cid = category?.identifier ?? "0"
            var cityid = "0"
            if var dictionary = UserDefaults.standard.object(forKey: "cityDic") as? [String: String] {
                if let username = KeychainSwift().get("Username") {
                    cityid = dictionary[username] ?? "0"
                }
            }
            return "category/\(cid)/city/\(cityid)/events"
        case .mapEvents(let latitude, let longitude, let radius):
            return String(format: "latitude/%0.6f/longitude/%0.6f/radius/%0.f/events", latitude, longitude, radius)
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
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
