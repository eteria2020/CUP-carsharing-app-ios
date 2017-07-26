//
//  TutorialViewController.swift
//  Sharengo
//
//  Created by Dedecube on 26/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import DeviceKit
import SnapKit
import BonMot

class TutorialViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var scrollView_main: UIScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var view_scrollViewContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var img_leftArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_previousStep: UIButton!
    @IBOutlet fileprivate weak var img_rightArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_nextStep: UIButton!
    @IBOutlet fileprivate weak var img_close: UIImageView!
    @IBOutlet fileprivate weak var btn_close: UIButton!
    
    var viewModel: TutorialViewModel?
    fileprivate var stepX: CGFloat = 0.0
    fileprivate var currentStep = 0

    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? TutorialViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.signupBackground.value

        // Steps
        if let steps = viewModel?.steps {
            for step in steps {
                let image = UIImage(named: step.image)
                let imageView = UIImageView(frame: CGRect(x: stepX, y: view_scrollViewContainer.frame.origin.y, width: view_scrollViewContainer.frame.width, height: view_scrollViewContainer.frame.height))
                imageView.image = image
                view_scrollViewContainer.addSubview(imageView)
                imageView.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(view_scrollViewContainer.frame.width)
                    make.left.equalTo(stepX)
                    make.top.equalTo(0)
                    make.bottom.equalTo(0)
                }
                stepX = stepX + view_scrollViewContainer.frame.width
            }
            scrollView_main.contentSize = CGSize(width: scrollView_main.frame.width * CGFloat(steps.count), height: scrollView_main.frame.height)
            view_scrollViewContainerWidthConstraint.constant = scrollView_main.contentSize.width
            self.view.layoutIfNeeded()
        }

        // Buttons
        self.btn_previousStep.rx.tap.subscribe(onNext:{[weak self] output in
            self?.previousStep()
        }).addDisposableTo(self.disposeBag)
        self.btn_nextStep.rx.tap.subscribe(onNext:{[weak self] output in
            self?.nextStep()
        }).addDisposableTo(self.disposeBag)
        self.btn_close.rx.tap.subscribe(onNext:{output in
            let dialog = ZAlertView(title: nil, message: "alert_closeTutorial".localized(), isOkButtonLeft: false, okButtonText: "btn_tutorialAlertStay".localized(), cancelButtonText: "btn_tutorialAlertClose".localized(),
                okButtonHandler: { alertView in
                    alertView.dismissAlertView()
            },
                cancelButtonHandler: { alertView in
                    alertView.dismissAlertView()
                    Router.back(self)
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }).addDisposableTo(self.disposeBag)
        self.btn_previousStep.isUserInteractionEnabled = false

        // Gesture recognizers
        self.view.rx.swipeGesture(.left).when(.recognized).subscribe(onNext: {_ in
            self.nextStep()
        }).addDisposableTo(self.disposeBag)
        self.view.rx.swipeGesture(.right).when(.recognized).subscribe(onNext: {_ in
            self.previousStep()
        }).addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Other methods
    
    fileprivate func previousStep()
    {
        if self.currentStep != 0 {
            var frame = self.scrollView_main.frame
            frame.origin.x = (frame.size.width * CGFloat(self.currentStep - 1))
            self.scrollView_main.scrollRectToVisible(frame, animated: true)
            
            self.currentStep = self.currentStep - 1
        }
    }
    
    fileprivate func nextStep()
    {
        if let viewModel = self.viewModel
        {
            if self.currentStep != viewModel.steps.count {
                var frame = self.scrollView_main.frame
                frame.origin.x = (frame.size.width * CGFloat(self.currentStep + 1))
                self.scrollView_main.scrollRectToVisible(frame, animated: true)
                
                self.currentStep = self.currentStep + 1
            }
        }
    }
}

// MARK: - ScrollViewDelegate methods

extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel != nil {
            let pageWidth: CGFloat = scrollView.frame.size.width
            let page: Int = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
            self.currentStep = page + 1
            if self.currentStep == 0 {
                btn_previousStep.isUserInteractionEnabled = false
                btn_nextStep.isUserInteractionEnabled = true
            } else if self.currentStep == viewModel!.steps.count-1 {
                btn_previousStep.isUserInteractionEnabled = true
                btn_nextStep.isUserInteractionEnabled = false
            } else {
                btn_previousStep.isUserInteractionEnabled = true
                btn_nextStep.isUserInteractionEnabled = true
            }
        }
    }
}
