//
//  CircularMenuView.swift
//  Sharengo
//
//  Created by Dedecube on 19/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

enum CircularMenuType {
    case none
    case searchCars
    
    func getMainBorderColor() -> UIColor {
        switch self {
        case .searchCars:
            return Color.circularMenuBorder.value
        default:
            return UIColor()
        }
    }
    
    func getMainBorderSize() -> CGFloat {
        switch self {
        case .searchCars:
            return 50
        default:
            return 0
        }
    }
    
    func getMainViewColor() -> UIColor {
        switch self {
        case .searchCars:
            return Color.circularMenuMain.value
        default:
            return UIColor()
        }
    }
}

@IBDesignable class CircularMenuView: UIView {
    @IBOutlet weak var view_main: UIView!
    
    fileprivate var view: UIView!
    var type: CircularMenuType = .none {
        didSet {
            view_main.backgroundColor = type.getMainViewColor()
            view_main.layer.borderColor = type.getMainBorderColor().cgColor
            view_main.layer.borderWidth = type.getMainBorderSize()
            view_main.layer.cornerRadius = view_main.frame.size.width/2
            view_main.layer.masksToBounds = true
        }
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
    }
    
    fileprivate func loadViewFromNib() -> UIView
    {
        let nib = ViewXib.circularMenu.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
