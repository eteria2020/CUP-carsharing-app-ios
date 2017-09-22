//
//  GoogleAPIController.swift
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

// NetworkLoggerPlugin(verbose: true, cURL: true)

final class GoogleAPIController {
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
    
    func searchAddress(text: String) -> Observable<[Address]> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchAddress(text: text))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: GoogleResponse.self)
                .subscribe { event in
                switch event {
                case .next(let response):
                    if let data = response.array_data {
                        if let addresses = [Address].from(jsonArray: data) {
                            observable.onNext(addresses)
                        }
                    }
                    observable.onCompleted()
                case .error(let error):
                    observable.onError(error)
                default:
                    break
                }
            }
        }
    }
    
    func searchRoute(destination: CLLocation) -> Observable<[RouteStep]> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchRoute(destination: destination))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: GoogleResponse.self)
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if let data = response.array_data {
                            if let steps = [RouteStep].from(jsonArray: data) {
                                observable.onNext(steps)
                            }
                        }
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
    case searchAddress(text: String)
    case searchRoute(destination: CLLocation)
}

extension API: TargetType {
    var baseURL: URL { return URL(string: "https://maps.googleapis.com/maps/api")! }
    
    var path: String {
        switch self {
        case .searchAddress(_):
            return "place/textsearch/json"
        case .searchRoute(_):
            return "directions/json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchAddress(let text):
            var locationString = ""
            let locationManager = LocationManager.sharedInstance
            if let userLocation = locationManager.lastLocationCopy.value {
                locationString = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
            }
            return ["query": text.replacingOccurrences(of: " ", with: "+"), "language": "language".localized(), "location": "\(locationString)", "key": "AIzaSyAnVjGP9ZCkSkBVkrX-5SBdmNW9AwE_Gew"]
        case .searchRoute(let destination):
            var originString = ""
            let locationManager = LocationManager.sharedInstance
            if let userLocation = locationManager.lastLocationCopy.value {
                originString = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
            }
            let destinationString = "\(destination.coordinate.latitude),\(destination.coordinate.longitude)"
            return ["mode": "walking", "origin": "\(originString)", "destination": "\(destinationString)", "key": "AIzaSyBwHmQj5SXyKDwLaMe6KouQ9u6AFY5DUK0"]
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
