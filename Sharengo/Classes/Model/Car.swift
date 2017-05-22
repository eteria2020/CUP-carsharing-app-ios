//
//  Car.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

class Car: ModelType, Decodable {
    /*
     JSON response example:
    {
     "plate":"ED93147",
     "manufactures":"Xindayang Ltd.",
     "model":"ZD 80",
     "label":"/",
     "active":true,
     "int_cleanliness":"clean",
     "ext_cleanliness":"clean",
     "notes":"1929",
     "longitude":"9.24313",
     "latitude":"45.51891",
     "damages":
        [
        "Paraurti posteriore",
        "Porta sin","Led anteriore dx"
        ],
     "battery":73,
     "frame":null,
     "location":"0101000020E61000005C5A0D897B7C22409FC893A46BC24640",
     "firmware_version":"V4.6.3",
     "software_version":"0.104.10",
     "Mac":null,
     "imei":"861311004706528",
     "last_contact":"2017-05-13T10:36:02.000Z",
     "last_location_time":"2017-05-13T10:36:02.000Z",
     "busy":false,
     "hidden":false,
     "rpm":0,
     "speed":0,
     "obc_in_use":0,
     "obc_wl_size":65145,
     "km":6120,
     "running":false,
     "parking":false,
     "status":"operative",
     "soc":73,
     "vin":null,
     "key_status":"OFF",
     "charging":false,
     "battery_offset":0,
     "gps_data":
        {
        "time":"13/05/2017 12:35:49",
        "fix_age":20,
        "accuracy":1.4199999570846558,
        "change_age":20,"satellites":10
        },
     "park_enabled":false,
     "plug":false,
     "fleet_id":1,
     "fleets":
        {
        "id":1,
        "label":"Milano"
        }
    }
    */
    
    var plate:String?

    required init?(json: JSON) {
        plate = "plate" <~~ json
    }
}
