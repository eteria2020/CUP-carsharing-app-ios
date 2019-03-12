//
//  CircularMenuView.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift

import Action

/**
 Struct used to store info about buttons
 */
public struct ButtonSection {
    var midValue: CGFloat = 0.0
    var minValue: CGFloat = 0.0
    var maxValue: CGFloat = 0.0
    var sector = 0
}

/**
 The Circular menu class is a view that adds a circular menu on the screen with typology-dependent buttons
 */
public class CircularMenuView: UIView {
    @IBOutlet fileprivate weak var view_main: UIView!
    @IBOutlet fileprivate weak var view_background: UIView!
    /// Main view of the circular menu
    public var view: UIView!
    /// Variable used to save buttons
    public var array_buttons: [CircularMenuButton] = []
    /// Variable used to save buttons section
    public var array_buttons_sections: [ButtonSection] = []
    /// ViewModel variable used to represents the data
    public var viewModel: CircularMenuViewModel?
    /// Variable used to save start transform for rotation
    public var startTransform: CGAffineTransform = CGAffineTransform()
    /// Variable used to save delta angle for rotation
    public var deltaAngle: Float = 0.0
    /// Variable used to save rotation for rotation
    public var rotationAngle: Float = 0.0

    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CircularMenuViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
    }
    
    // MARK: - View methods
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        guard let type = viewModel?.type else {
            return
        }
        self.layoutIfNeeded()
        self.view_background.backgroundColor = type.getBackgroundViewColor()
        self.view_background.layer.borderColor = type.getBackgroundBorderColor().cgColor
        self.view_background.layer.borderWidth = type.getBackgroundBorderSize()
        self.view_background.layer.cornerRadius = self.view_background.frame.size.width/2
        self.view_background.layer.masksToBounds = true
        self.generateButtons()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.circularMenu.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Touches methods
    
    /**
     This method is called when a touch begans on circular menu
     */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.viewModel?.type.getItems().count ?? 0 > 3 {
            let touch = touches.first!
            let location = touch.location(in: self)
            let dx = location.x - self.center.x
            let dy = location.y - self.center.y
            deltaAngle = atan2(Float(dy), Float(dx))
            startTransform = self.transform
        }
    }
    
    /**
     This method is called when a touch moves on circular menu
     */
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.viewModel?.type.getItems().count ?? 0 > 3 {
            let touch = touches.first!
            let location = touch.location(in: self)
            let dx = location.x - self.center.x
            let dy = location.y - self.center.y
            let ang = atan2(dy, dx)
            let angleDifference = deltaAngle - Float(ang)
            startTransform = self.transform.rotated(by: -(CGFloat)(angleDifference))
            let radians = atan2f(Float(startTransform.b), Float(startTransform.a))
            let degrees = radians * Float(180 / Double.pi)
            if degrees < 0 && degrees > -33 {
                self.transform = self.transform.rotated(by: -(CGFloat)(angleDifference))
                for button in self.array_buttons {
                    button.transform = button.transform.rotated(by: (CGFloat)(angleDifference))
                }
                self.rotationAngle = radians
            }
        }
    }
    
    /**
     This method is called when a touch ends on circular menu
     */
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.viewModel?.type.getItems().count ?? 0 > 3 {
            let radians = atan2f(Float(self.transform.b), Float(self.transform.a))
            var newVal: CGFloat = 0.0
            for section in array_buttons_sections {
                if (radians > Float(section.minValue) && radians < Float(section.maxValue)) {
                    newVal = CGFloat(radians) - section.midValue
                }
            }
            UIView.animate(withDuration: 0.2) {
                self.transform = self.transform.rotated(by: -(CGFloat)(newVal))
                for button in self.array_buttons {
                    button.transform = button.transform.rotated(by: (CGFloat)(newVal))
                }
                self.rotationAngle = radians
            }
        }
    }
    
    /**
     This method is used to enable touch in specific points of the circular menu
     */
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in view_main.subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        let circlePath1 = UIBezierPath(arcCenter: self.view_background.center, radius: CGFloat(self.view_background.frame.size.width/2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let circlePath2 = UIBezierPath(arcCenter: self.view_background.center, radius: CGFloat((self.view_background.frame.size.width/2)-(self.viewModel?.type.getBackgroundBorderSize() ?? 0.0)), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        if circlePath1.contains(point) && !circlePath2.contains(point) {
            return true
        }
        return false
    }
    
    // MARK: - Buttons methods
    
    /**
     This method is called to initialize buttons and buttons sections in circular menu
     */
    public func generateButtons() {
        guard let viewModel = viewModel else {
            return
        }
        let numberOfButtons: Int = 11
        var curAngle: CGFloat = 3.42719
        let incAngle: CGFloat = (360.0/CGFloat(numberOfButtons))*CGFloat.pi/180
        let circleCenter: CGPoint = self.view_main.center
        let circleRadius: CGFloat = (self.view_main.bounds.size.width/2)-(viewModel.type.getBackgroundBorderSize()/2)
        
        let fanWidth = (Double.pi * 2) / Double(numberOfButtons)
        var mid: CGFloat = 0.0
        
        for i in 0..<numberOfButtons {
            if viewModel.type.getItems().count > i {
                let menuItem = viewModel.type.getItems()[i]
                let button = CircularMenuButton(type: .custom)
                button.circularMenuView = self
                button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height*0.065, height: UIScreen.main.bounds.height*0.065)
                button.layer.cornerRadius = button.frame.size.width/2
                button.layer.masksToBounds = true
                let buttonX: CGFloat = circleCenter.x+cos(curAngle)*circleRadius
                let buttonY: CGFloat = circleCenter.y+sin(curAngle)*circleRadius
                button.center = CGPoint(x: buttonX, y: buttonY)
                button.setBackgroundImage(UIImage(named: menuItem.icon), for: .normal)
                button.rx.bind(to: viewModel.selection, input: menuItem.input)
                view_main.addSubview(button)
                array_buttons.append(button)
                var buttonSection = ButtonSection()
                buttonSection.midValue = mid
                buttonSection.minValue = mid - CGFloat(fanWidth / 2)
                buttonSection.maxValue = mid + CGFloat(fanWidth / 2)
                buttonSection.sector = i
                if (buttonSection.maxValue - CGFloat(fanWidth) < -CGFloat(Double.pi)) {
                    mid = CGFloat(Double.pi)
                    buttonSection.midValue = mid
                    buttonSection.minValue = CGFloat(fabsf(Float(buttonSection.maxValue)))
                    
                }
                mid -= CGFloat(fanWidth)
                array_buttons_sections.append(buttonSection)
                curAngle += incAngle
            }
        }
    }
    
    // MARK: - Utility methods
    
    /**
     This method is used to calculate distance from one point to the center of the view
     - Parameter point: Point to calculate
     */
    func calculateDistanceFromCenter(point: CGPoint) -> Float
    {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(Float(dx*dx + dy*dy))
    }
}
