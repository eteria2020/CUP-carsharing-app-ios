//
//  SearchCarsViewController.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action
import MapKit

class SearchCarsViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView! // TODO: ???
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    fileprivate let searchBarViewController:SearchBarViewController = (Storyboard.main.scene(.searchBar))
    
    var viewModel: SearchCarsViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchCarsViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            }
        }).addDisposableTo(self.disposeBag)
        viewModel.reload()
    }
   
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NavigationBar
        view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // CircularMenu
        view_circularMenu.bind(to: ViewModelFactory.circularMenu(type: .searchCars))
        view_circularMenu.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .refresh:
                self?.updateData()
            case .center:
                self?.centerMap()
            case .compass:
                self?.turnMap()
            default:break
            }
        }).addDisposableTo(self.disposeBag)
        // TODO: ???
        view_circularMenu.isUserInteractionEnabled = false
        // SearchBar
        self.view.addSubview(searchBarViewController.view)
        self.addChildViewController(searchBarViewController)
        searchBarViewController.didMove(toParentViewController: self)
        // TODO: ???
        searchBarViewController.view.isUserInteractionEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapButtons(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        self.setupMap()
    }
    
    func setupMap() {
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        mapView.add(overlay, level: .aboveLabels)
    }
    
    // MARK: - Gesture methods
    
    // TODO: ???
    func tapButtons(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.ended) {
            var point = sender.location(in: searchBarViewController.view_microphone)
            if searchBarViewController.btn_microphone.frame.contains(point) {
                searchBarViewController.startDictated()
                return
            }
            point = sender.location(in: searchBarViewController.view_search)
            if searchBarViewController.txt_search.frame.contains(point) {
                searchBarViewController.startSearching()
                return
            }
            point = sender.location(in: view_circularMenu)
            let arrayOfButtons = view_circularMenu.array_buttons
            if let arrayOfItems = view_circularMenu.viewModel?.type.getItems() {
                for i in 0..<arrayOfButtons.count {
                    if arrayOfItems.count > i {
                        let menuItem = arrayOfItems[i]
                        let button = arrayOfButtons[i]
                        if button.frame.contains(point) {
                            switch menuItem.input {
                            case .refresh:
                                self.updateData()
                            case .center:
                                self.centerMap()
                            case .compass:
                                self.turnMap()
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Data methods
    
    fileprivate func updateData() {
        print("Update Data")
    }

    // MARK: - Map methods
    
    fileprivate func centerMap() {
        print("Center Map")
    }
    
    fileprivate func turnMap() {
        print("Turn Map")
    }
}

// TODO: ???
extension SearchCarsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: view_navigationBar)
        if view_navigationBar.frame.contains(point) {
            return false
        }
        return true
    }
}

// TODO: ???
extension SearchCarsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer()
        }
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    }
}
