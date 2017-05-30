//
//  HomeViewController.swift
//  Sharengo
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class HomeViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
    
    var viewModel: HomeViewModel?
  
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? HomeViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_searchCar.rx.bind(to: viewModel.selection, input: .searchCars)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_searchCar.backgroundColor = Color.homeSearchCarBackground.value
        self.view_searchCar.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_searchCar.layer.masksToBounds = true
    }
}
