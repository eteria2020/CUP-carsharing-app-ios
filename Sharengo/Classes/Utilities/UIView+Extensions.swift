//
//  UIView+Extensions.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

/**
 UIView utilities
 */
public extension UIView
{
    /**
     This method execute a rotation on z-axis of a UIView
     - Parameter duration: duration in CFTimeInterval
     - Parameter repeatCount: how many times it has to rotate
     - Parameter clockwise: default value is true
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
     This method stop a rotation on z-axis of a UIView
     */
    public func stopZRotation()
    {
        self.layer.removeAnimation(forKey: "transform.rotation.z")
    }
}
