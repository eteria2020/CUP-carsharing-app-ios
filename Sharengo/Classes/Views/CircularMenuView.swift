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

enum CircularMenuType {
    case empty
    case searchCars
    
    func getBackgroundBorderColor() -> UIColor {
        switch self {
        case .searchCars:
            return Color.circularMenuBackgroundBorder.value
        default:
            return UIColor()
        }
    }
    
    func getBackgroundBorderSize() -> CGFloat {
        switch self {
        case .searchCars:
            return UIScreen.main.bounds.height*0.08
        default:
            return 0
        }
    }
    
    func getBackgroundViewColor() -> UIColor {
        switch self {
        case .searchCars:
            return Color.circularMenuBackground.value
        default:
            return UIColor()
        }
    }
    
    func getItems() -> [CircularMenuItem] {
        switch self {
        case .searchCars:
            return [CircularMenuItem(icon: "ic_referesh", input: .refresh),
                    CircularMenuItem(icon: "ic_center", input: .center),
                    CircularMenuItem(icon: "ic_compass", input: .compass),
            ]
        default:
            return []
        }
    }
}

struct CircularMenuItem {
    let icon: String
    let input: CircularMenuInput
}

public enum CircularMenuInput: SelectionInput {
    case refresh
    case center
    case compass
}

public enum CircularMenuOutput: SelectionInput {
    case empty
    case refresh
    case center
    case compass
}

@IBDesignable class CircularMenuView: UIView {
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var view_background: UIView!
    
    fileprivate var view: UIView!
    fileprivate var array_buttons: [UIButton] = []
    var type: CircularMenuType = .empty {
        didSet {
            self.layoutIfNeeded()
            self.view_background.backgroundColor = self.type.getBackgroundViewColor()
            self.view_background.layer.borderColor = self.type.getBackgroundBorderColor().cgColor
            self.view_background.layer.borderWidth = self.type.getBackgroundBorderSize()
            self.view_background.layer.cornerRadius = self.view_background.frame.size.width/2
            self.view_background.layer.masksToBounds = true
            self.generateButtons()
        }
    }
    public var selection: Action<CircularMenuInput, CircularMenuOutput> = Action { _ in
        return .just(.empty)
    }
    
    // MARK: - View methods
    
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
        self.selection = Action { input in
            switch input {
            case .refresh:
                return .just(.refresh)
            case .center:
                return .just(.center)
            case .compass:
                return .just(.compass)
            }
        }
    }
    
    fileprivate func loadViewFromNib() -> UIView
    {
        let nib = ViewXib.circularMenu.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    // MARK: - Buttons methods
    
    fileprivate func generateButtons() {
        let numberOfButtons: Int = 11
        var curAngle: CGFloat = 3.42719
        let incAngle: CGFloat = (360.0/CGFloat(numberOfButtons))*CGFloat.pi/180
        let circleCenter: CGPoint = self.view_main.center
        let circleRadius: CGFloat = (self.view_main.bounds.size.width/2)-(self.type.getBackgroundBorderSize()/2)
        for i in 0..<numberOfButtons {
            if self.type.getItems().count > i {
                let menuItem = self.type.getItems()[i]
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height*0.065, height: UIScreen.main.bounds.height*0.065)
                button.layer.cornerRadius = button.frame.size.width/2
                button.layer.masksToBounds = true
                let buttonX: CGFloat = circleCenter.x+cos(curAngle)*circleRadius
                let buttonY: CGFloat = circleCenter.y+sin(curAngle)*circleRadius
                button.center = CGPoint(x: buttonX, y: buttonY)
                button.setBackgroundImage(UIImage(named: menuItem.icon), for: .normal)
                button.rx.bind(to: selection, input: menuItem.input)
                view_main.addSubview(button)
                array_buttons.append(button)
                curAngle += incAngle
            }
        }
    }
}
