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
    
    func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) -> Observable<[Car]> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true), NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])//NetworkLoggerPlugin(verbose: true)
            return provider.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius))
                // TODO: check status and response
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapArray(type: Car.self, forKeyPath: "data")
                .subscribe { event in
                switch event {
                case .next(let cars):
                    observable.onNext(cars)
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
    case searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
}

extension API: TargetType {
    var baseURL: URL { return URL(string: "https://api.sharengo.it:8023/v2")! }
    
    var path: String {
        switch self {
        case .searchCars(_, _, _):
            return "cars"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        /*
        case .searchCars(_, _, _):
            return [:]
        */
        // TODO: with parameters it doesn't work
        case .searchCars(let latitude, let longitude, let radius):
            return ["lat": latitude, "lon": longitude, "radius": Int(radius)]
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
