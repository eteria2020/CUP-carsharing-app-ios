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
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
    @IBOutlet fileprivate weak var btn_profile: UIButton!
    @IBOutlet fileprivate weak var view_profile: UIView!
    @IBOutlet fileprivate weak var view_dotted: UIView!
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var loginIsShowed: Bool = false
    fileprivate var introIsShowed: Bool = false
    
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
        // TODO: animazione su CAShapeLayer e view_searchCar/view_profile/...
        // TODO: in grigio le funzionalità non disponibili, in verde quelle disponibili
        // TODO: cambiare la città a seconda delle impostazioni dell'utente (abbiamo questo dato?)
        // TODO: aggiungere la label descrittiva
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
        self.view_dotted.backgroundColor = UIColor.clear
        let strokeColor = UIColor.black.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [2,2]
        shapeLayer.path = UIBezierPath(arcCenter: self.view_dotted.center, radius: CGFloat(self.view_dotted.frame.size.width/2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true).cgPath
        self.view.layer.addSublayer(shapeLayer)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*
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
        */
        if !self.introIsShowed {
            let destination: IntroViewController  = (Storyboard.main.scene(.intro))
            destination.bind(to: ViewModelFactory.intro(), afterLoad: true)
            self.addChildViewController(destination)
            self.view.addSubview(destination.view)
            self.view.layoutIfNeeded()
            // TODO: si può spostare questa logica in Intro?
            if UserDefaults.standard.bool(forKey: "LongIntro") == false {
                let dispatchTime = DispatchTime.now() + 7
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    UIView.animate(withDuration: 0.5, animations: {
                        destination.view.frame.origin.y = -UIScreen.main.bounds.size.height
                    })
                }
            } else {
                let dispatchTime = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    UIView.animate(withDuration: 0.5, animations: {
                        destination.view.frame.origin.y = -UIScreen.main.bounds.size.height
                    })
                }
            }
        }
        self.introIsShowed = true
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
