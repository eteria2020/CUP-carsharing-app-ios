//
//  HomeViewController.swift
//  Sharengo
//
//  Created by Dedecube on 23/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import KeychainSwift

class HomeViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
    @IBOutlet fileprivate weak var btn_profile: UIButton!
    @IBOutlet fileprivate weak var view_profile: UIView!
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var loginIsShowed: Bool = false
    
    var viewModel: HomeViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? HomeViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                if viewModel is SearchBarViewModel {
                    self.openSearchCars(viewModel: viewModel)
                } else {
                    Router.from(self,viewModel: viewModel).execute()
                }
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_searchCar.rx.bind(to: viewModel.selection, input: .searchCars)
        self.btn_profile.rx.bind(to: viewModel.selection, input: .profile)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_searchCar.backgroundColor = Color.homeSearchCarBackground.value
        self.view_searchCar.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_searchCar.layer.masksToBounds = true
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        self.view_profile.backgroundColor = Color.homeSearchCarBackground.value
        self.view_profile.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_profile.layer.masksToBounds = true
        self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.loginIsShowed {
            if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
                KeychainSwift().clear()
                let destination: LoginViewController = (Storyboard.main.scene(.login))
                destination.bind(to: ViewModelFactory.login(), afterLoad: true)
                self.navigationController?.pushViewController(destination, animated: false)
                UserDefaults.standard.set(true, forKey: "LoginShowed")
            }
        }
        self.loginIsShowed = true
        CoreController.shared.updateData()
    }
    
    fileprivate func openSearchCars(viewModel: ViewModelType) {
        if !CoreController.shared.updateInProgress {
            Router.from(self,viewModel: viewModel).execute()
        } else {
            let dispatchTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.openSearchCars(viewModel: viewModel)
            }
        }
    }
}
