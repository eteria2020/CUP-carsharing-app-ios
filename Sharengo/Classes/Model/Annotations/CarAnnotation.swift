//
//  CarAnnotation.swift
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import GoogleMaps

/**
 CarAnnotation class is the GMUClusterItem that application uses to show car location (single pin or cluster)
 */
public class CarAnnotation: NSObject, GMUClusterItem {
    /// Variable used to check cars cluster identifier
    public var identifier: Int32
    /// Variable used to give cluster unique identifier
    public var uniqueIdentifier: String
    /// Variable used to check cars cluster type
    public var type: Int32
    /// Variable used to save the position of the marker
    public var position: CLLocationCoordinate2D
    /// Variable used to save the image to show in the marker
    public var marker: UIImage
    /// Variable used to save the car
    public var car: Car
    /// Variable used to save if the annotation can be clustered
    public var canCluster: Bool = true
    /// Variable used to save car plate
    public var carPlate: String = ""
    
    // MARK: - Init methods
    
    public init(position: CLLocationCoordinate2D, car: Car, carBooked: Car?, carTrip: CarTrip?, carNearest: Car?) {
        self.position = position
        self.car = car
        self.identifier = 1
        self.type = 1
        self.uniqueIdentifier = car.plate ?? "0"
        self.marker = UIImage(named: "ic_auto")!
        super.init()
        //viene passato un solo bonus alla volta dalle API o nouse o Unplug
        let bonusFree = car.bonus.filter({ (bonus) -> Bool in
            return bonus.status == true && bonus.value > 0
        })
        if bonusFree.count > 0 {
            let bonus = bonusFree[0]
            if bonus.type == "nouse"{
                let image = self.freeImage(image: UIImage(named: "ic_auto_free")!, value: bonus.value)
                self.marker = image
            }else if bonus.type == "unplug"{
                 let image = self.freeImage(image: UIImage(named: "ic_auto_unplug")!, value: bonus.value)
                 self.marker = image
            }
        
        }
        if car.booked && (carTrip == nil || carTrip?.car.value?.parking == true) {
            self.marker = CoreController.shared.pulseYellow
            self.type = 3
        } else if car.plate == carNearest?.plate && carBooked == nil {
            if bonusFree.count > 0 {
                let bonus = bonusFree[0]
                if bonus.type == "nouse"{
                    let image = self.freeImage(image: UIImage(named: "ic_auto_free")!, value: bonus.value)
                    self.marker = image
                }else if bonus.type == "unplug"{
                    let image = self.freeImage(image: UIImage(named: "ic_auto_unplug")!, value: bonus.value)
                    self.marker = image
                }
            } else {
                self.marker = CoreController.shared.pulseGreen
            }
            self.type = 2
        }
    }
    
    /**
     This method create image with paragraph
     - Parameter image: Image value
     - Parameter value: Int value
     */
    public func freeImage(image: UIImage, value: Int) -> (UIImage) {
        let newSize = CGSize(width: image.size.width, height: image.size.height)
        let newOrigin = CGPoint(x: (newSize.width - newSize.width)/2, y: (newSize.height - newSize.height)/2)
        let thumbRect = CGRect(origin: newOrigin, size: newSize).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: thumbRect)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs = [NSFontAttributeName: UIFont(name: "Poppins-SemiBold", size: 12)!, NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: paragraphStyle]
        let string = "\(value)"
        let thumbRect2 = CGRect(origin: CGPoint(x: (newSize.width - newSize.width)/2, y: (newSize.height - newSize.height)/2 + 16), size: newSize).integral
        string.draw(in: thumbRect2, withAttributes: attrs)

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
