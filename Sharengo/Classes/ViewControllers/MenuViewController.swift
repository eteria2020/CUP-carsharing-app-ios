//
//  MenuViewController.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import KeychainSwift
import SideMenu

class MenuViewController : UIViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_welcome: UILabel!
    @IBOutlet fileprivate weak var view_userIcon: UIView!
    @IBOutlet fileprivate weak var img_userIcon: UIImageView!
    @IBOutlet fileprivate weak var view_separator: UIView!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var btn_profileEco: UIButton!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    var viewModel: MenuViewModel?

    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MenuViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            case .logout:
                KeychainSwift().clear()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
                let dispatchTime = DispatchTime.now() + 0.3
                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                    Router.exit(CoreController.shared.currentViewController ?? self)
                    self.updateData()
                }
            default: break
            }
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.view_userIcon.backgroundColor = UIColor.clear
        self.view_userIcon.layer.cornerRadius = self.view_userIcon.frame.size.width/2
        self.view_userIcon.layer.masksToBounds = true
        self.view_userIcon.layer.borderWidth = 1
        self.view_userIcon.layer.borderColor = Color.menuProfile.value.cgColor
        self.btn_profileEco.rx.bind(to: viewModel.selection, input: .profileEco)
        self.updateData()
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.updateData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.menuBackBackground.value
        view_header.backgroundColor = Color.menuTopBackground.value
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Update methods
    
    @objc fileprivate func updateData() {
        DispatchQueue.main.async {
            self.viewModel?.updateData()
            self.viewModel?.reload()
            self.collectionView?.reloadData()
            self.view.layoutIfNeeded()
            self.lbl_welcome.styledText = self.viewModel?.welcome
            self.view_userIcon.isHidden = self.viewModel?.userIconIsHidden ?? true
            self.img_userIcon.isHidden = self.viewModel?.userIconIsHidden ?? true
            self.btn_profileEco.isHidden = self.viewModel?.userIconIsHidden ?? true
        }
    }
    
    // MARK: - Collection methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-56)/9)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
}