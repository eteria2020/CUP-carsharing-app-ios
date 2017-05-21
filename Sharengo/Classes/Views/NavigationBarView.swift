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

@IBDesignable class NavigationBarView: UIView {
    @IBOutlet weak var btn_left: UIButton!
    @IBOutlet weak var btn_right: UIButton!
    
    fileprivate var view: UIView!
    
    var viewModel: NavigationBarViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NavigationBarViewModel else {
            return
        }
        self.viewModel = viewModel
        self.setupInterface()
    }
    
    // MARK: - View methods
    
    fileprivate func setupInterface() {
        guard let viewModel = viewModel else {
            return
        }
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.navigationBarBackground.value
        self.btn_left.setBackgroundImage(UIImage(named: viewModel.letfItem.icon), for: .normal)
        self.btn_left.rx.bind(to: viewModel.selection, input: viewModel.letfItem.input)
        self.btn_right.setBackgroundImage(UIImage(named: viewModel.rightItem.icon), for: .normal)
        self.btn_right.rx.bind(to: viewModel.selection, input: viewModel.rightItem.input)
        // TODO: ???
        self.btn_left.setBackgroundImage(UIImage(named: viewModel.letfItem.icon), for: .highlighted)
        self.btn_right.setBackgroundImage(UIImage(named: viewModel.rightItem.icon), for: .highlighted)
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
        let nib = ViewXib.navigationBar.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
