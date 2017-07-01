//
//  FavouritesViewController.swift
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

class FavouritesViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var btn_newFavourite: UIButton!
    @IBOutlet fileprivate weak var view_title: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    
    var viewModel: FavouritesViewController?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FavouritesViewController else {
            return
        }
        
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFavouritesBackground.value
        self.view_title.backgroundColor = Color.favouritesTitle.value
        
        self.btn_newFavourite.style(.squaredButton(Color.loginContinueAsNotLoggedButton.value), title: "btn_noFavouritesNewFavourite".localized())
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        default:
            break
        }
        
        self.lbl_headerTitle.styledText = "lbl_favouritesHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_favouritesTitle".localized()
        
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
        
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                Router.back(self)
            }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
