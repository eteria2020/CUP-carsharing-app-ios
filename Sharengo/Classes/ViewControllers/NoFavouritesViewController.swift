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
    @IBOutlet fileprivate weak var btn_back: UIButton!
    
    var viewModel: NoFavouritesViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NoFavouritesViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .newFavourite:
                Router.from(self,viewModel: ViewModelFactory.newFavourite()).execute()
            default: break
            }
        }).addDisposableTo(self.disposeBag)

        self.viewModel = viewModel
        
        self.btn_newFavourite.rx.bind(to: viewModel.selection, input: .newFavourite)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFavouritesBackground.value
        
        self.btn_newFavourite.style(.squaredButton(Color.loginContinueAsNotLoggedButton.value), title: "btn_noFavouritesNewFavourite".localized())
   
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
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
        
        self.lbl_headerTitle.styledText = "lbl_noFavouritesHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_noFavouritesTitle".localized()
        self.lbl_description.styledText = "lbl_noFavouritesDescription".localized()
       
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
