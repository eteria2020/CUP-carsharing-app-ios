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
    var moveInProgress: Bool = false
    var touchPoint: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.circularMenuView?.touchesBegan(touches, with: event)
        let touch:UITouch = touches.first! as UITouch
        touchPoint = touch.location(in: self)
        self.moveInProgress = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
        let firstTouch:UITouch = touches.first! as UITouch
        let firstTouchLocation = firstTouch.location(in: self)
        if touchPoint != firstTouchLocation {
            self.moveInProgress = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesEnded(touches, with: event)
        if !self.moveInProgress {
           super.touchesEnded(touches, with: event)
        }
        self.isHighlighted = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.circularMenuView?.touchesCancelled(touches, with: event)
    }
}
