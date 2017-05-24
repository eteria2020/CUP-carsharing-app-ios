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
    static var manager: SessionManager?
   
    // TODO: ???
    static func initManager() {
        let cert = PKCS12.init(mainBundleResource: "client", resourceType: "p12", password: "oi8dmf0");
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "api.sharengo.it": .disableEvaluation
        ]
        
        self.manager = Alamofire.SessionManager(
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
    
    static func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        self.initManager()
        
        let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true)])
        _ = provider.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius)).subscribe { event in
            switch event {
            case .next(let response):
                let json = String(data: response.data, encoding: .utf8)
                print(json ?? "")
            case .error(let error):
                let errorM = error as! MoyaError
                print(errorM.response ?? "")
                print(errorM.failureReason ?? "")
                print(errorM.helpAnchor ?? "")
            default:
                break
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
        case .searchCars(_, _, _):
            return [:]
        // TODO: ???
        /*
        case .searchCars(let latitude, let longitude, let radius):
            return ["lat": latitude, "lon": longitude, "radius": radius]
        */
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
