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

import KeychainSwift
import pop
import SideMenu
import DeviceKit

/**
 The Home class is the main screen and user can use it to navigate through the application
 */
public class HomeViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var btn_searchCar: UIButton!
    @IBOutlet fileprivate weak var view_searchCar: UIView!
    @IBOutlet fileprivate weak var btn_profile: UIButton!
    @IBOutlet fileprivate weak var view_profile: UIView!
    @IBOutlet fileprivate weak var btn_feeds: UIButton!
    @IBOutlet fileprivate weak var view_feeds: UIView!
    @IBOutlet fileprivate weak var view_dotted: UIView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    /// Variable used to save if the login is already showed
    public var loginIsShowed: Bool = false
    /// Variable used to save if the intro is already showed
    public var introIsShowed: Bool = false
    /// Variable used to save if the tutorial is already showed
    public var tutorialIsShowed: Bool = false
    /// ViewModel variable used to represents the data
    public var viewModel: HomeViewModel?
    /// User can open profile eco status
    public var profileEcoStatusAvailable: Bool = false
    /// User can open feeds
    public var feedsAvailable: Bool = false
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? HomeViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                switch viewModel {
                case is MapViewModel:
                    self.openSection(viewModel: viewModel, homeItem: .searchCar)
                case is ProfileViewModel:
                    if self.profileEcoStatusAvailable {
                        self.openSection(viewModel: viewModel, homeItem: .profile)
                    } else {
                        let message = "alert_homeNotAvailable".localized()
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                case is LoginViewModel:
                    if self.profileEcoStatusAvailable {
                        self.openSection(viewModel: viewModel, homeItem: .profile)
                    } else {
                        let message = "alert_homeNotAvailable".localized()
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                default:
                    break
                }
            case .feeds:
                if self.feedsAvailable {
                    var cityid = "0"
                    if var dictionary = UserDefaults.standard.object(forKey: "cityDic") as? [String: String] {
                        if let username = KeychainSwift().get("Username") {
                            cityid = dictionary[username] ?? "0"
                        }
                    }
                    if cityid == "0" {
                        let settingsCitiesViewModel = ViewModelFactory.settingsCities()
                        (settingsCitiesViewModel as! SettingsCitiesViewModel).nextViewModel = ViewModelFactory.feeds()
                        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
                            self.openSection(viewModel: ViewModelFactory.login(nextViewModel: settingsCitiesViewModel), homeItem: .feeds)
                        } else {
                            self.openSection(viewModel: settingsCitiesViewModel, homeItem: .feeds)
                        }
                    } else {
                        self.openSection(viewModel: ViewModelFactory.feeds(), homeItem: .feeds)
                    }
                } else {
                    let message = "alert_homeNotAvailable".localized()
                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                }
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_searchCar.rx.tap.asObservable()
            .subscribe(onNext:{
        }).addDisposableTo(disposeBag)
        self.btn_searchCar.rx.bind(to: viewModel.selection, input: .searchCars)
        self.btn_profile.rx.bind(to: viewModel.selection, input: .profile)
        self.btn_feeds.rx.bind(to: viewModel.selection, input: .feeds)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_searchCar.backgroundColor = Color.homeEnabledBackground.value
        self.view_searchCar.layer.cornerRadius = self.view_searchCar.frame.size.width/2
        self.view_searchCar.layer.masksToBounds = true
        self.view_searchCar.alpha = 0.0
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_searchCar.setImage(self.btn_searchCar.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        if self.profileEcoStatusAvailable {
            self.view_profile.backgroundColor = Color.homeEnabledBackground.value
            self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white), for: .normal)
            self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        } else {
            self.view_profile.backgroundColor = Color.homeDisabledBackground.value
            self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9")), for: .normal)
            self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9").withAlphaComponent(0.5)), for: .highlighted)
        }
        self.view_profile.layer.cornerRadius = self.view_profile.frame.size.width/2
        self.view_profile.layer.masksToBounds = true
        self.view_profile.alpha = 0.0
        if self.feedsAvailable {
            self.view_feeds.backgroundColor = Color.homeEnabledBackground.value
            self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(UIColor.white), for: .normal)
            self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
        } else {
            self.view_feeds.backgroundColor = Color.homeDisabledBackground.value
            self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9")), for: .normal)
            self.btn_feeds.setImage(self.btn_feeds.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9").withAlphaComponent(0.5)), for: .highlighted)
        }
        self.view_feeds.layer.cornerRadius = self.view_feeds.frame.size.width/2
        self.view_feeds.layer.masksToBounds = true
        self.view_feeds.alpha = 0.0
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
                self?.present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updateUserData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view_searchCar.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        self.view_profile.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        self.view_feeds.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        self.view.layoutIfNeeded()
        if !self.loginIsShowed {
            self.loginIsShowed = true
            if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
                KeychainSwift().clear()
                let destination: OnBoardViewController = (Storyboard.main.scene(.onBoard))
                destination.bind(to: ViewModelFactory.onBoard(), afterLoad: true)
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
            let dispatchTime = DispatchTime.now() + 2.0
            DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                self.animateButtons()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    if !self.tutorialIsShowed {
                        self.tutorialIsShowed = true
                        if UserDefaults.standard.bool(forKey: "TutorialShowed") == false {
                            let destination: TutorialViewController = (Storyboard.main.scene(.tutorial))
                            let viewModel = ViewModelFactory.tutorial()
                            destination.bind(to: viewModel, afterLoad: true)
                            self.present(destination, animated: true, completion: nil)
                            UserDefaults.standard.set(true, forKey: "TutorialShowed")
                        }
                    }
                }
            }
        } else {
            self.view_searchCar.alpha = 1.0
            self.view_profile.alpha = 1.0
            self.view_feeds.alpha = 1.0
            self.view_dotted.alpha = 1.0
            self.lbl_description.alpha = 1.0
        }
        self.introIsShowed = true
        self.updateUserData()
    }
    
    // MARK: - Update methods
    
    /**
     This method is linked to a notification with name "updateData". When other methods calls this "updateData" the home updates its interface:
     - user's firstname in the bottom message
     - user's city showed in the feed button
     */
    @objc fileprivate func updateUserData() {
        DispatchQueue.main.async {
            if let firstname = KeychainSwift().get("UserFirstname") {
                self.lbl_description.styledText = String(format: "lbl_homeDescriptionLogged".localized(), firstname)
            } else {
                self.lbl_description.styledText = "lbl_homeDescriptionNotLogged".localized()
            }
            var cityid = "0"
            if var dictionary = UserDefaults.standard.object(forKey: "cityDic") as? [String: String] {
                if let username = KeychainSwift().get("Username") {
                    cityid = dictionary[username] ?? "0"
                }
            }
            var cityFounded: Bool = false
            let cities = CoreController.shared.cities
            for city in cities {
                if city.identifier == cityid {
                    if let url = URL(string: city.icon)
                    {
                        do {
                            let data = try Data(contentsOf: url)
                            if let image = UIImage(data: data) {
                                cityFounded = true
                                if self.feedsAvailable {
                                    self.btn_feeds.setImage(image.tinted(UIColor.white), for: .normal)
                                    self.btn_feeds.setImage(image.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
                                } else {
                                    self.btn_feeds.setImage(image.tinted(UIColor(hexString: "b6afa9")), for: .normal)
                                    self.btn_feeds.setImage(image.tinted(UIColor(hexString: "b6afa9").withAlphaComponent(0.5)), for: .highlighted)
                                }
                            }
                        } catch {
                        }
                    }
                }
            }
            if !cityFounded {
                if self.feedsAvailable {
                    self.btn_feeds.setImage(UIImage(named: "ic_imposta_citta_big")?.tinted(UIColor.white), for: .normal)
                    self.btn_feeds.setImage(UIImage(named: "ic_imposta_citta_big")?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
                } else {
                    self.btn_feeds.setImage(UIImage(named: "ic_imposta_citta_big")?.tinted(UIColor(hexString: "b6afa9")), for: .normal)
                    self.btn_feeds.setImage(UIImage(named: "ic_imposta_citta_big")?.tinted(UIColor(hexString: "b6afa9").withAlphaComponent(0.5)), for: .highlighted)
                }
            }
            if self.profileEcoStatusAvailable {
                self.view_profile.backgroundColor = Color.homeEnabledBackground.value
                self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white), for: .normal)
                self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor.white.withAlphaComponent(0.5)), for: .highlighted)
            } else {
                self.view_profile.backgroundColor = Color.homeDisabledBackground.value
                self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9")), for: .normal)
                self.btn_profile.setImage(self.btn_profile.image(for: .normal)?.tinted(UIColor(hexString: "b6afa9").withAlphaComponent(0.5)), for: .highlighted)
            }
        }
    }
    
    // MARK: - Animation methods
    
    /**
     This method executes dotted circle and buttons animation (scale and alpha)
     */
    public func animateButtons() {
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
    
    /**
     This method opens selected screen after button animation
     */
    public func openSection(viewModel: ViewModelType, homeItem: HomeItem) {
        let popAnimation2: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        popAnimation2.fromValue = NSValue(cgSize: CGSize(width: 1, height: 1))
        popAnimation2.toValue = NSValue(cgSize: CGSize(width: 0.5, height: 0.5))
        popAnimation2.duration = 0.5
        let popAnimation1: POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        popAnimation1.fromValue = 1
        popAnimation1.toValue = 0
        popAnimation1.duration = 0.5
        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { () -> Void in
                        switch homeItem {
                        case .searchCar:
                            self.view_searchCar?.center = self.view.center
                        case .profile:
                            self.view_profile?.center = self.view.center
                        case .feeds:
                            self.view_feeds?.center = self.view.center
                        }
        }, completion: { (finished) -> Void in
            switch homeItem {
            case .searchCar:
                self.view_searchCar.pop_add(popAnimation1, forKey: "popAnimation1")
                self.view_searchCar.pop_add(popAnimation2, forKey: "popAnimation2")
            case .profile:
                self.view_profile.pop_add(popAnimation1, forKey: "popAnimation1")
                self.view_profile.pop_add(popAnimation2, forKey: "popAnimation2")
            case .feeds:
                self.view_feeds.pop_add(popAnimation1, forKey: "popAnimation1")
                self.view_feeds.pop_add(popAnimation2, forKey: "popAnimation2")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                Router.from(self,viewModel: viewModel).execute()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.view_searchCar.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                self.view_profile.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                self.view_feeds.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                self.view.layoutIfNeeded()
            }
        })
    }
}
