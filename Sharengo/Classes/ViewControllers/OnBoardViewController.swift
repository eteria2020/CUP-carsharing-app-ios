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
import Boomerang
import Gifu
import SideMenu

class OnBoardViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var img_background: GIFImageView!
    @IBOutlet fileprivate weak var img_step: GIFImageView!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var btn_skip: UIButton!
    @IBOutlet fileprivate weak var pgc_steps: UIPageControl!

    var viewModel: OnBoardViewModel?
    
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
        self.lbl_description.styledText = "lbl_introTitle1".localized()
        
        // Images
        self.img_background.animate(withGIFNamed: "ONBOARD_sfondo_loop.gif", loopCount: 0)
        self.img_step.animate(withGIFNamed: "Auto-A-ingresso.gif", loopCount: 1)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.26) {
            self.img_step.animate(withGIFNamed: "Auto-A-loop.gif", loopCount: 1)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.11) {
                self.img_step.animate(withGIFNamed: "Auto-A-uscita.gif", loopCount: 1)
            }
        }
        
        // PageControl
        self.pgc_steps.numberOfPages = 3
        self.pgc_steps.pageIndicatorTintColor = Color.onBoardPageControlEmpty.value
        self.pgc_steps.currentPageIndicatorTintColor = Color.onBoardPageControlFilled.value
        
        // Gesture recognizer
        self.view.rx.tapGesture().when(.recognized).subscribe(onNext: {_ in
            //react to taps
        }).addDisposableTo(self.disposeBag)
    }
}
