//
//  NoFavouritesViewController.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

class NoFavouritesViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var btn_newFavourite: UIButton!

    var viewModel: NoFavouritesViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NoFavouritesViewModel else {
            return
        }
        self.viewModel = viewModel
        
        self.btn_newFavourite.rx.tap.asObservable()
            .subscribe(onNext:{
                // Open new favourite vc
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.loginBackground.value
        
        self.btn_newFavourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_settingsFavouritesNewFavourite".localized())
        
        self.lbl_headerTitle.styledText = "lbl_settingsFavouritesHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_settingsFavouritesTitle".localized()
        self.lbl_description.styledText = "lbl_settingsFavouritesDescription".localized()
        
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
