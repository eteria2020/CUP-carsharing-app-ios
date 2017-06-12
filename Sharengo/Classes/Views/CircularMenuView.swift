//
//  CircularMenuView.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import Boomerang
import Action

class CircularMenuView: UIView {
    @IBOutlet fileprivate weak var view_main: UIView!
    @IBOutlet fileprivate weak var view_background: UIView!
    fileprivate var view: UIView!
    
    var array_buttons: [UIButton] = []
    var viewModel: CircularMenuViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CircularMenuViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
    }
    
    // MARK: - View methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
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
    
    fileprivate func generateButtons() {
        guard let viewModel = viewModel else {
            return
        }
        let numberOfButtons: Int = 11
        var curAngle: CGFloat = 3.42719
        let incAngle: CGFloat = (360.0/CGFloat(numberOfButtons))*CGFloat.pi/180
        let circleCenter: CGPoint = self.view_main.center
        let circleRadius: CGFloat = (self.view_main.bounds.size.width/2)-(viewModel.type.getBackgroundBorderSize()/2)
        for i in 0..<numberOfButtons {
            if viewModel.type.getItems().count > i {
                let menuItem = viewModel.type.getItems()[i]
                let button = UIButton(type: .custom)
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
                curAngle += incAngle
            }
        }
    }
    
}
