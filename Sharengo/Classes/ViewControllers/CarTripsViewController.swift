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

import SideMenu
import DeviceKit
//import ReachabilitySwift

class CarTripsViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
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
        
        self.showLoader()
        let dispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.apiController.archivedTripsList()
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let response):
                        if response.status == 200, let data = response.array_data {
                            // Usiamo "prefix" per limitare il numero di corse da visualizzare in cronologia.
                            if let carTrips = [CarTrip].from(jsonArray: data)?.prefix(100)
                            {
                                self.allCarTrips = Array(carTrips)
                                /*
                                self.apiController.getTrip(trip: carTrips[0])
                                    .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                                    .subscribe { event in
                                    switch event {
                                    case .next(let response):
                                        break
                                    case .error(_):
                                        break
                                    default:
                                        break
                                    }
                                }.addDisposableTo(self.disposeBag)
                                */
                                DispatchQueue.main.async {
                                    self.viewModel?.updateData(carTrips: self.allCarTrips)
                                    self.viewModel?.reload()
                                    self.collectionView?.reloadData()
                                    self.hideLoader(completionClosure: { () in
                                    })
                                    let dispatchTime = DispatchTime.now() + 1
                                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                        self.objectsLoaded = true
                                    }
                                }
                                return
                            }
                        }
                        DispatchQueue.main.async {
                            let destination: NoCarTripsViewController = (Storyboard.main.scene(.noCarTrips))
                            destination.bind(to: ViewModelFactory.noCarTrips(), afterLoad: true)
                            var array = self.navigationController?.viewControllers ?? []
                            array.removeLast()
                            array.append(destination)
                            self.navigationController?.viewControllers = array
                            self.hideLoader(completionClosure: { () in
                            })
                            self.allCarTrips = []
                        }
                    case .error(_):
                        self.hideLoader(completionClosure: { () in
                            var message = "alert_generalError".localized()
                            if Reachability()?.isReachable == false {
                                message = "alert_connectionError".localized()
                            }
                            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                                Router.back(self)
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                            
                        })
                        self.allCarTrips = []
                    default:
                        break
                    }
                }.addDisposableTo(self.disposeBag)
        }
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
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 34
        default:
             self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
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
            switch Device().diagonal {
            case 3.5:
                return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/1.75)
            default:
                return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/1.8)
            }
        }
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.objectsLoaded {
            self.viewModel?.selection.execute(.item(indexPath))
        }
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
