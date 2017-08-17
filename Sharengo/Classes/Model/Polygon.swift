//
//  Polygon.swift
//  Sharengo
//
//  Created by Dedecube on 13/08/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Boomerang
import RxSwift
import Gloss

public class PolygonCache: NSObject, NSCoding {
    var type: String = ""
    var coordinates: [CLLocationCoordinate2D] = []
    
    init(type: String, coordinates: [CLLocationCoordinate2D]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    // MARK: - Coding methods
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type, forKey: "type")
        
        var coordinatesToEncode = [[String: Double]]()
        for coordinate in coordinates {
            coordinatesToEncode.append(["latitude": coordinate.latitude, "longitude": coordinate.longitude] )
        }
        aCoder.encode(coordinatesToEncode, forKey: "coordinates")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let type = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = type
        }
        
        if let coordinatesDecoded = aDecoder.decodeObject(forKey: "coordinates") as? [[String: Double]]
        {
            var coordinates = [CLLocationCoordinate2D]()
            for coordinateDecoded in coordinatesDecoded {
                coordinates.append(CLLocationCoordinate2D(latitude: coordinateDecoded["latitude"]!, longitude: coordinateDecoded["longitude"]!))
            }
            
            self.coordinates = coordinates
        }
    }
    
    // MARK: - Polygon methods
    
    func getPolygon() -> Polygon {
        return Polygon(type: self.type, coordinates: self.coordinates)
    }
}

public class JSONPolygons: ModelType, Decodable {
    var polygons: [Polygon] = []
    required public init?(json: JSON) {
        var exit: Bool = false
        var index: Int = 0
        while !exit {
            var polygonCreated: Bool = false
            var JSONPolygon = "\(index)" <~~ json ?? [String: AnyObject]()
            if JSONPolygon.keys.count > 0 {
                if let JSONType = (JSONPolygon["type"] as? String),
                    let JSONCoordinates = JSONPolygon["coordinates"] as? [[[Double]]]
                {
                    var coordinates: [CLLocationCoordinate2D] = []
                    for arrayOfCoordinates in JSONCoordinates[0] {
                        if arrayOfCoordinates.count == 2 {
                            let longitude = arrayOfCoordinates[0]
                            let latitude = arrayOfCoordinates[1]
                            coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        }
                    }
                    if coordinates.count > 0 {
                        self.polygons.append(Polygon(type: JSONType, coordinates: coordinates))
                        polygonCreated = true
                    }
                }
                if !polygonCreated {
                    if let areaUse = JSONPolygon["areaUse"] as? String {
                        if let data = areaUse.data(using: String.Encoding.utf8) {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                                    JSONPolygon = json
                                    if let JSONType = (JSONPolygon["type"] as? String),
                                        let JSONCoordinates = JSONPolygon["coordinates"] as? [[[Double]]]
                                    {
                                        var coordinates: [CLLocationCoordinate2D] = []
                                        for arrayOfCoordinates in JSONCoordinates[0] {
                                            if arrayOfCoordinates.count == 2 {
                                                let longitude = arrayOfCoordinates[0]
                                                let latitude = arrayOfCoordinates[1]
                                                coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                                            }
                                        }
                                        if coordinates.count > 0 {
                                            self.polygons.append(Polygon(type: JSONType, coordinates: coordinates))
                                            polygonCreated = true
                                        }
                                    }
                                }
                            } catch {
                                print("Something went wrong")
                            }
                        }
                    }
                }
            }
            index += 1
            
            if index == 1000 {
                exit = true
            }
        }
    }
}

public class Polygon: ModelType {
    /*
     JSON response example:
     "type": "Polygon",
     "coordinates": [
     [
     [
     9.1592502593994,
     45.522931576139
     ],
     [
     9.1505876736107,
     45.521279981882
     ]
     }
    */
    
    var type: String = ""
    var coordinates: [CLLocationCoordinate2D] = []
    
    init(type: String, coordinates: [CLLocationCoordinate2D]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    // MARK: - PolygonCache methods
    
    func getPolygonCache() -> PolygonCache {
        return PolygonCache(type: self.type, coordinates: self.coordinates)
    }
}
