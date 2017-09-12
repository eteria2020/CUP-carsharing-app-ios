//
//  NominatimAPIController.swift
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

final class NominatimAPIController {
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
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true, cURL: true), NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.searchAddress(text: text))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: Response.self)
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
}

fileprivate enum API {
    case searchAddress(text: String)
}

extension API: TargetType {
    var baseURL: URL { return URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json")! }
    
    var path: String {
        switch self {
        case .searchAddress(_):
            return ""
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchAddress(let text):
            var location = ""
            let locationManager = LocationManager.sharedInstance
            if let userLocation = locationManager.lastLocationCopy.value {
                location = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
            }
            return ["query": text.replacingOccurrences(of: " ", with: "+"), "language": "language".localized(), "location": "\(location)", "key": "AIzaSyAnVjGP9ZCkSkBVkrX-5SBdmNW9AwE_Gew"]
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
