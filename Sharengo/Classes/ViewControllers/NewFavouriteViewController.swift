//
//  NewFavouriteViewController.swift
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
import TPKeyboardAvoiding

class NewFavouriteViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var txt_address: AnimatedTextInput!
    @IBOutlet fileprivate weak var txt_name: AnimatedTextInput!
    @IBOutlet fileprivate weak var btn_saveFavourite: UIButton!
    @IBOutlet fileprivate weak var btn_undo: UIButton!
    @IBOutlet fileprivate weak var scrollView_main: TPKeyboardAvoidingScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    
    var viewModel: NewFavouriteViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NewFavouriteViewModel else {
            return
        }
        self.viewModel = viewModel
        
        /*
        self.btn_saveFavourite.rx.tap.asObservable()
            .subscribe(onNext:{
                // Save
            }).addDisposableTo(disposeBag)
        self.btn_undo.rx.tap.asObservable()
            .subscribe(onNext:{
                // Undo
            }).addDisposableTo(disposeBag)
        */
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.loginBackground.value
        
        /*
        self.btn_saveFavourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_newFavouriteSaveFavourite".localized())
        self.btn_undo.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_newFavouriteUndo".localized())
        */
        
        self.lbl_headerTitle.styledText = "lbl_newFavouriteHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_newFavouriteTitle".localized()
        self.lbl_description.styledText = "lbl_newFavouriteDescription".localized()
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        default:
            break
        }
        
        /*
        self.txt_address.placeHolderText = "txt_newFavouriteAddressPlaceholder".localized()
        self.txt_address.style = CustomTextInputStyle()
        
        self.txt_name.placeHolderText = "txt_newFavouriteNamePlaceholder".localized()
        self.txt_name.style = CustomTextInputStyle()
        */
        
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
