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
    // TODO: ???
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    fileprivate let searchBarViewController:SearchBarViewController = (Storyboard.main.scene(.searchBar))
    fileprivate var checkedUserPosition:Bool = false
    fileprivate var resultsTask: DispatchWorkItem?
    
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
        viewModel.array_annotationsToAdd.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    self?.mapView.addAnnotations(array)
                    self?.setUpdateButtonAnimated(false)
                }
            }).addDisposableTo(disposeBag)
        viewModel.array_annotationsToRemove.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    self?.mapView.removeAnnotations(array)
                    self?.setUpdateButtonAnimated(false)
                }
            }).addDisposableTo(disposeBag)
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
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // CircularMenu
        self.view_circularMenu.bind(to: ViewModelFactory.circularMenu(type: .searchCars))
        self.view_circularMenu.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
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
        self.view_circularMenu.isUserInteractionEnabled = false
        // SearchBar
        self.view.addSubview(searchBarViewController.view)
        self.addChildViewController(searchBarViewController)
        self.searchBarViewController.didMove(toParentViewController: self)
        // TODO: ???
        self.searchBarViewController.view.isUserInteractionEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapButtons(_:)))
        tapGesture.delegate = self
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        // Map
        self.setupMap()
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.didAuthorized) { [weak self] _ in
            let locationController = LocationController.shared
            if locationController.isAuthorized, let userLocation = locationController.currentLocation {
                self?.mapView?.showsUserLocation = true
                self?.setUserPositionButtonVisible(true)
                self?.centerMap(on: userLocation)
            }
        }
        NotificationCenter.default.addObserver(forName:
        NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            let locationController = LocationController.shared
            if locationController.isAuthorized && locationController.currentLocation != nil {
                self.mapView?.showsUserLocation = true
                self.setUserPositionButtonVisible(true)
            } else {
                self.mapView?.showsUserLocation = false
                self.setUserPositionButtonVisible(false)
            }
            self.getResults()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.checkedUserPosition {
            self.checkUserPosition()
        }
    }
    
    func setupMap() {
        self.mapView.showsUserLocation = false
        self.setUserPositionButtonVisible(false)
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        self.mapView.add(overlay, level: .aboveLabels)
    }
    
    // MARK: - CircularMenu methods
    
    fileprivate func setUserPositionButtonVisible(_ visible: Bool) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .center {
                        if visible {
                            button.isUserInteractionEnabled = true
                            button.isEnabled = true
                        } else {
                            button.isUserInteractionEnabled = false
                            button.isEnabled = false
                        }
                        return
                    }
                }
            }
        }
    }
    
    fileprivate func setUpdateButtonAnimated(_ animated: Bool) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .refresh {
                        if animated {
                            button.startZRotation()
                        } else {
                            button.stopZRotation()
                        }
                        return
                    }
                }
            }
        }
    }
    
    fileprivate func setTurnButtonDegrees(_ degrees: CGFloat) {
        let arrayOfButtons = self.view_circularMenu.array_buttons
        if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
            for i in 0..<arrayOfButtons.count {
                if arrayOfItems.count > i {
                    let menuItem = arrayOfItems[i]
                    let button = arrayOfButtons[i]
                    if menuItem.input == .compass {
                        UIView.animate(withDuration: 0.2, animations: { 
                            button.transform = CGAffineTransform(rotationAngle: degrees.degreesToRadians)
                        })
                        return
                    }
                }
            }
        }
    }
    
    // MARK: - Gesture methods
    
    // TODO: ???
    func tapButtons(_ sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.ended) {
            var point = sender.location(in: self.searchBarViewController.view_microphone)
            if self.searchBarViewController.btn_microphone.frame.contains(point) {
                self.searchBarViewController.startDictated()
                return
            }
            point = sender.location(in: searchBarViewController.view_search)
            if self.searchBarViewController.txt_search.frame.contains(point) {
                self.searchBarViewController.startSearching()
                return
            }
            point = sender.location(in: self.view_circularMenu)
            let arrayOfButtons = self.view_circularMenu.array_buttons
            if let arrayOfItems = self.view_circularMenu.viewModel?.type.getItems() {
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
        self.getResults()
    }
    
    fileprivate func stopRequest() {
        // TODO: ???
        self.resultsTask?.cancel()
        self.setUpdateButtonAnimated(false)
        self.viewModel?.stopRequest()
    }
    
    fileprivate func getResults() {
        self.stopRequest()
        if let radius = self.getRadius() {
            if let mapView = self.mapView {
                self.setUpdateButtonAnimated(true)
                self.viewModel?.reloadResults(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: radius)
                return
            }
        }
        self.viewModel?.resetCars()
    }

    // MARK: - Map methods
    
    fileprivate func checkUserPosition()
    {
        let locationController = LocationController.shared
        if locationController.isAuthorized, let userLocation = locationController.currentLocation {
            self.mapView?.showsUserLocation = true
            self.setUserPositionButtonVisible(true)
            self.centerMap(on: userLocation)
            self.checkedUserPosition = true
        } else {
            let firstCheckUserPosition = "FirstCheckUserPosition"
            if !UserDefaults.standard.bool(forKey: firstCheckUserPosition) {
                locationController.requestLocationAuthorization(handler: { (status) in
                    UserDefaults.standard.set(true, forKey: firstCheckUserPosition)
                    self.checkedUserPosition = true
                })
            }
        }
    }
    
    fileprivate func getRadius() -> CLLocationDistance?
    {
        if let mapView = self.mapView {
            let distanceMeters = mapView.radiusBaseOnViewWidth
            return distanceMeters
        }
        return nil
    }
    
    fileprivate func centerMap() {
        let locationController = LocationController.shared
        if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
            centerMap(on: userLocation)
        }
        else {
            let dialog = ZAlertView(title: nil, message: "alert_centerMapMessage".localized(), isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
            okButtonHandler: { alertView in
                alertView.dismissAlertView()
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            },
            cancelButtonHandler: { alertView in
                alertView.dismissAlertView()
            })
            dialog.allowTouchOutsideToDismiss = false
            dialog.show()
        }
    }
    
    fileprivate func centerMap(on position: CLLocation) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let location = CLLocationCoordinate2DMake(position.coordinate.latitude, position.coordinate.longitude)
        let region = MKCoordinateRegionMake(location, span)
        self.mapView?.setRegion(region, animated: true)
    }
    
    fileprivate func turnMap() {
        let newCamera: MKMapCamera = MKMapCamera()
        newCamera.pitch = self.mapView.camera.pitch
        newCamera.centerCoordinate = self.mapView.camera.centerCoordinate
        newCamera.altitude = self.mapView.camera.altitude
        newCamera.heading = 0
        self.mapView.setCamera(newCamera, animated: true)
    }
}

// MARK: - Gesture delegate

extension SearchCarsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view_navigationBar)
        if self.view_navigationBar.frame.contains(point) {
            return false
        }
        return true
    }
}

// MARK: - Map delegate

extension SearchCarsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer()
        }
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.heading))
        self.stopRequest()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.setTurnButtonDegrees(CGFloat(self.mapView.camera.heading))
        self.getResults()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        if let annotationView = annotationView {
            if let carAnnotation = annotationView.annotation as? CarAnnotation {
                if let car = carAnnotation.car {
                    annotationView.image = car.getAnnotationViewImage()
                }
            } else if annotationView.annotation is MKUserLocation {
                annotationView.image = UIImage(named: "ic_user")
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }
        if let carAnnotation = view.annotation as? CarAnnotation {
            if let car = carAnnotation.car {
                // TODO: show callout for this car
                print(car.plate ?? "")
            }
        }
    }
}
