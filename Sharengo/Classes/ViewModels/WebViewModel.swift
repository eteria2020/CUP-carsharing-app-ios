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
 Enum that specifies web type (url)
 */
public enum WebType: String {
    case empty = ""
    case forgotPassword = "https://www.sharengo.it/forgot-password/mobile"
    case signup = "http://www.sharengo.it/signup/mobile"
}

/**
 The WebViewModel provides data related to display share'ngo url pages to user
 */
public class WebViewModel: ViewModelType {
    /// Web type
    public var type: WebType = .empty
    /// Url request created with page url
    public var urlRequest: URLRequest?
  
    // MARK: - Init methods
    
    public init(with type: WebType) {
        self.type = type
        self.clearCacheCookie()
        let url = URL(string: type.rawValue)
        self.urlRequest = URLRequest(url: url!)
    }

    // MARK: - Utilities methods
    
    /**
     This method clears cache and cookie of a loaded page
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
