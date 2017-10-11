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
import DeviceKit
import Reachability

/**
 The Car Trips class shows to user its car trips
 */
public class CarTripsViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    fileprivate var allCarTrips: [CarTrip] = []
    fileprivate let apiController: ApiController = ApiController()
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    fileprivate var objectsLoaded: Bool = false
    
    public var viewModel: CarTripsViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? CarTripsViewModel else {
            return
        }

        self.viewModel = viewModel
        
        self.lbl_title.styledText = "lbl_carTripsHeaderTitle".localized()
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.viewModel?.reload()
      
        if CoreController.shared.archivedCarTrips.count > 0 {
            self.allCarTrips = CoreController.shared.archivedCarTrips
            self.viewModel?.updateData(carTrips: self.allCarTrips)
            self.viewModel?.reload()
            self.collectionView?.reloadData()
            self.objectsLoaded = true
            self.apiController.archivedTripsList()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.array_data {
                            if let carTrips = [CarTrip].from(jsonArray: data) {
                                
                                
                                
                                CoreController.shared.archivedCarTrips = carTrips
                                self.allCarTrips = carTrips
                                DispatchQueue.main.async {[weak self]  in
                                    if let carTrips = self?.allCarTrips {
                                        self?.viewModel?.updateData(carTrips: carTrips)
                                    }
                                    self?.viewModel?.reload()
                                    self?.collectionView?.reloadData()
                                }
                                return
                            }
                        }
                    case .error(_):
                        break
                    default:
                        break
                    }
                }.addDisposableTo(self.disposeBag)
        } else {
            let destination: NoCarTripsViewController = (Storyboard.main.scene(.noCarTrips))
            destination.bind(to: ViewModelFactory.noCarTrips(), afterLoad: true)
            var array = self.navigationController?.viewControllers ?? []
            let navigationController = self.navigationController!
            array.append(destination)
            self.navigationController?.viewControllers = array
            
            self.apiController.archivedTripsList()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.array_data {
                            if let carTrips = [CarTrip].from(jsonArray: data) {
                                CoreController.shared.archivedCarTrips = carTrips
                                self.allCarTrips = carTrips
                                DispatchQueue.main.async {[weak self]  in
                                    if CoreController.shared.currentViewController is NoCarTripsViewController {
                                        if let carTrips = self?.allCarTrips {
                                            self?.viewModel?.updateData(carTrips: carTrips)
                                        }
                                        self?.viewModel?.reload()
                                        self?.collectionView?.reloadData()
                                        self?.objectsLoaded = true
                                        array.removeLast()
                                        navigationController.viewControllers = array
                                    }
                                }
                                return
                            }
                        }
                    case .error(_):
                        break
                    default:
                        break
                    }
                }.addDisposableTo(self.disposeBag)
        }
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
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
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7, 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        //case 5.5:
        default:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        //default:
        //    break
        }
        
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
    }
    
    // MARK: - Collection methods
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (line spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (interitem spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (inset)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (size)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let model = self.viewModel?.model(atIndex: indexPath) as?  CarTrip else { return CGSize.zero }
        //let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        let width = collectionView.bounds.size.width
        if model.id == self.viewModel?.idSelected {
            switch Device().diagonal {
            case 3.5:
                return CGSize(width: width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/1.75)
            default:
                return CGSize(width: width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/1.8)
            }
        }
        return CGSize(width: width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/3)
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.objectsLoaded {
            self.viewModel?.selection.execute(.item(indexPath))
        }
    }
    
    /**
     This method is called from collection delegate before display a cell to change list interface
     */
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let carTripCell = cell as? CarTripItemCollectionViewCell {
            carTripCell.updateWithPlateSelected(idSelected: self.viewModel?.idSelected ?? -1)
        }
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
