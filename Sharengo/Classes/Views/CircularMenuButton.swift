//
//  CircularMenuButton.swift
//  Sharengo
//
//  Created by Dedecube on 17/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import Boomerang
import Action

class CircularMenuButton: UIButton {
    var circularMenuView: CircularMenuView?
    var originalPoint: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.circularMenuView?.touchesBegan(touches, with: event)
        
        self.originalPoint = self.superview?.convert(CGPoint.zero, from: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesMoved(touches, with: event)

        if let point: CGPoint = touches.first?.location(in: self) {
            if !((point.x < 0 || point.x > bounds.width) ||
                (point.y < 0 || point.y > bounds.height)) {
                if !(self.originalPoint != self.superview?.convert(CGPoint.zero, from: self))
                {
                    super.touchesMoved(touches, with: event)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesEnded(touches, with: event)
        
        if let point: CGPoint = touches.first?.location(in: self) {
            if !((point.x < 0 || point.x > bounds.width) ||
                (point.y < 0 || point.y > bounds.height)) {
                if !(self.originalPoint != self.superview?.convert(CGPoint.zero, from: self))
                {
                    super.touchesEnded(touches, with: event)
                }
            }
        }
        
        self.isHighlighted = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.circularMenuView?.touchesCancelled(touches, with: event)
    }
}
