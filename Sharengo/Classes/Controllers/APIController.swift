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

final class ApiController {
    fileprivate var manager: SessionManager?
   
    init() {
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
    
    func getUser() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.getUser())
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

    func searchCars() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.searchAllCars())
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
    
    func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius))
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
    
    func searchCar(plate: String) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true), NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
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
    
    func bookingList() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
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
    
    func tripsList() -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true), NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
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
    
    func bookCar(car: Car) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true), NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.bookCar(car: car))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        observable.onNext(response)
                        observable.onCompleted()
                    case .error(let error):
                        observable.onError(error)
//                        {"status":200,"reason":"Error: reservation:false - status:false - trip:true - limit:false - limit_archive:false","data":null,"time":1497018296}
                    default:
                        break
                    }
            }
        }
    }
    
    func deleteCarBooking(carBooking: CarBooking) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
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
    
    func getCarBooking(id: Int) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
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
    
    func openCar(car: Car) -> Observable<Response> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.openCar(car: car))
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
    case getUser()
    case searchAllCars()
    case searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
    case searchCar(plate: String)
    case bookingList()
    case bookCar(car: Car)
    case deleteCarBooking(carBooking: CarBooking)
    case getCarBooking(id: Int)
    case openCar(car: Car)
    case tripsList()
}

extension API: TargetType {
    var baseURL: URL {
        switch self {
        case .bookingList(), .bookCar(_), .deleteCarBooking(_), .openCar(_), .getUser(), .tripsList():
            return URL(string: "https://francesco.galatro%40gmail.com:508c82b943ae51118d905553b8213c8a@api.sharengo.it:8023/v2")!
        default:
            return URL(string: "https://api.sharengo.it:8023/v2")!
        }
    }
    
    var path: String {
        switch self {
        case .getUser():
            return "user"
        case .searchAllCars(), .searchCars(_, _, _), .searchCar(_):
            return "cars"
        case .bookingList(), .bookCar(_), .getCarBooking(_):
            return "reservations"
        case .deleteCarBooking(let carBooking):
            return "reservations/\(carBooking.id ?? 0)"
        case .openCar(let car):
            return "cars/\(car.plate ?? "")"
        case .tripsList():
            return "trips"
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
        case .searchCars(let latitude, let longitude, let radius):
            return ["lat": latitude, "lon": longitude, "radius": Int(radius)]
        case .searchCar(let plate):
            return ["plate": plate]
        case .bookCar(let car):
            return ["plate": car.plate ?? ""]
        case .getCarBooking(let id):
            return ["reservation_id": id]
        case .openCar(_):
            return ["action": "open"]
        case .tripsList():
            return ["active": "true"]
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
