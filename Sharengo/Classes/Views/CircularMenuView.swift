//
//  CircularMenuView.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action

@IBDesignable class CircularMenuView: UIView {
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var view_background: UIView!
    
    fileprivate var view: UIView!
    fileprivate var array_buttons: [UIButton] = []
    
    var viewModel: CircularMenuViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CircularMenuViewModel else {
            return
        }
        self.viewModel = viewModel
        self.setupInterface()
    }
    
    // MARK: - View methods
    
    fileprivate func setupInterface() {
        self.layoutIfNeeded()
        guard let viewModel = viewModel else {
            return
        }
        self.view_background.backgroundColor = viewModel.type.getBackgroundViewColor()
        self.view_background.layer.borderColor = viewModel.type.getBackgroundBorderColor().cgColor
        self.view_background.layer.borderWidth = viewModel.type.getBackgroundBorderSize()
        self.view_background.layer.cornerRadius = self.view_background.frame.size.width/2
        self.view_background.layer.masksToBounds = true
        self.generateButtons()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    fileprivate func xibSetup()
    {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView
    {
        let nib = ViewXib.circularMenu.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
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
