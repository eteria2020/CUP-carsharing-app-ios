//
//  RatesViewController.swift
//  Sharengo
//
//  Created by Dedecube on 29/08/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit
import KeychainSwift

/**
 The Rates class shows Share'ngo rates
 */
public class RatesViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_titleRates: UILabel!
    @IBOutlet fileprivate weak var lbl_rates: UILabel!
    @IBOutlet fileprivate weak var view_bonusContainer: UIView!
    @IBOutlet fileprivate weak var lbl_titleBonus: UILabel!
    @IBOutlet fileprivate weak var lbl_bonus: UILabel!
    @IBOutlet fileprivate weak var btn_signup: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: RatesViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? RatesViewModel else {
            return
        }
        self.viewModel = viewModel
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
        }).addDisposableTo(self.disposeBag)
        
        viewModel.ratesDescription.asObservable()
            .subscribe(onNext: {[weak self] (value) in
                DispatchQueue.main.async {
                    self?.lbl_rates.styledText = value
                }
            }).addDisposableTo(disposeBag)
        
        viewModel.bonusDescription.asObservable()
            .subscribe(onNext: {[weak self] (value) in
                DispatchQueue.main.async {
                    self?.lbl_bonus.styledText = value
                }
            }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view.backgroundColor = Color.ratesBackground.value
        self.view_header.backgroundColor = Color.ratesHeaderBackground.value
        self.view_bonusContainer.backgroundColor = Color.ratesBonusContainerBackground.value
        
        // Labels
        self.lbl_headerTitle.textColor = Color.ratesHeaderTitle.value
        self.lbl_headerTitle.styledText = "lbl_ratesHeader".localized().uppercased()
        
        // NavigationBar
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
        
        // Buttons
        self.btn_signup.style(.roundedButton(Color.supportCallBackgroundButton.value), title: "btn_ratesSignup".localized())
        self.btn_signup.rx.tap.asObservable()
            .subscribe(onNext:{
                let destination: SignupViewController = (Storyboard.main.scene(.signup))
                destination.bind(to: ViewModelFactory.signup(), afterLoad: true)
                self.navigationController?.pushViewController(destination, animated: true)
            }).addDisposableTo(disposeBag)
        
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
        default:
            break
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else {
            return
        }
        viewModel.updateValues()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.lbl_titleRates.styledText = "lbl_ratesNotLoggedRatesTitle".localized()
        } else {
            self.lbl_titleRates.styledText = "lbl_ratesLoggedRatesTitle".localized()
        }
        self.lbl_titleBonus.styledText = "lbl_ratesBonusTitle".localized().uppercased()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.view_bonusContainer.isHidden = true
            self.btn_signup.isHidden = false
        }
        else
        {
            self.view_bonusContainer.isHidden = false
            self.btn_signup.isHidden = true
        }
    }
}
