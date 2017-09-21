//
//  SharengoApiController.swift
//
//  Created by Dedecube on 13/08/17.
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

/**
Sharengo API controller is class thant manage web services of sharengo servers
*/
public class SharengoApiController {
    /// Session Manager
    public var manager: SessionManager?
    
    // MARK: - Init methods
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForResource = 20
        configuration.timeoutIntervalForRequest = 20
        self.manager = Alamofire.SessionManager(
            configuration: configuration
        )
    }
    
    /**
     This method return polygons from server
     */
    public func getPolygons() -> Observable<[Polygon]> {
        return Observable.create{ observable in
            let provider = RxMoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.request(.polygons())
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapObject(type: JSONPolygons.self)
                .subscribe { event in
                    switch event {
                    case .next(let JSONPolygons):
                        observable.onNext(JSONPolygons.polygons)
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

/// Enum with api calls
public enum API {
    case polygons()
}

extension API: TargetType {
    var baseURL: URL { return URL(string: "http://www.sharengo.it")! }
    
    var path: String {
        switch self {
        case .polygons():
            return "zone"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .polygons():
            return ["format": "json"]
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
