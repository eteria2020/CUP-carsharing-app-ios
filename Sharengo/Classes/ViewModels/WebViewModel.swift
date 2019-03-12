//
//  WebViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift

import Action

enum WebType: String {
    case empty = ""
    case forgotPassword = "https://www.sharengo.it/forgot-password/mobile"
    case signup = "http://www.sharengo.it/signup/mobile"
}

final class WebViewModel: ViewModelType {
    var type: WebType = .empty
    var urlRequest:URLRequest?
  
    init(with type: WebType) {
        self.type = type
        self.clearCacheCookie()
        let url = URL(string: type.rawValue)
        self.urlRequest = URLRequest(url: url!)
    }

    func clearCacheCookie() {
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
}
