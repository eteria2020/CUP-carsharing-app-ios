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
import RxCocoa
import Boomerang
import Action

class SearchCarsViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    
    var viewModel: SearchCarsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_circularMenu.type = .searchCars
        view_circularMenu.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .refresh:
                print("Refresh button tapped")
                break
            case .center:
                print("Center button tapped")
                break
            case .compass:
                print("Compass button tapped")
                break
            default:break
            }
        }).addDisposableTo(self.disposeBag)
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
