//
//  SearchCarsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class SearchCarsViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    
    var viewModel: SearchCarsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_circularMenu.type = .searchCars
    }
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchCarsViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            }
        }).addDisposableTo(self.disposeBag)
        viewModel.reload()
    }
}
