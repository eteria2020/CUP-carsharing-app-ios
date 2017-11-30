//
//  Response.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

/**
 The Response model is used to convert api response in an object that has useful data from server
*/
public class Response: ModelType, Decodable {
    /// Status code of response (200, 404, ...)
    public var status: Int?
    /// Status code used from publisheres api
    public var status_bool: Bool?
    /// Message that describe how response is gone
    public var code: String?
    /// Message that describe how response is gone
    public var msg: String?
    /// Content of data as array
    public var array_data: [JSON]?
    /// Content of data as dictionary
    public var dic_data: JSON?
    /// Content of reason as string
    public var reason: String?
    
    // MARK: - Init methods
    
    public init() {
    }
    
    public required init?(json: JSON) {
        self.status = "status" <~~ json
        self.status_bool = "status" <~~ json
        self.code = "code" <~~ json
        self.msg = "msg" <~~ json
        self.array_data =  "data" <~~ json
        self.dic_data = "data" <~~ json
        self.reason = "reason" <~~ json
    }
}
