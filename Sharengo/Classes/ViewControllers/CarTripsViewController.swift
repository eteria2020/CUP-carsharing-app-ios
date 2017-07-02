//
//  CarTripsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 30/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu

class CarTripsViewController : UIViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var viewModel: CarTripsViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarTripsViewModel else {
            return
        }

        self.viewModel = viewModel

        self.lbl_title.styledText = "lbl_carTripsHeaderTitle".localized()
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        
        self.viewModel?.reload()
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_header.backgroundColor = Color.carTripsHeaderBackground.value
        self.lbl_title.textColor = Color.carTripsHeaderLabel.value
        
        self.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .reload:
                self?.viewModel?.reload()
                self?.collectionView?.reloadData()
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
            
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
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
        guard let model = self.viewModel?.model(atIndex: indexPath) as?  CarTrip else { return CGSize.zero }
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        if model.selected {
            return CGSize(width: size.width, height: (UIScreen.main.bounds.height-106)/2)
        }
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-106)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0
        {
            cell.backgroundColor = Color.carTripsEvenCellBackground.value
        }
        else
        {
            cell.backgroundColor = Color.carTripsOddCellBackground.value
        }
    }
}
