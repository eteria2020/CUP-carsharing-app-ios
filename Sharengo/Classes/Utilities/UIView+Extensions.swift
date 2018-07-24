//
//  UIView+Extensions.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

/**
 Int utilities
 */
public extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

/**
 FloatingPoint utilities
 */
public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

/**
 UIView utilities
 */
public extension UIView
{
    /**
     This method executes a rotation on z-axis
     - Parameter duration: duration in CFTimeInterval (default value is 1)
     - Parameter repeatCount: how many times it has to rotate (default value is infinity)
     - Parameter clockwise: rotation direction (default value is true)
     */
    public func startZRotation(duration: CFTimeInterval = 1, repeatCount: Float = Float.infinity, clockwise: Bool = true)
    {
        if self.layer.animation(forKey: "transform.rotation.z") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(value: Double.pi * 2 * direction)
        animation.duration = duration
        animation.isCumulative = true
        animation.repeatCount = repeatCount
        self.layer.add(animation, forKey:"transform.rotation.z")
    }
    
    /**
     This method stops a rotation on z-axis
     */
    public func stopZRotation()
    {
        self.layer.removeAnimation(forKey: "transform.rotation.z")
    }
}
