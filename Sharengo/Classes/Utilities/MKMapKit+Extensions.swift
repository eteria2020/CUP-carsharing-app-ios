//
//  MKMapKit+Extensions.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import MapKit

extension MKMapView
{
	var radiusBaseOnViewWidth:CLLocationDistance {
		
		let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
		let topCenterLon:Double = centerLocation.coordinate.longitude - region.span.longitudeDelta * 0.5
		
		let topCenterLocation = CLLocation(latitude: centerLocation.coordinate.latitude, longitude: topCenterLon)
		
		let radius =  centerLocation.distance(from: topCenterLocation)

		return radius
	}
	
	var radiusBaseOnViewHeight:CLLocationDistance {
		
		let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
		let topCenterLat:Double = centerLocation.coordinate.latitude - region.span.latitudeDelta * 0.5
		
		let topCenterLocation = CLLocation(latitude: topCenterLat, longitude: centerLocation.coordinate.longitude)
		
		let radius =  centerLocation.distance(from: topCenterLocation)
		
		return radius
	}
}

