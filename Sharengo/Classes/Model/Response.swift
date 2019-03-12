//
//  Response.swift
//
//  Created by Dedecube on 28/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//


import RxSwift
import Gloss

/**
 The Response model is used to convert api response in an object that have useful data from server like code
*/
public class Response: ModelType, Gloss.JSONDecodable {
    /// HTTP Status code of response (200, 404, ...)
    public var status: Int?
    /// Boolean that determine if status is present or not
    public var status_bool: Bool?
    /// Description of response
    public var reason: String?
    /// Generic code
    var code: String?
    /// Message that describe how response is gone
    var msg: String?
    /// Content of data as array
    var array_data: [JSON]?
    /// Content of data as dictionary
    var dic_data: JSON?
    
    // MARK: - Init methods
    
    public init() {
    }
    
    public required init?(json: JSON) {
        self.status = "status" <~~ json
        self.status_bool = self.status != nil
        self.reason = "reason" <~~ json
        self.code = "code" <~~ json
        self.msg = "msg" <~~ json
        
        if let array = json["data"] as? [JSON]
        {
            self.array_data =  array
        }

        if let dict = json["data"] as? JSON
        {
            self.dic_data = dict
        }
    }
    
    
}
