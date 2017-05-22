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
import KeychainSwift
import MapKit
import Alamofire

class CustomServerTrustPoliceManager : ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }
    public init() {
        super.init(policies: [:])
    }
}

final class ApiController {

    private static let provider = RxMoyaProvider<API>(manager: Manager(configuration: URLSessionConfiguration.default, serverTrustPolicyManager: CustomServerTrustPoliceManager()), plugins: [NetworkLoggerPlugin(verbose: true)])
    private static let keychain = KeychainSwift()
    
    static func searchCars(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        _ = self.provider.request(.searchCars(latitude: latitude, longitude: longitude, radius: radius)).subscribe { event in
            switch event {
            case .next(let response):
                let json = String(data: response.data, encoding: .utf8)
                print(json ?? "")
            case .error(let error):
                print(error.localizedDescription)
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
        case .searchCars(let latitude, let longitude, let radius):
            return ["lat": latitude, "lon": longitude, "radius": radius]
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
