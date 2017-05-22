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
    fileprivate var checkedUserPosition:Bool = false
    fileprivate let kMinSearchRadius:Double = 1 //	1 meter
    fileprivate let kMaxSearchRadius:Double = 250 //	250km
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
        // Map
        self.setupMap()
        NotificationCenter.observe(notificationWithName: LocationControllerNotification.didAuthorized) { [weak self] _ in
            self?.centerMap()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if !checkedUserPosition {
            checkUserPosition()
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
    
    fileprivate func setUserPositionButtonVisible(_ visible: Bool)
    {
        // TODO: ???
        // locationInfoView.set(userPositionButtonVisible: visible)
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
    
    fileprivate func stopRequest() {
        resultsTask?.cancel()
//        searchRequest?.cancel()
//        searchRequest = nil
        // TODO: ???
    }
    
    fileprivate func getResults() {
        stopRequest()
        resultsTask = DispatchWorkItem { [weak self] in
            if let radius = self?.getRadius() {
                if let mapView = self?.mapView {
                    self?.reloadResults(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: radius)
                    // TODO: ???
                    return
                }
            }
            self?.updatePoi(with: [Car]())
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: resultsTask!)
    }
    
    internal func reloadResults(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance)
    {
//        searchRequest = ServicesController.shared.search(fromRegion: region, children: childrenSelected, startDate: startDateSelected, endDate: endDateSelected, categories: categoriesSelected, isForBirthDay: false, { [weak self] (services, error) in
//
//            self?.bottomSearchViewController.setLoadingViewVisible(false)
//            
//            if let error = error
//            {
//                debugLog("Search Error: \(error)")
//                
//                switch error  as AppServiceError {
//                case .searchError:
//                    Toast.present(withTitle: "default.warning".localized(), message: "search.error.message".localized(), image: nil)
//                default: break;
//                }
//            }
//            else
//            {
//                self?.bottomSearchViewController.noResultsDescriptionLabel?.text = "search.noresults.increase.description".localized()
//                self?.updateServices(services)
//            }
//        })
    }
    
    internal func updatePoi(with withCars: [Car])
    {
        // TODO: ???
//        self.services = services
//        
//        let locationController = LocationController.shared
//        if locationController.isAuthorized == true, let userLocation = locationController.currentLocation {
//            if sortingValue == .alphanumeric
//            {
//                sortingValue = .distance
//            }
//            
//            for service in services
//            {
//                service.distance = CLLocation(latitude: service.latitude, longitude: service.longitude).distance(from: userLocation)
//            }
//        }
//        
//        var annotations:[ServiceAnnotation] = []
//        for service in services
//        {
//            let coordinates = CLLocationCoordinate2DMake(service.latitude, service.longitude)
//            let annotation = ServiceAnnotation()
//            annotation.coordinate = coordinates
//            annotation.title = service.name
//            annotation.service = service
//            
//            annotations.append(annotation)
//        }
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
                // TODO: ???
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
        if let mapView = mapView {
            let distanceMeters = mapView.radiusBaseOnViewWidth
            let distanceKM = (distanceMeters * 2) / 1000
            guard distanceKM < kMaxSearchRadius else {
                return nil
            }
            guard distanceMeters > kMinSearchRadius else {
                return kMinSearchRadius
            }
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
    
    fileprivate func centerMap(on position: CLLocation)
    {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let location = CLLocationCoordinate2DMake(position.coordinate.latitude, position.coordinate.longitude)
        let region = MKCoordinateRegionMake(location, span)
        
        self.mapView?.setRegion(region, animated: true)
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        stopRequest()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getResults()
    }
    
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else
        {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
            
        if let annotationView = annotationView
        {
            annotationView.canShowCallout = true
            if let serviceAnnotation = annotationView.annotation as? ServiceAnnotation
            {
                if let service = serviceAnnotation.service
                {
                    annotationView.image = service.pinImage
                }
            }
        }
            
        return annotationView
    }
    */
    
    /*
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        guard !(view.annotation is MKUserLocation) else { return }
        
        if let cluster = view.annotation as? FBAnnotationCluster
        {
            let span = MKCoordinateSpanMake(mapView.region.span.latitudeDelta * 0.2, mapView.region.span.longitudeDelta * 0.2)
            let region = MKCoordinateRegion(center: cluster.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    */
}
