//
//  LocationController.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import CoreLocation

typealias LocationRequestHandler = (_ location:CLLocation?, _ placemark:CLPlacemark?, _ error:NSError?) -> ()
typealias LocationAuthorizationHandler = (_ status:CLAuthorizationStatus) -> ()
typealias LocationGeocodeHandler = (_ placemark:[CLPlacemark]?) -> ()

struct LocationControllerNotification
{
	static let didAuthorized = Notification.Name("LocationControllerDidAuthorized")
	static let didUnAuthorized = Notification.Name("LocationControllerDidUnAuthorized")
	static let locationDidUpdate = Notification.Name("LocationControllerLocationDidUpdate")
	static let didEnterRegion = Notification.Name("locationControllerDidEnterRegion")
	static let didExitRegion = Notification.Name("locationControllerDidExitRegion")
}

class LocationController:NSObject, CLLocationManagerDelegate
{
	static let shared = LocationController()
	
	var preferredStatus:CLAuthorizationStatus = .authorizedWhenInUse
	var locationManager = CLLocationManager()
	var currentLocation:CLLocation? {
		get {
			return self.locationManager.location
		}
	}
	var isUpdatingLocation = false
	var currentPlacemarks:[CLPlacemark]?
	var isAuthorized:Bool {
		get {
			return CLLocationManager.authorizationStatus() == self.preferredStatus
		}
	}
	var desiredAccuracy:CLLocationAccuracy = 500 {
		didSet {
			self.locationManager.desiredAccuracy = desiredAccuracy
		}
	}
	var locationRequestsQueue:[LocationRequestHandler] = []
	var locationAuthorizationsQueue:[LocationAuthorizationHandler] = []
	
	override init()
	{
		super.init()
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = self.desiredAccuracy
		
		self.updateCurrentLocationPlacemarks(handler: nil)
	}
	
	//	MARK: Action
	
	func requestLocationAuthorization(handler: @escaping LocationAuthorizationHandler)
	{
		if self.isAuthorized
		{
			handler(CLLocationManager.authorizationStatus())
		}
		else
		{
			self.locationAuthorizationsQueue.append(handler)
			
			if self.preferredStatus == .authorizedWhenInUse
			{
				self.locationManager.requestWhenInUseAuthorization()
			}
			else
			{
				self.locationManager.requestAlwaysAuthorization()
			}
		}
	}
	
	func startUpdatingLocation()
	{
		self.isUpdatingLocation = true
		self.locationManager.startUpdatingLocation()
	}
	
	func stopUpdatingLocation()
	{
		self.isUpdatingLocation = false
		self.locationManager.stopUpdatingLocation()
	}
	
	func requestSingleLocation(force:Bool = false, handler: @escaping LocationRequestHandler)
	{
		if let currentLocation = self.currentLocation, let placemark = self.currentPlacemarks?.first, force == false
		{
			handler(currentLocation, placemark, nil)
		}
		else
		{
			self.locationRequestsQueue.append(handler)
			self.startUpdatingLocation()
		}
	}
	
	func updateCurrentLocationPlacemarks(handler: LocationGeocodeHandler?)
	{
		self.currentPlacemarks = nil
		
		if let location = self.locationManager.location
		{
			CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemark, error in
				
				self.currentPlacemarks = placemark
				
				handler?(placemark)
				
			})
		}
	}
	
	func getGeocode(latitude:Double, longitude:Double, handler: @escaping LocationGeocodeHandler)
	{
		self.getGeocode(location: self.clLocationFrom(latitude: latitude, longitude: longitude), handler: handler)
	}
	
	func getGeocode(location:CLLocation, handler:@escaping LocationGeocodeHandler)
	{
		CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemark, error -> Void in
			
			handler(placemark)
			
		})
		
	}
	
	func clLocationFrom(latitude:Double, longitude:Double) -> CLLocation
	{
		return CLLocation(latitude: latitude, longitude: longitude)
	}
	
	//	MARK: Region Monitoring
	
	func startMonitoring(region: CLCircularRegion)
	{
		if isAuthorized && preferredStatus == .authorizedAlways
		{
			locationManager.startMonitoring(for: region)
		}
	}
	
	func startMonitoring(regions: [CLCircularRegion])
	{
		regions.forEach { startMonitoring(region: $0) }
	}
	
	func stopMonitoring(region: CLCircularRegion)
	{
		locationManager.stopMonitoring(for: region)
	}
	
	func stopMonitoring(regions: [CLCircularRegion])
	{
		regions.forEach { stopMonitoring(region: $0) }
	}
	
	func stopMonitoringAllRegions()
	{
		locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
	}
	
	//	MARK: Private
	
	private func sendLocation(location:CLLocation?, placemark: CLPlacemark?, error:NSError?)
	{
		for handler in self.locationRequestsQueue
		{
			handler(location, placemark, nil)
		}
		self.locationRequestsQueue = []
	}
	
	private func sendAuthorizationStatus(status: CLAuthorizationStatus)
	{
		for handler in self.locationAuthorizationsQueue
		{
			handler(status)
		}
		self.locationAuthorizationsQueue = []
	}
	
	//	MARK: CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
	{
		if status == preferredStatus
		{
			NotificationCenter.post(notificationWithName: LocationControllerNotification.didAuthorized)
		}
		else
		{
			stopMonitoringAllRegions()
			
			NotificationCenter.post(notificationWithName: LocationControllerNotification.didUnAuthorized)
		}
		
		sendAuthorizationStatus(status: status)
		
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{
		if let location = locations.first
		{
			if location.verticalAccuracy <= manager.desiredAccuracy || location.horizontalAccuracy <= manager.desiredAccuracy
			{
				CLGeocoder().reverseGeocodeLocation(location, completionHandler: { placemark, error in
					
					self.currentPlacemarks = nil
					
					if let placemark = placemark
					{
						self.currentPlacemarks = placemark
						
						NotificationCenter.post(notificationWithName: LocationControllerNotification.locationDidUpdate, userInfo: ["placemarks": placemark])
					}
					else
					{
						NotificationCenter.post(notificationWithName: LocationControllerNotification.locationDidUpdate)
					}
					
					self.sendLocation(location: location, placemark: placemark?.first, error: error as NSError?)
					
				})
				
				manager.stopUpdatingLocation()
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
	{
		NotificationCenter.post(notificationWithName: LocationControllerNotification.locationDidUpdate, error: (error as NSError?)!)
		
		self.sendLocation(location: nil, placemark: nil, error: error as NSError?)
		
		manager.stopUpdatingLocation()
		
	}
	
	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
	{
		NotificationCenter.post(notificationWithName: LocationControllerNotification.didEnterRegion, object: region)
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
	{
		NotificationCenter.post(notificationWithName: LocationControllerNotification.didExitRegion, object: region)
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    { }
}

extension CLPlacemark
{
	func locationName() -> String
	{
		var locationName = ""
		
		if	let name = self.name,
			let subAdministrativeArea = self.subAdministrativeArea
		{
			
			if !name.contains(subAdministrativeArea)
			{
				locationName = name + ", " + subAdministrativeArea
			}
			else
			{
				locationName = name
			}
			
		}
		else
		{
			if let name = self.name
			{
				locationName = name
			}
		}
		
		if let name = self.name, let country = self.country
		{
			locationName = name + ", " + country
		}
		
		if locationName.characters.count == 0
		{
			locationName = NSLocalizedString("Unknown Location", comment: "")
		}
		
		return locationName
	}
}
