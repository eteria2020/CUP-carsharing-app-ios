//
//  WebViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

/**
 Share'ngo urls
 */
public enum WebType: String {
    case empty = ""
    case forgotPassword = "https://www.sharengo.it/forgot-password/mobile"
    case signup = "http://www.sharengo.it/signup/mobile"
}

/**
 The Web viewmodel provides data related to display Share'ngo pages on WebVC
 */
public class WebViewModel: ViewModelType {
    public var type: WebType = .empty
    public var urlRequest:URLRequest?
  
    public init(with type: WebType) {
        self.type = type
        self.clearCacheCookie()
        let url = URL(string: type.rawValue)
        self.urlRequest = URLRequest(url: url!)
    }

    /**
     Clear cache and cookie of a loaded page
     */
    public func clearCacheCookie() {
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
