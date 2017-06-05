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
    fileprivate let clusteringManager = FBClusteringManager()
    var viewModel: SearchCarsViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchCarsViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.array_annotations.asObservable()
            .subscribe(onNext: {[weak self] (array) in
                DispatchQueue.main.async {
                    self?.clusteringManager.removeAll()
                    self?.clusteringManager.add(annotations: array)
                    DispatchQueue.global(qos: .userInitiated).async {
                        let mapBoundsWidth = Double((self?.mapView?.bounds.size.width)!)
                        let mapRectWidth = self?.mapView?.visibleMapRect.size.width
                        let scale = mapBoundsWidth / mapRectWidth!
                        let annotationArray = self?.clusteringManager.clusteredAnnotations(withinMapRect: (self?.mapView?.visibleMapRect)!, zoomScale:scale)
                        DispatchQueue.main.async {
                            self?.clusteringManager.display(annotations: annotationArray!, onMapView:self!.mapView!)
                        }
                    }
                    self?.setUpdateButtonAnimated(false)
                }
            }).addDisposableTo(disposeBag)
        self.btn_closeCarPopup.rx.tap.asObservable()
            .subscribe(onNext:{
                self.closeCarPopup()
            }).addDisposableTo(disposeBag)
        self.clusteringManager.delegate = self
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
                Router.back(self!)
                self?.view_searchBar.endEditing(true)
                self?.closeCarPopup()
            case .menu:
                print("Open menu")
                self?.view_searchBar.endEditing(true)
                self?.closeCarPopup()
                break
            default:
                break
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            
            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView: self.mapView)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if annotation is FBAnnotationCluster {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: FBAnnotationClusterViewConfiguration.custom())
            } else {
                clusterView?.annotation = annotation
            }
            return clusterView
        } else {
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
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard !(view.annotation is MKUserLocation) else { return }
        if let cluster = view.annotation as? FBAnnotationCluster {
            let span = MKCoordinateSpanMake(mapView.region.span.latitudeDelta * 0.2, mapView.region.span.longitudeDelta * 0.2)
            let region = MKCoordinateRegion(center: cluster.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else if let carAnnotation = view.annotation as? CarAnnotation {
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

extension SearchCarsViewController: FBClusteringManagerDelegate {
    func cellSizeFactor(forCoordinator coordinator: FBClusteringManager) -> CGFloat {
        return 1.0
    }
}

//	MARK: - FBAnnotationClusterViewConfiguration

extension FBAnnotationClusterViewConfiguration {
    public static func custom() -> FBAnnotationClusterViewConfiguration {
        var smallTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), displayMode: .Image(imageName: "ic_cluster"))
        smallTemplate.borderWidth = 0
        smallTemplate.fontName = Font.searchCarsClusterLabel.value.fontName
        smallTemplate.fontSize = Font.searchCarsClusterLabel.value.pointSize
        smallTemplate.labelColor = Color.searchCarsClusterLabel.value
        var mediumTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), displayMode: .Image(imageName: "ic_cluster"))
        mediumTemplate.borderWidth = 0
        mediumTemplate.fontName = Font.searchCarsClusterLabel.value.fontName
        mediumTemplate.fontSize = Font.searchCarsClusterLabel.value.pointSize
        mediumTemplate.labelColor = Color.searchCarsClusterLabel.value
        var largeTemplate = FBAnnotationClusterTemplate(range: nil, displayMode: .Image(imageName: "ic_cluster"))
        largeTemplate.borderWidth = 0
        largeTemplate.fontName = Font.searchCarsClusterLabel.value.fontName
        largeTemplate.fontSize = Font.searchCarsClusterLabel.value.pointSize
        largeTemplate.labelColor = Color.searchCarsClusterLabel.value
        return FBAnnotationClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }
}
