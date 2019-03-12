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

final class ApiController {
    fileprivate var manager: SessionManager?
   
    init()
    {
        let cert = PKCS12.init(mainBundleResource: "client", resourceType: "p12", password: "1WC;Xen123hb|z");
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
    
    func getUser(username: String, password: String) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.getUserWith(username: username, password: password)).asObservable()
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

    func searchCars() -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status, _  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.searchAllCars()).asObservable()
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
    
    func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance, userLatitude: CLLocationDegrees = 0, userLongitude: CLLocationDegrees = 0) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status, _ in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.rx.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius, userLatitude: userLatitude, userLongitude: userLongitude))
                .asObservable()
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
    
    func searchCar(plate: String) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true, cURL: true) , NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.searchCar(plate: plate)).asObservable()
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
    
    //  AGGIUNTA PER DEEPLINK CALLING APP
    //  searchCarURL(let userLatitude, let userLongitude, let callingApp, let car):
    //  return ["user_lat": userLatitude, "user_lon": userLongitude, "plate": car, "calling_app": callingApp]
    func searchCarURL(userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees, plate: String, callingApp: String, email: String?) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status, _   in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.searchCarURL(userLatitude: userLatitude, userlLongitude: userLongitude, carPlate: plate, callingApp: callingApp, email: email)).asObservable()
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
    
    func bookingList() -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.bookingList()).asObservable()
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
    
    func tripsList() -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.tripsList()).asObservable()
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
    
    func archivedTripsList() -> Observable<Response>
    {
        
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.archivedTripsList()).asObservable()
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
    
    func bookCar(car: Car, userLatitude: CLLocationDegrees = 0, userLongitude: CLLocationDegrees = 0) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_  in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.bookCar(car: car, userLatitude: userLatitude, userLongitude: userLongitude)).asObservable()
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
    
    func deleteCarBooking(carBooking: CarBooking) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.deleteCarBooking(carBooking: carBooking)).asObservable()
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
    
    func getCarBooking(id: Int) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.getCarBooking(id: id)).asObservable()
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
    
    func openCar(car: Car, action: String) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.openCar(car: car, action: action)).asObservable()
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
    
    func closeCar(car: Car, action: String) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.closeCar(car: car, action: action)).asObservable()
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
    
    func getTrip(trip: CarTrip) -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.getTrip(trip: trip)).asObservable()
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
    
    func getConfig() -> Observable<Response>
    {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { status,_ in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.getConfig()).asObservable()
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
    case searchAllCars()
    case searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance, userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees)
    case searchCar(plate: String)
    case searchCarURL(userLatitude: CLLocationDegrees, userlLongitude: CLLocationDegrees, carPlate: String, callingApp: String, email: String?)
    case bookingList()
    case bookCar(car: Car, userLatitude: CLLocationDegrees, userLongitude: CLLocationDegrees)
    case deleteCarBooking(carBooking: CarBooking)
    case getCarBooking(id: Int)
    case openCar(car: Car, action: String)
    case closeCar(car: Car, action: String)
    case tripsList()
    case archivedTripsList()
    case getTrip(trip: CarTrip)
    case getConfig()
}

extension API: TargetType
{
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        switch self {
        case .tripsList(), .archivedTripsList(), .getTrip(_):
            let username = KeychainSwift().get("Username")!
            let password = KeychainSwift().get("Password")!
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v3")!
        case .searchCars(_, _, _, _, _), .searchCar(_), .searchAllCars():
            return URL(string: "https://api.sharengo.it:8023/v3")!
        case  .searchCarURL(_, _, _, _,_):
            return URL(string: "https://api.sharengo.it:8023/v3")!
        case .bookingList(), .bookCar(_), .deleteCarBooking(_), .openCar(_, _), .closeCar(_, _):
            let username = KeychainSwift().get("Username")!
            let password = KeychainSwift().get("Password")!
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v2")!
        case .getUserWith(let username, let password):
            return URL(string: "https://\(username):\(password)@api.sharengo.it:8023/v3")!
        case .getConfig():
            return URL(string: "https://api.sharengo.it:8023/v3")!
        default:
            return URL(string: "https://api.sharengo.it:8023/v2")!
        }
    }
    
    var path: String {
        switch self {
        case .getUserWith(_, _):
            return "user"
        case .searchAllCars(), .searchCars(_, _, _, _, _), .searchCarURL(_, _, _, _,_), .searchCar(_):
            return "cars"
        case .bookingList(), .bookCar(_), .getCarBooking(_):
            return "reservations"
        case .deleteCarBooking(let carBooking):
            return "reservations/\(carBooking.id ?? 0)"
        case .openCar(let car, _), .closeCar(let car, _):
            return "cars/\(car.plate ?? "")"
        case .tripsList(), .archivedTripsList():
            return "trips"
        case .getTrip(let trip):
            return "trips/\(trip.id ?? 0)"
        case .getConfig():
            return "config"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .bookCar(_):
            return .post
        case .deleteCarBooking(_):
            return .delete
        case .openCar(_), .closeCar(_):
            return .put
        default:
            return .get
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .searchCars(let latitude, let longitude, let radius, let userLatitude, let userLongitude):
            return ["lat": latitude, "lon": longitude, "radius": Int(radius), "user_lat": userLatitude, "user_lon": userLongitude]
        case .searchCar(let plate):
            return ["plate": plate]
        case .searchCarURL(let userLatitude, let userLongitude,let car,let callingApp, let email):
            return ["user_lat": userLatitude, "user_lon": userLongitude, "plate": car, "callingApp": callingApp,"email": email ?? ""]
        case .bookCar(let car, let userLatitude, let userLongitude):
            return ["plate": car.plate ?? "", "user_lat": userLatitude, "user_lon": userLongitude]
        case .getCarBooking(let id):
            return ["reservation_id": id]
        case .openCar(_, let action), .closeCar(_, let action):
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
        switch method {
        case .post, .put: return Task.requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default: return Task.requestParameters(parameters: parameters, encoding: URLEncoding.methodDependent)
        }
        
    }
}
