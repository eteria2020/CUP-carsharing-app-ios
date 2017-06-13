//
//  SignupViewController.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import DeviceKit
import SnapKit

class SignupViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_topView: UIView!
    @IBOutlet fileprivate weak var lbl_header: UILabel!
    @IBOutlet fileprivate weak var scrollView_main: UIScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var view_scrollViewContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var img_leftArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_previousStep: UIButton!
    @IBOutlet fileprivate weak var img_rightArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_nextStep: UIButton!
    @IBOutlet fileprivate weak var pgc_steps: UIPageControl!
    @IBOutlet fileprivate weak var view_bottomView: UIView!
    @IBOutlet fileprivate weak var btn_signup: UIButton!

    var viewModel: SignupViewModel?
    fileprivate var stepX: CGFloat = 0.0

    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SignupViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        if let stepsArray = viewModel?.stepsArray
        {
            for step in stepsArray
            {
                step.frame.origin.x = stepX
                step.frame.origin.y = 0
                view_scrollViewContainer.addSubview(step)
                
                step.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(UIScreen.main.bounds.width)
                    make.left.equalTo(stepX)
                    make.top.equalTo(0)
                    make.bottom.equalTo(0)
                }
                
                stepX = stepX + UIScreen.main.bounds.width
            }
            
            scrollView_main.contentSize = CGSize(width: scrollView_main.frame.width * CGFloat(stepsArray.count), height: scrollView_main.frame.height)
            view_scrollViewContainerWidthConstraint.constant = scrollView_main.contentSize.width
            pgc_steps.numberOfPages = stepsArray.count
            
            self.view.layoutIfNeeded()
        }

        
        self.view.backgroundColor = Color.signupBackground.value
        
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

        // Labels
        self.lbl_header.styledText = "lbl_signupHeader".localized()

        // Buttons
        switch Device().diagonal {
        case 3.5:
            self.btn_signup.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 30
        case 4:
            self.btn_signup.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        default:
            self.btn_signup.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 35
        }
        self.btn_previousStep.rx.tap.subscribe(onNext:{[weak self] output in
            if self != nil
            {
                if self!.pgc_steps.currentPage != 0
                {
                    var frame = self!.scrollView_main.frame
                    frame.origin.x = (frame.size.width * CGFloat(self!.pgc_steps.currentPage - 1))
                    self!.scrollView_main.scrollRectToVisible(frame, animated: true)

                    self!.pgc_steps.currentPage = self!.pgc_steps.currentPage - 1
                }
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_nextStep.rx.tap.subscribe(onNext:{[weak self] output in
            if self != nil
            {
                if self!.pgc_steps.currentPage != self!.viewModel?.stepsArray.count
                {
                    var frame = self!.scrollView_main.frame
                    frame.origin.x = (frame.size.width * CGFloat(self!.pgc_steps.currentPage + 1))
                    self!.scrollView_main.scrollRectToVisible(frame, animated: true)
                
                    self!.pgc_steps.currentPage = self!.pgc_steps.currentPage + 1
                }
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_previousStep.isHidden = true
        self.img_leftArrow.isHidden = true

        self.btn_signup.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_signupSignup".localized())
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .signup:
                print("Signup")
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}

// MARK: - ScrollViewDelegate methods

extension SignupViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if viewModel != nil
        {
            let pageWidth: CGFloat = scrollView.frame.size.width
            let page: Int = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
            self.pgc_steps.currentPage = page + 1
            
            if self.pgc_steps.currentPage == 0
            {
                btn_previousStep.isHidden = true
                img_leftArrow.isHidden = true
                btn_nextStep.isHidden = false
                img_rightArrow.isHidden = false
            }
            else if self.pgc_steps.currentPage == viewModel!.stepsArray.count-1
            {
                btn_previousStep.isHidden = false
                img_leftArrow.isHidden = false
                btn_nextStep.isHidden = true
                img_rightArrow.isHidden = true
            }
            else
            {
                btn_previousStep.isHidden = false
                img_leftArrow.isHidden = false
                btn_nextStep.isHidden = false
                img_rightArrow.isHidden = false
            }
        }
    }
}
