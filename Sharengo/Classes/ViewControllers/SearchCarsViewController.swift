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
import Action

class SearchCarsViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView! // TODO: ???
    
    var viewModel: SearchCarsViewModel?
    
    // MARK: - ViewModel methods
    
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
   
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NavigationBar
        view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // CircularMenu
        view_circularMenu.bind(to: ViewModelFactory.circularMenu(type: .searchCars))
        view_circularMenu.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
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
        // SearchBar
        let searchBarViewController:SearchBarViewController = (Storyboard.main.scene(.searchBar))
        self.view.addSubview(searchBarViewController.view)
        self.addChildViewController(searchBarViewController)
        searchBarViewController.didMove(toParentViewController: self)
        searchBarViewController.view.isUserInteractionEnabled = false
    }
}
