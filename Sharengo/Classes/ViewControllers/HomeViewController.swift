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
import pop
import SideMenu

class HomeViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
    @IBOutlet fileprivate weak var btn_profile: UIButton!
    @IBOutlet fileprivate weak var view_profile: UIView!
    @IBOutlet fileprivate weak var btn_feeds: UIButton!
    @IBOutlet fileprivate weak var view_feeds: UIView!
    @IBOutlet fileprivate weak var view_dotted: UIView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
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
            case .feeds:
                let dialog = ZAlertView(title: nil, message: "alert_homeNotAvailable".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                    alertView.dismissAlertView()
                })
                dialog.allowTouchOutsideToDismiss = false
                dialog.show()
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_searchCar.rx.bind(to: viewModel.selection, input: .searchCars)
        self.btn_profile.rx.bind(to: viewModel.selection, input: .profile)
        self.btn_feeds.rx.bind(to: viewModel.selection, input: .feeds)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_searchCar.backgroundColor = Color.homeEnabledBackground.value
        self.view_searchCar.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_searchCar.layer.masksToBounds = true
        self.view_searchCar.alpha = 0.0
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        self.view_profile.backgroundColor = Color.homeEnabledBackground.value
        self.view_profile.layer.cornerRadius = self.view_profile.frame.size.width/2
        self.view_profile.layer.masksToBounds = true
        self.view_profile.alpha = 0.0
        self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        self.view_feeds.backgroundColor = Color.homeDisabledBackground.value
        self.view_feeds.layer.cornerRadius = self.view_feeds.frame.size.width/2
        self.view_feeds.layer.masksToBounds = true
        self.view_feeds.alpha = 0.0
        self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(Color.homeDisabledIcon.value), for: .normal)
        self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(Color.homeDisabledIcon.value.withAlphaComponent(0.5)), for: .highlighted)
        self.view_dotted.backgroundColor = UIColor.clear
        let strokeColor = UIColor.black.cgColor
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [2,2]
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: CGFloat(self.view_dotted.frame.size.width/2), y: CGFloat(self.view_dotted.frame.size.width/2)), radius: CGFloat(self.view_dotted.frame.size.width/2), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true).cgPath
        self.view_dotted.layer.addSublayer(shapeLayer)
        self.view.bringSubview(toFront: self.view_searchCar)
        self.view.bringSubview(toFront: self.view_profile)
        self.view.bringSubview(toFront: self.view_feeds)
        self.view_dotted.alpha = 0.0
        self.lbl_description.alpha = 0.0
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
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.loginIsShowed {
            self.loginIsShowed = true
            if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
                KeychainSwift().clear()
                let destination: LoginViewController = (Storyboard.main.scene(.login))
                destination.bind(to: ViewModelFactory.login(), afterLoad: true)
                self.navigationController?.pushViewController(destination, animated: false)
                self.introIsShowed = true
                self.animateButtons()
                return
            }
        }
        if !self.introIsShowed {
            let destination: IntroViewController  = (Storyboard.main.scene(.intro))
            destination.bind(to: ViewModelFactory.intro(), afterLoad: true)
            self.addChildViewController(destination)
            self.view.addSubview(destination.view)
            self.view.layoutIfNeeded()
            if UserDefaults.standard.bool(forKey: "LongIntro") == false {
                let dispatchTime = DispatchTime.now() + 7.5
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.animateButtons()
                }
            } else {
                let dispatchTime = DispatchTime.now() + 1.8
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    self.animateButtons()
                }
            }
        }
        self.introIsShowed = true
        self.updateData()
    }
    
    // MARK: - Update methods
    
    @objc fileprivate func updateData() {
        DispatchQueue.main.async {
            if let firstname = KeychainSwift().get("UserFirstname") {
                self.lbl_description.styledText = String(format: "lbl_homeDescriptionLogged".localized(), firstname)
            } else {
                self.lbl_description.styledText = "lbl_homeDescriptionNotLogged".localized()
            }
        }
    }
    
    // MARK: - Animation methods
    
    fileprivate func animateButtons() {
        let popAnimation1: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        popAnimation1.fromValue = 0
        popAnimation1.toValue = 1
        popAnimation1.duration = 0.5
        let popAnimation2: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        popAnimation2.fromValue = NSValue(cgSize: CGSize(width: 0.5, height: 0.5))
        popAnimation2.toValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        popAnimation2.duration = 0.5
        self.view_dotted.pop_add(popAnimation1, forKey: "popAnimation1")
        self.view_dotted.pop_add(popAnimation2, forKey: "popAnimation2")
        let dispatchTime = DispatchTime.now() + 0.75
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.view_searchCar.pop_add(popAnimation1, forKey: "popAnimation1")
            self.view_profile.pop_add(popAnimation1, forKey: "popAnimation1")
            self.view_feeds.pop_add(popAnimation1, forKey: "popAnimation1")
            self.lbl_description.pop_add(popAnimation1, forKey: "popAnimation1")
            self.view_searchCar.pop_add(popAnimation2, forKey: "popAnimation2")
            self.view_profile.pop_add(popAnimation2, forKey: "popAnimation2")
            self.view_feeds.pop_add(popAnimation2, forKey: "popAnimation2")
        }
    }
    
    // MARK: - Utilities methods
    
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
