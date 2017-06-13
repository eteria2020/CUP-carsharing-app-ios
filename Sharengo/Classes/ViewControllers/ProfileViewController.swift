//
//  ProfileViewController.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class ProfileViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var tblView_main: UITableView!
    
    var viewModel: ProfileViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.view.backgroundColor = Color.profileBackground.value
        
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                print("Open menu")
                break
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}
