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

/**
 The Tutorial class shows tutorial to user
 */
public class TutorialViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var scrollView_main: UIScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var view_scrollViewContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var img_leftArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_previousStep: UIButton!
    @IBOutlet fileprivate weak var img_rightArrow: UIImageView!
    @IBOutlet fileprivate weak var btn_nextStep: UIButton!
    @IBOutlet fileprivate weak var img_close: UIImageView!
    @IBOutlet fileprivate weak var btn_close: UIButton!
    @IBOutlet fileprivate weak var constraint_close: NSLayoutConstraint!
    @IBOutlet fileprivate weak var constraint_buttons: NSLayoutConstraint!
    @IBOutlet fileprivate weak var constraint_width: NSLayoutConstraint!
    /// ViewModel variable used to represents the data
    public var viewModel: TutorialViewModel?
    fileprivate var stepX: CGFloat = 0.0
    fileprivate var currentStep: Int = 0
    fileprivate var pageWidth: CGFloat = 0

    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? TutorialViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        btn_previousStep.isHidden = true
        img_leftArrow.isHidden = true
        self.view.backgroundColor = Color.signupBackground.value
        switch Device().diagonal {
        case 3.5:
            self.constraint_close.constant = 50
            self.constraint_buttons.constant = -10
            self.pageWidth = 320
            self.constraint_width.constant = 25
        case 4:
            self.constraint_close.constant = 50
            self.constraint_buttons.constant = 120
            self.pageWidth = 320
            self.constraint_width.constant = 25
        case 4.7:
            self.constraint_close.constant = 60
            self.constraint_buttons.constant = 140
            self.pageWidth = 375
            self.constraint_width.constant = 30
        case 5.5:
            self.constraint_close.constant = 65
            self.constraint_buttons.constant = 155
            self.pageWidth = 414
            self.constraint_width.constant = 35
        default:
            break
        }
        self.view.layoutIfNeeded()
        // Steps
        if let steps = viewModel?.steps {
            for step in steps {
                let image = UIImage(named: step.image)
                let imageView = UIImageView(frame: CGRect(x: stepX, y: view_scrollViewContainer.frame.origin.y, width: pageWidth, height: view_scrollViewContainer.frame.height))
                imageView.image = image
                view_scrollViewContainer.addSubview(imageView)
                imageView.snp.makeConstraints { (make) -> Void in
                    make.width.equalTo(pageWidth)
                    make.left.equalTo(stepX)
                    make.top.equalTo(0)
                    make.bottom.equalTo(0)
                }
                stepX = stepX + pageWidth
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
                    self.dismiss(animated: true, completion: nil)
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }).addDisposableTo(self.disposeBag)
      
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
            frame.origin.x = (pageWidth * CGFloat(self.currentStep - 1))
            self.scrollView_main.scrollRectToVisible(frame, animated: true)
            
            self.currentStep = self.currentStep - 1
        }
    }
    
    fileprivate func nextStep()
    {
        if let viewModel = self.viewModel
        {
            if self.currentStep != viewModel.steps.count-1 {
                var frame = self.scrollView_main.frame
                frame.origin.x = (pageWidth * CGFloat(self.currentStep + 1))
                self.scrollView_main.scrollRectToVisible(frame, animated: true)
                self.currentStep = self.currentStep + 1
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - ScrollViewDelegate methods

extension TutorialViewController: UIScrollViewDelegate {
    /**
     With this method app show next or previous tutorial's step to user
     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
         if viewModel != nil {
            let page: Int = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth))
            self.currentStep = page + 1
            if self.currentStep == 0 {
                btn_previousStep.isHidden = true
                img_leftArrow.isHidden = true
            } else if self.currentStep == viewModel!.steps.count-1 {
                btn_previousStep.isHidden = false
                img_leftArrow.isHidden = false
            } else {
                btn_previousStep.isHidden = false
                img_leftArrow.isHidden = false
            }
        }
        if scrollView.contentOffset.x < 0 {
            scrollView.isScrollEnabled = false
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
            scrollView.isScrollEnabled = true
        } else if scrollView.contentOffset.x > pageWidth*CGFloat(viewModel!.steps.count-1) {
            scrollView.isScrollEnabled = false
            scrollView.contentOffset = CGPoint(x: pageWidth*CGFloat(viewModel!.steps.count-1), y: scrollView.contentOffset.y)
            scrollView.isScrollEnabled = true
        }
    }
}
