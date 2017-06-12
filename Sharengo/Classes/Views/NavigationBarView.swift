//
//  NavigationBarView.swift
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

class NavigationBarView: UIView {
    @IBOutlet fileprivate weak var btn_left: UIButton!
    @IBOutlet fileprivate weak var btn_right: UIButton!
    fileprivate var view: UIView!
    
    var viewModel: NavigationBarViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NavigationBarViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
        self.btn_left.rx.bind(to: viewModel.selection, input: viewModel.letfItem.input)
        self.btn_right.rx.bind(to: viewModel.selection, input: viewModel.rightItem.input)
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
        guard let letfItem = viewModel?.letfItem else {
            return
        }
        guard let rightItem = viewModel?.rightItem else {
            return
        }
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.navigationBarBackground.value
        self.btn_left.setBackgroundImage(UIImage(named: letfItem.icon), for: .normal)
        self.btn_right.setBackgroundImage(UIImage(named: rightItem.icon), for: .normal)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.navigationBar.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
