//
//  FeedAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

/**
 FeedAnnotation class is the GMUClusterItem that application uses to show feed location (single pin or cluster)
 */
public class FeedAnnotation: NSObject, GMUClusterItem {
    /// Variable used to give cluster unique identifier
    public var uniqueIdentifier: String
    /// Variable used to check feeds cluster identifier
    public var identifier: Int32
    /// Variable used to check feeds cluster type
    public var type: Int32
    /// Variable used to save the position of the marker
    public var position: CLLocationCoordinate2D
    /// Variable used to save the image to show in the marker
    public var marker: UIImage
    /// Variable used to save the feed
    public var feed: Feed
    /// Variable used to save if the annotation can be clustered
    public var canCluster: Bool = true
    /// Variable used to save car plate
    public var carPlate: String = ""
    
    // MARK: - Init methods
    
    public init(position: CLLocationCoordinate2D, feed: Feed) {
        self.position = position
        self.feed = feed
        self.identifier = 2
        self.type = 1
        self.marker = UIImage(named: "ic_puntatore-generico")!
        self.uniqueIdentifier = "0"
        super.init()
        if let icon = feed.marker, let url = URL(string: icon) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    var size = CGSize(width:38, height: 46)
                    if feed.sponsored {
                        size = CGSize(width: 46, height: 55)
                    }
                    let markerImage = self.resizeImageForAnnotation(image: image, newSize: size)
                    self.marker = markerImage
                }
            } catch {
            }
        }
    }
    
    /**
     This method resize image for annotation
     - Parameter image: Image to be resized
     - Parameter newSize: Size of image returned
     */
    public func resizeImageForAnnotation(image: UIImage, newSize: CGSize) -> (UIImage) {
        let scale = min(image.size.width/newSize.width, image.size.height/newSize.height)
        let newSize = CGSize(width: image.size.width/scale, height: image.size.height/scale)
        let newOrigin = CGPoint(x: (newSize.width - newSize.width)/2, y: (newSize.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: thumbRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
