//
//  OnBoardViewController.swift
//  Sharengo
//
//  Created by Dedecube on 06/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Boomerang
import Gifu
import SideMenu
import DeviceKit
import BonMot

class OnBoardViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var img_background: GIFImageView!
    @IBOutlet fileprivate weak var img_step: GIFImageView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var btn_skip: UIButton!
    @IBOutlet fileprivate weak var pgc_steps: UIPageControl!
    @IBOutlet fileprivate weak var view_white: UIView!
    
    var viewModel: OnBoardViewModel?
    fileprivate var introIsShowed: Bool = false
    fileprivate var gestureInProgress: Bool = false
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? OnBoardViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        switch Device().diagonal {
        case 3.5:
            self.view.constraint(withIdentifier: "constraint1", searchInSubviews: true)?.constant = 0
            self.view.constraint(withIdentifier: "constraint2", searchInSubviews: true)?.constant = 0
            self.view.constraint(withIdentifier: "constraint3", searchInSubviews: true)?.constant = 0
            self.view.constraint(withIdentifier: "constraint4", searchInSubviews: true)?.constant = 0
            self.view.constraint(withIdentifier: "bottomLblDescription", searchInSubviews: true)?.constant = 5
            self.view.constraint(withIdentifier: "bottomPgcSteps", searchInSubviews: true)?.constant = 25
            self.view.constraint(withIdentifier: "bottomBtnSkip", searchInSubviews: true)?.constant = 5
            self.lbl_description.bonMotStyle = StringStyle(.font(FontWeight.bold.font(withSize: 13)), .color(Color.onBoardDescription.value), .alignment(.center))
        default:
            break
        }

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

        // Labels
        self.lbl_description.alpha = 0.0
        self.view_white.alpha = 0.0
        
        // PageControl
        self.pgc_steps.currentPage = 0
        self.pgc_steps.numberOfPages = 3
        self.pgc_steps.pageIndicatorTintColor = Color.onBoardPageControlEmpty.value
        self.pgc_steps.currentPageIndicatorTintColor = Color.onBoardPageControlFilled.value
        
        // Buttons
        self.btn_skip.rx.tap.asObservable()
            .subscribe(onNext:{
                let destination: LoginViewController = (Storyboard.main.scene(.login))
                destination.bind(to: ViewModelFactory.login(), afterLoad: true)
                destination.introIsShowed = true
                self.navigationController?.pushViewController(destination, animated: true)
            }).addDisposableTo(disposeBag)
        
        // Images
        self.img_background.animate(withGIFNamed: "ONBOARD_sfondo_loop.gif", loopCount: 0)
        
        let dispatchTime = DispatchTime.now() + 9.0
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.img_step.animate(withGIFNamed: "Auto-A-ingresso.gif", loopCount: 1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.26) {
                self.img_step.animate(withGIFNamed: "Auto-A-loop.gif", loopCount: 1)
                self.lbl_description.styledText = "lbl_onBoardStep1Description".localized()
                UIView.animate(withDuration: 0.3, animations: { 
                    self.lbl_description.alpha = 1.0
                })
                
                // Gesture recognizers
                self.view.rx.swipeGesture(.left).when(.recognized).subscribe(onNext: {_ in
                    if !self.gestureInProgress {
                        switch self.pgc_steps.currentPage {
                        case 0:
                            self.gestureInProgress = true
                            self.pgc_steps.currentPage = 1
                            UIView.animate(withDuration: 0.3, animations: {
                                self.lbl_description.alpha = 0.0
                            })
                            self.img_step.animate(withGIFNamed: "Auto-A-uscita.gif", loopCount: 1)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.66) {
                                self.img_step.animate(withGIFNamed: "Auto-B-ingresso.gif", loopCount: 1)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.9) {
                                    self.gestureInProgress = false
                                    self.img_step.animate(withGIFNamed: "Auto-B-loop.gif", loopCount: 1)
                                    self.lbl_description.styledText = "lbl_onBoardStep2Description".localized()
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.lbl_description.alpha = 1.0
                                    })
                                }
                            }
                        case 1:
                            self.gestureInProgress = true
                            self.pgc_steps.currentPage = 2
                            UIView.animate(withDuration: 0.3, animations: {
                                self.lbl_description.alpha = 0.0
                            })
                            self.img_step.animate(withGIFNamed: "Auto-B-uscita.gif", loopCount: 1)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.72) {
                                self.img_step.animate(withGIFNamed: "Auto-C-ingresso.gif", loopCount: 1)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.05) {
                                    self.gestureInProgress = false
                                    self.img_step.animate(withGIFNamed: "Auto-C-loop.gif", loopCount: 1)
                                    self.lbl_description.styledText = "lbl_onBoardStep3Description".localized()
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.lbl_description.alpha = 1.0
                                    })
                                }
                            }
                        case 2:
                            self.gestureInProgress = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                UIView.animate(withDuration: 0.5, animations: {
                                    self.view_white.alpha = 1.0
                                })
                            }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                let destination: LoginViewController = (Storyboard.main.scene(.login))
                                destination.bind(to: ViewModelFactory.login(), afterLoad: true)
                                destination.introIsShowed = true
                                self.navigationController?.pushViewController(destination, animated: false)
                            }
                        default:
                            break
                        }
                    }
                }).addDisposableTo(self.disposeBag)
                
                self.view.rx.swipeGesture(.right).when(.recognized).subscribe(onNext: {_ in
                    if !self.gestureInProgress {
                        switch self.pgc_steps.currentPage {
                        case 1:
                            self.gestureInProgress = true
                            self.pgc_steps.currentPage = 0
                            UIView.animate(withDuration: 0.3, animations: {
                                self.lbl_description.alpha = 0.0
                            })
                            self.img_step.animate(withGIFNamed: "Auto-B-uscita.gif", loopCount: 1)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.72) {
                                self.img_step.animate(withGIFNamed: "Auto-A-ingresso.gif", loopCount: 1)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.26) {
                                    self.gestureInProgress = false
                                    self.img_step.animate(withGIFNamed: "Auto-A-loop.gif", loopCount: 1)
                                    self.lbl_description.styledText = "lbl_onBoardStep1Description".localized()
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.lbl_description.alpha = 1.0
                                    })
                                }
                            }
                        case 2:
                            self.gestureInProgress = true
                            self.pgc_steps.currentPage = 1
                            UIView.animate(withDuration: 0.3, animations: {
                                self.lbl_description.alpha = 0.0
                            })
                            self.img_step.animate(withGIFNamed: "Auto-C-uscita.gif", loopCount: 1)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
                                self.img_step.animate(withGIFNamed: "Auto-B-ingresso.gif", loopCount: 1)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.9) {
                                    self.gestureInProgress = false
                                    self.img_step.animate(withGIFNamed: "Auto-B-loop.gif", loopCount: 1)
                                    self.lbl_description.styledText = "lbl_onBoardStep2Description".localized()
                                    UIView.animate(withDuration: 0.3, animations: {
                                        self.lbl_description.alpha = 1.0
                                    })
                                }
                            }
                        default:
                            break
                        }
                    }
                }).addDisposableTo(self.disposeBag)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: "LoginShowed") == false {
            UserDefaults.standard.set(true, forKey: "LoginShowed")
            if !self.introIsShowed {
                let destination: IntroViewController  = (Storyboard.main.scene(.intro))
                destination.bind(to: ViewModelFactory.intro(), afterLoad: true)
                self.addChildViewController(destination)
                self.view.addSubview(destination.view)
                self.view.layoutIfNeeded()
            }
            self.introIsShowed = true
        }
    }
}
