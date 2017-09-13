//
//  RouteStepRouteStep.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class RouteStep: ModelType, Decodable {
    /*
     JSON response example:
     {
     "distance" : {
     "text" : "87 m",
     "value" : 87
     },
     "duration" : {
     "text" : "1 min",
     "value" : 63
     },
     "end_location" : {
     "lat" : 41.8909852,
     "lng" : 12.49189
     },
     "html_instructions" : "Head \u003cb\u003enorthwest\u003c/b\u003e on \u003cb\u003ePiazza del Colosseo\u003c/b\u003e",
     "polyline" : {
     "points" : "yxt~Fs_gkAAFKVEZCTCVARAb@@X@L"
     },
     "start_location" : {
     "lat" : 41.8908484,
     "lng" : 12.4928967
     },
     "travel_mode" : "WALKING"
     }
     */
    
//    var startLocation: CLLocation?
//    var endLocation: CLLocation?
  
    required public init?(json: JSON) {
    }
}
