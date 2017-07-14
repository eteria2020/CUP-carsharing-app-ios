//
//  FeedDetailViewController.swift
//  Sharengo
//
//  Created by Dedecube on 14/07/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

class FeedDetailViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var view_containerBackgroundImage: UIView!
    @IBOutlet fileprivate weak var img_background: UIImageView!
    @IBOutlet fileprivate weak var view_containerClaim: UIView!
    @IBOutlet fileprivate weak var lbl_claim: UILabel!
    @IBOutlet fileprivate weak var view_bottomContainer: UIView!
    @IBOutlet fileprivate weak var lbl_bottom: UILabel!
    @IBOutlet fileprivate weak var img_icon: UIImageView!
    @IBOutlet fileprivate weak var view_icon: UIView!
    @IBOutlet fileprivate weak var btn_favourite: UIButton!

    var viewModel: FeedDetailViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FeedDetailViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Views
        self.view_header.backgroundColor = Color.settingsCitiesHeaderBackground.value
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
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
        
        // Buttons
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                Router.back(self)
            }).addDisposableTo(disposeBag)
        
        // Labels
        self.lbl_title.textColor = Color.settingsCitiesHeaderLabel.value
    }
}
