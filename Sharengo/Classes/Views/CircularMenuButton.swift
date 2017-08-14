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

/**
 The Circular menu button class is a subclass of UIButton used to add functionalities to circular menu buttons
 */
public class CircularMenuButton: UIButton {
    /// Reference to circular menu class
    public weak var circularMenuView: CircularMenuView?
    /// Variable used to save if a movement is going on
    public var moveInProgress: Bool = false
    /// Variable used to save the point touched from user
    public var touchPoint: CGPoint?
    
    // MARK: - Touches methods
    
    /**
     This method is called when a touch begans on button
     */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.circularMenuView?.touchesBegan(touches, with: event)
        let touch:UITouch = touches.first! as UITouch
        self.touchPoint = touch.location(in: self)
        self.moveInProgress = false
    }
    
    /**
     This method is called when a touch moves on button
     */
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
        let firstTouch:UITouch = touches.first! as UITouch
        let firstTouchLocation = firstTouch.location(in: self)
        if self.touchPoint != firstTouchLocation {
            self.moveInProgress = true
        }
    }
    
    /**
     This method is called when a touch ends on button
     */
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.circularMenuView?.touchesEnded(touches, with: event)
        if !self.moveInProgress {
           super.touchesEnded(touches, with: event)
        }
        self.isHighlighted = false
    }
    
    /**
     This method is called when a touch is cancelled on button
     */
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.circularMenuView?.touchesCancelled(touches, with: event)
    }
}
