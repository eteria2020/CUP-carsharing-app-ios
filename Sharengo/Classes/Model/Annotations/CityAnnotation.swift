//
//  CityAnnotation.swift
//
//  Created by Dedecube on 05/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

/**
 CityAnnotation class is the GMSMarker that application uses to show city location
 */
public class CityAnnotation: GMSMarker {
    /// Variable used to save the city
    public var city: City?
    
    /**
     This method get image for city annotation depending on nearest car or booked car or car trip available
     - Parameter bookedCity: A boolean variable that says to application if the city annotation is a city with booked car or car trip
     - Parameter nearestCity: A boolean variable that says to application if the city annotation is a city with nearest car
     */
    public func getImage(bookedCity: Bool, nearestCity: Bool) -> UIImage {
        if let icon = self.city?.icon, let url = URL(string: icon) {
            do {
                let data = try Data(contentsOf: url)
                if let cityImage = UIImage(data: data) {
                    let size = CGSize(width: 50, height: 50)
                    let topImage = self.resizeImageForCluster(image: cityImage.tinted(ColorBrand.green.value), newSize: size)
                    return topImage
                }
            } catch {
                let fileManager = FileManager.default
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(url.lastPathComponent)
                if fileManager.fileExists(atPath: paths){
                    if let image = UIImage(contentsOfFile: paths) {
                        let size = CGSize(width: 50, height: 50)
                        let topImage = self.resizeImageForCluster(image: image.tinted(ColorBrand.green.value), newSize: size)
                        return topImage
                    }
                }
            }
        }
        return UIImage(named: "ic_cluster")!
    }
    
    /**
     This method resize image for Cluster
     - Parameter image: Image to be resized
     - Parameter newSize: Size of image resized
     */
    public func resizeImageForCluster(image: UIImage, newSize: CGSize) -> (UIImage) {
        let scale = min(image.size.width/newSize.width, image.size.height/newSize.height)
        let newSize = CGSize(width: image.size.width/scale, height: image.size.height/scale)
        let newOrigin = CGPoint(x: (newSize.width - newSize.width)/2, y: (newSize.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let bottomImage = UIImage(named: "ic_cluster")!
        bottomImage.draw(in: thumbRect)
        image.draw(in: thumbRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }

    /**
     This method draw two images in unique image with a specific size
     - Parameter image1: First image
     - Parameter image2: Second image
     - Parameter newSize: Size of image returned
     */
    public func drawImageForAnimation(image1: UIImage, image2: UIImage, newSize: CGSize) -> (UIImage) {
        let scale = min(image2.size.width/newSize.width, image2.size.height/newSize.height)
        let newSize = CGSize(width: image2.size.width/scale, height: image2.size.height/scale)
        let newSize2 = CGSize(width: image1.size.width, height: image1.size.height)
        let newOrigin = CGPoint(x: (newSize2.width - newSize.width)/2, y: (newSize2.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        let newOrigin2 = CGPoint(x: 0, y: 0)
        let thumbRect2 = CGRect(origin: newOrigin2, size: newSize2).integral
        UIGraphicsBeginImageContextWithOptions(newSize2, false, 0)
        image1.draw(in: thumbRect2)
        image2.draw(in: thumbRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
