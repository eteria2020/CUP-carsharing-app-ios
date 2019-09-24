//
//  PublishersAPIController.swift
//
//  Created by Dedecube on 31/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import Moya
import Gloss
import RxSwift
import MapKit
import Alamofire
import KeychainSwift

// NetworkLoggerPlugin(verbose: true, cURL: true)

final class PublishersAPIController {
    fileprivate var manager: SessionManager?
   
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20        
        self.manager = Alamofire.SessionManager(
            configuration: configuration
        )
    }
    
    func getCities() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.rx.request(.cities).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    
    func getCategories() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.categories).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    
    func getOffers(category: Category? = nil) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.offers(category: category)).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    
    func getMapOffers(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.mapOffers(latitude: latitude, longitude: longitude, radius: radius)).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    
    func getEvents(category: Category? = nil) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.events(category: category)).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    
    func getMapEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.mapEvents(latitude: latitude, longitude: longitude, radius: radius)).asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: Response.self)
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
    case cities
    case categories
    case offers(category: Category?)
    case mapOffers(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
    case events(category: Category?)
    case mapEvents(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
}

extension API: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL { return URL(string: "http://universo-sharengo.thedigitalproject.it:universo-sharengo.thedigitalproject.it@universo-sharengo.thedigitalproject.it/feed")! }
    
    var path: String {
        switch self {
        case .cities:
            return "cities/list"
        case .categories:
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
        return .requestPlain
    }
}
