//
//  SharengoApiController.swift
//
//  Created by Dedecube on 13/08/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import Moya
import Gloss
import RxSwift
import MapKit
import Alamofire

// NetworkLoggerPlugin(verbose: true, cURL: true)
//per loggare aggiungere ad plugin

struct ManageNetworkLoaderUI {
    static func update(with status: NetworkActivityChangeType)
    {
        DispatchQueue.main.async {
            switch status
            {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

final class SharengoApiController {
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
    
    func getPolygons() -> Observable<[Polygon]> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkActivityPlugin(networkActivityClosure: { (status, _) in ManageNetworkLoaderUI.update(with: status) })])
            return provider.rx.request(.polygons)
                .asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONObject(type: JSONPolygons.self)
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
    
    func getOsmAdress(text: String) -> Observable<[Address]> {
        return Observable.create{ observable in
            let provider = MoyaProvider<API>(manager: self.manager!, plugins: [NetworkLoggerPlugin(verbose: true, cURL: true),NetworkActivityPlugin(networkActivityClosure: { (status, _) in
                switch status {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    
                  
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            })])
            return provider.rx.request(.osmAddress(text: text))
                .asObservable()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .mapJSONArray(type: Address.self)
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
    case polygons
    case osmAddress(text: String)
}

extension API: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        switch self {
        case .polygons:
          return URL(string: Config().site_Endpoint)!
            
        case .osmAddress(_):
           return URL(string: Config().osm_EndPoint)!
        }
    }
    
    var path: String {
        switch self {
        case .polygons:
            return "zone"
        
        case .osmAddress(_):
            return "search"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any] {
        switch self {
        case .polygons:
            return ["format": "json"]
        
        case .osmAddress(let text):
            return ["q": text, "format": "json" ,"polygon": "0", "addressdetails": "1", "countrycode": Config().language, "dedupe":"1"]
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
