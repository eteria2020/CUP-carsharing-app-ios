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

class HomeViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
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
                self.openSearchCars(viewModel: viewModel)
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_searchCar.rx.bind(to: viewModel.selection, input: .searchCars)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_searchCar.backgroundColor = Color.homeSearchCarBackground.value
        self.view_searchCar.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_searchCar.layer.masksToBounds = true
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.loginIsShowed {
            if UserDefaults.standard.object(forKey: "UserPin") == nil || UserDefaults.standard.object(forKey: "Username") == nil || UserDefaults.standard.object(forKey: "Password") == nil {
                    if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
                        UserDefaults.standard.set(true, forKey: "LoginShowed")
                        let destination: LoginViewController = (Storyboard.main.scene(.login))
                        destination.bind(to: ViewModelFactory.login(), afterLoad: true)
                        self.navigationController?.pushViewController(destination, animated: false)
                }
            }
        }
        self.loginIsShowed = true
        // TODO: move in intro please
        self.setupUser()
        CoreController.shared.updateData()
    }
   
    fileprivate func setupUser() {
        self.apiController.getUser()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.dic_data {
                        UserDefaults.standard.set(data["pin"], forKey: "UserPin")
                    }
                default:
                    break
                }
            }.addDisposableTo(self.disposeBag)
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
