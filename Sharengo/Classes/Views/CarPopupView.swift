//
//  CarPopupView.swift
//  Sharengo
//
//  Created by Dedecube on 27/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action

class CarPopupView: UIView {
    @IBOutlet weak var btn_open: UIButton!
    @IBOutlet weak var btn_book: UIButton!
    @IBOutlet weak var view_type: UIView!
    
    fileprivate var view: UIView!
    
    var viewModel: CarPopupViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarPopupViewModel else {
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
        viewModel.showType.asObservable()
            .subscribe(onNext: {[weak self] (showType) in
                DispatchQueue.main.async {
                    if showType {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 50
                    } else {
                        self?.view_type.constraint(withIdentifier: "typeHeight", searchInSubviews: false)?.constant = 0
                    }
                }
        }).addDisposableTo(disposeBag)
        self.layoutIfNeeded()
        self.view.backgroundColor = Color.carPopupBackground.value
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.carPopup.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
