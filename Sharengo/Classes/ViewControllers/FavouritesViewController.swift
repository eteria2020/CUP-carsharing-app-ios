//
//  FavouritesViewController.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit

class FavouritesViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var btn_newFavourite: UIButton!
    @IBOutlet fileprivate weak var view_title: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    var viewModel: FavouritesViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FavouritesViewModel else {
            return
        }
        
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .newFavourite:
                let destination: NewFavouriteViewController = (Storyboard.main.scene(.newFavourite))
                destination.bind(to: ViewModelFactory.newFavourite(), afterLoad: true)
                destination.fromFavourites = true
                self.navigationController?.pushViewController(destination, animated: true)
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        
        
        self.viewModel = viewModel
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.viewModel?.reload()
        self.btn_newFavourite.rx.bind(to: viewModel.selection, input: .newFavourite)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFavouritesBackground.value
        self.view_title.backgroundColor = Color.favouritesTitle.value
        
        self.btn_newFavourite.style(.squaredButton(Color.loginContinueAsNotLoggedButton.value), title: "btn_noFavouritesNewFavourite".localized())
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        default:
            break
        }
        
        self.lbl_headerTitle.styledText = "lbl_favouritesHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_favouritesTitle".localized()
        
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
        
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                Router.back(self)
            }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.updateData()
        self.viewModel?.reload()
        self.collectionView?.reloadData()
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
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height+self.view_title.frame.size.height))/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let favCell = cell as? FavouriteItemCollectionViewCell else {
            return
        }
        favCell.btn_action1.rx.tap.asObservable()
            .subscribe(onNext:{
                guard let itemViewModel = favCell.viewModel as? FavouriteItemViewModel else {
                    return
                }
                if itemViewModel.favourite {
                    print("PROPORRE MODIFICA")
                } else {
                    print("PROPORRE AGGIUNTA AI PREFERITI")
                }
            }).addDisposableTo(disposeBag)
        favCell.btn_action2.rx.tap.asObservable()
            .subscribe(onNext:{
                print("PROPORRE ELIMINAZIONE")
            }).addDisposableTo(disposeBag)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Color.settingEvenCellBackground.value
        } else {
            cell.backgroundColor = Color.settingOddCellBackground.value
        }
    }
}
