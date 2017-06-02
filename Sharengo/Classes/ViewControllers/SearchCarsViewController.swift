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
import StoryboardConstraint
import DeviceKit

class SearchCarsViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_carPopup: CarPopupView!
    @IBOutlet fileprivate weak var view_circularMenu: CircularMenuView!
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_searchBar: SearchBarView!
    @IBOutlet fileprivate weak var mapView: MKMapView!
    @IBOutlet fileprivate weak var btn_closeCarPopup: UIButton!
    fileprivate var closeCarPopupHeight: CGFloat = 0.0
    
    fileprivate var checkedUserPosition: Bool = false
    fileprivate let carPopupDistanceOpenDoors: Int = 50
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
        self.btn_closeCarPopup.rx.tap.asObservable()
            .subscribe(onNext:{
                self.closeCarPopup()
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
            default:
                self?.view_searchBar.endEditing(true)
                self?.closeCarPopup()
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
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        // CarPopup
        self.view_carPopup.bind(to: ViewModelFactory.carPopup())
        self.view_carPopup.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .open(let car):
                if let distance = car.distance, let distanceOpenDoors = self?.carPopupDistanceOpenDoors {
                    if Int(distance.rounded()) <= distanceOpenDoors {
                        print("Open doors \(car)")
                    } else {
                        let dialog = ZAlertView(title: nil, message: "alert_carPopupDistanceMessage".localized(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                } else {
                   self?.showLocalizationAlert(message: "alert_carPopupLocalizationMessage".localized())
                }
            case .book(let car):
                print("Book car \(car)")
                break
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.view_carPopup.alpha = 0.0
        self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
        switch Device().diagonal {
        case 3.5:
            self.closeCarPopupHeight = 160
        case 4:
            self.closeCarPopupHeight = 170
        case 4.7:
            self.closeCarPopupHeight = 185
        case 5.5:
            self.closeCarPopupHeight = 195
        default:
            break
        }
        // SearchBar
        self.view_searchBar.bind(to: ViewModelFactory.searchBar())
        self.view_searchBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .reload:
                self?.view_searchBar.updateCollectionView(show: true)
            case .address(let address):
                if let location = address.location {
                    self?.centerMap(on: location)
                }
                self?.view_searchBar.updateCollectionView(show: false)
                if self?.view_searchBar.viewModel?.speechInProgress.value == true {
                    self?.view_searchBar.viewModel?.speechInProgress.value = false
                    if #available(iOS 10.0, *) {
                        self?.view_searchBar.viewModel?.speechController.manageRecording()
                    }
                }
            case .car(let car):
                if let location = car.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.005, longitude: location.coordinate.longitude)
                    self?.centerMap(on: newLocation)
                }
                self?.view_carPopup.updateWithCar(car: car)
                self?.view.layoutIfNeeded()
                UIView .animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0
                    } else {
                        self?.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self?.closeCarPopupHeight ?? 0 + 40
                    }
                    self?.view_carPopup.alpha = 1.0
                    self?.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self?.view.layoutIfNeeded()
                })
                self?.view_searchBar.updateCollectionView(show: false)
                if self?.view_searchBar.viewModel?.speechInProgress.value == true {
                    self?.view_searchBar.viewModel?.speechInProgress.value = false
                    if #available(iOS 10.0, *) {
                        self?.view_searchBar.viewModel?.speechController.manageRecording()
                    }
                }
            default: break
            }
        }).addDisposableTo(self.disposeBag)
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
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.didUnAuthorized) { [weak self] _ in
            let locationController = LocationController.shared
            if !locationController.isAuthorized && UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
                self?.mapView?.showsUserLocation = false
                self?.setUserPositionButtonVisible(false)
            }
        }
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.locationDidUpdate) { [weak self] _ in
            self?.viewModel?.manageAnnotations()
            if let carAnnotation = self?.mapView.selectedAnnotations.first as? CarAnnotation {
                if let car = carAnnotation.car {
                    self?.view_carPopup.updateWithCar(car: car)
                    self?.view.layoutIfNeeded()
                }
            }
        }
        NotificationCenter.default.addObserver(forName:
        NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.view_searchBar.updateInterface()
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
    
    // MARK: - CarPopup methods
    
    fileprivate func closeCarPopup() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view_carPopup.alpha = 0.0
            self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = -self.view_carPopup.frame.size.height-self.btn_closeCarPopup.frame.size.height
            self.view.layoutIfNeeded()
        })
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
                            button.transform = CGAffineTransform(rotationAngle: -(degrees.degreesToRadians))
                        })
                        return
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
    
    fileprivate func setupMap() {
        if UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
            self.mapView.showsUserLocation = false
            self.setUserPositionButtonVisible(false)
        }
        let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = true
        self.mapView.add(overlay, level: .aboveLabels)
    }
    
    fileprivate func checkUserPosition() {
        let locationController = LocationController.shared
        if locationController.isAuthorized, let userLocation = locationController.currentLocation {
            self.mapView?.showsUserLocation = true
            self.setUserPositionButtonVisible(true)
            self.centerMap(on: userLocation)
            self.checkedUserPosition = true
        } else if !UserDefaults.standard.bool(forKey: "FirstCheckUserPosition") {
                locationController.requestLocationAuthorization(handler: { (status) in
                    UserDefaults.standard.set(true, forKey: "FirstCheckUserPosition")
                    self.checkedUserPosition = true
                })
        }
    }
    
    fileprivate func getRadius() -> CLLocationDistance? {
        if let mapView = self.mapView {
            let distanceMeters = mapView.radiusBaseOnViewHeight
            return distanceMeters
        }
        return nil
    }
    
    fileprivate func centerMap() {
        let locationController = LocationController.shared
        if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
            self.centerMap(on: userLocation)
        } else {
            self.showLocalizationAlert(message: "alert_centerMapMessage".localized())
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
    
    // MARK: - Alert methods
    
    fileprivate func showLocalizationAlert(message: String) {
        let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
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
        self.view_searchBar.stopSearchBar()
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
                annotationView.image = carAnnotation.image
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
                if let location = car.location {
                    let newLocation = CLLocation(latitude: location.coordinate.latitude - 0.005, longitude: location.coordinate.longitude)
                    self.centerMap(on: newLocation)
                }
                self.view_carPopup.updateWithCar(car: car)
                self.view.layoutIfNeeded()
                UIView .animate(withDuration: 0.2, animations: {
                    if car.type.isEmpty {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight
                    } else {
                        self.view_carPopup.constraint(withIdentifier: "carPopupHeight", searchInSubviews: false)?.constant = self.closeCarPopupHeight + 40
                    }
                    self.view_carPopup.alpha = 1.0
                    self.view.constraint(withIdentifier: "carPopupBottom", searchInSubviews: false)?.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}
