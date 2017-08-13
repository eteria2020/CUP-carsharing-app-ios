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
    /// Variable used to get the image to show in the marker
    public lazy var image: UIImage = self.getImage()
    
    func getImage() -> UIImage {
        if let icon = self.city?.icon, let url = URL(string: icon) {
            do {
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    let size = CGSize(width: 50, height: 50)
                    let topImage = self.resizeImageForCluster(image: image.tinted(ColorBrand.green.value), newSize: size)
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
    
    fileprivate func resizeImageForCluster(image: UIImage, newSize: CGSize) -> (UIImage) {
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
}
