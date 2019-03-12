//
//  PinViewController.swift
//  Sharengo
//
//  Created by sharengo on 18/12/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SideMenu
import DeviceKit
import KeychainSwift

class PinViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_titlePin: UILabel!
    @IBOutlet fileprivate weak var lbl_Pin: UILabel!
    @IBOutlet fileprivate weak var view_pinContainer: UIView!

    //@IBOutlet fileprivate weak var lbl_titleBonus: UILabel!
    //@IBOutlet fileprivate weak var lbl_bonus: UILabel!
    //@IBOutlet fileprivate weak var btn_signup: UIButton!
    
    var viewModel: PinViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? PinViewModel else {
            return
        }
        self.viewModel = viewModel
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
        }).addDisposableTo(self.disposeBag)
        
        viewModel.PinDescription.asObservable()
            .subscribe(onNext: {[weak self] (value) in
                DispatchQueue.main.async {
                    self?.lbl_Pin.styledText = value
                    self?.lbl_Pin.textColor = Color.pinPinDescription.value
                    self?.lbl_Pin.font = self?.lbl_Pin.font.withSize(25)
                }
            }).addDisposableTo(disposeBag)
        
        
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view.backgroundColor = Color.pinBackground.value
        self.view_header.backgroundColor = Color.pinHeaderBackground.value
        self.view_pinContainer.backgroundColor = Color.pinDescriptionContainerBackground.value
    
        
      
        // Labels
        self.lbl_headerTitle.textColor = Color.pinHeaderTitle.value
        self.lbl_headerTitle.styledText = "lbl_pinHeader".localized().uppercased()
        self.lbl_Pin.textColor = Color.pinPinDescription.value
        
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        
                // Other
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 34
        default:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else {
            return
        }
        viewModel.updateValues()
        
        self.lbl_titlePin.styledText = "lbl_pinPinTitle".localized()
        
    }
}
