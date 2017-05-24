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
    fileprivate let kMinSearchRadius:Double = 1 // 1 meter
    fileprivate let kMaxSearchRadius:Double = 250 // 250km
    fileprivate var resultsTask: DispatchWorkItem?
    fileprivate var annotationsForCars:[String:MKAnnotation] = [:]
    
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
            self?.centerMap()
        }
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
        self.resultsTask?.cancel()
        // TODO: request has to be cancelled
        // TODO: hide loading
    }
    
    fileprivate func getResults() {
        self.stopRequest()
        self.resultsTask = DispatchWorkItem { [weak self] in
            if let radius = self?.getRadius() {
                if let mapView = self?.mapView {
                    // TODO: show loading
                    self?.reloadResults(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: radius)
                    return
                }
            }
            self?.updateCars(with: [Car]())
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: resultsTask!)
    }
    
    internal func reloadResults(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        /*
        let dispatchTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            let cars = [
                Car(plate: "ABC", latitude: "44.968917", longitude: "7.616103")
            ]
            self.updateCars(with: cars)
        }
        */
        // TODO: we need to ask server for informations about cars
        ApiController.searchCars(latitude: latitude, longitude: longitude, radius: radius)
    }
    
    internal func updateCars(with cars: [Car]) {
        // TODO: hide loading
        self.viewModel?.cars = cars
        var annotationsForCarsKeys = Array(annotationsForCars.keys)
        for car in cars {
            // Distance
            let locationController = LocationController.shared
                if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
                    if let lat = car.location?.coordinate.latitude, let lon = car.location?.coordinate.longitude {
                        car.distance = CLLocation(latitude: lat, longitude: lon).distance(from: userLocation)
                    }
            }
            // Annotation
            if let key = car.plate {
                if annotationsForCarsKeys.contains(key) {
                    annotationsForCarsKeys.remove(key)
                } else if let coordinate = car.location?.coordinate {
                    let annotation = CarAnnotation()
                    annotation.coordinate = coordinate
                    annotation.car = car
                    mapView?.addAnnotation(annotation)
                    annotationsForCars[key] = annotation
                }
            }
        }
        for key in annotationsForCarsKeys {
            if let annotation = annotationsForCars[key] {
                mapView?.removeAnnotation(annotation)
                annotationsForCars.removeValue(forKey: key)
            }
        }
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
                    if locationController.isAuthorized, let userLocation = locationController.currentLocation {
                        self.mapView?.showsUserLocation = true
                        self.setUserPositionButtonVisible(true)
                        self.centerMap(on: userLocation)
                    }
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

// TODO: ???
extension SearchCarsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view_navigationBar)
        if self.view_navigationBar.frame.contains(point) {
            return false
        }
        return true
    }
}

extension SearchCarsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let tileOverlay = overlay as? MKTileOverlay else {
            return MKOverlayRenderer()
        }
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.stopRequest()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
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
