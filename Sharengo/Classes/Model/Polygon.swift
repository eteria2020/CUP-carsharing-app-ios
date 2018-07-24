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

/**
 The PolygonCache model is used to represent a saved polygon on the device
*/
public class PolygonCache: NSObject, NSCoding {
    /// Polygon type
    public var type: String = ""
    /// Coordinates array of polygon
    public var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - Init methods
    
    public init(type: String, coordinates: [CLLocationCoordinate2D]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    /**
     This method is used to convert this object from NSCoder
     */
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

    // MARK: - Coding methods
    
    /**
     This method is used to convert this object as NSCoder
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.type, forKey: "type")
        
        var coordinatesToEncode = [[String: Double]]()
        for coordinate in coordinates {
            coordinatesToEncode.append(["latitude": coordinate.latitude, "longitude": coordinate.longitude] )
        }
        aCoder.encode(coordinatesToEncode, forKey: "coordinates")
    }
    
    // MARK: - Polygon methods
    
    /**
     This method return polygon connected to polygon cache
     */
    public func getPolygon() -> Polygon {
        return Polygon(type: self.type, coordinates: self.coordinates)
    }
}

/**
 The JSONPolygons model is used to represent Polygon JSON Object
 */
public class JSONPolygons: ModelType, Gloss.Decodable {
    /// Array of polygons
    public var polygons: [Polygon] = []
    
    // Init methods
    
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

/**
 The Polygon model is used to represent a city polygon used in the map
*/
public class Polygon: ModelType {
    /// Polygon type
    public var type: String = ""
    /// Coordinates array of polygon
    public var coordinates: [CLLocationCoordinate2D] = []
    
    // MARK: - Init methods
    
    public init(type: String, coordinates: [CLLocationCoordinate2D]) {
        self.type = type
        self.coordinates = coordinates
    }
    
    // MARK: - PolygonCache methods
    
    /**
     This method return polygon cache connected to polygon
     */
    public func getPolygonCache() -> PolygonCache {
        return PolygonCache(type: self.type, coordinates: self.coordinates)
    }
}
