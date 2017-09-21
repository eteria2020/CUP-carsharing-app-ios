//
//  LocationManager.swift
//  LocationManager
//
//  Created by Rajan Maheshwari on 22/10/16.
//  Copyright © 2016 Rajan Maheshwari. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

/**
 LocationManager class is a controller that manage services about user location and other task like reverse geocoding
 */
public class LocationManager: NSObject,CLLocationManagerDelegate {
    
    /// Enum of possible location errors
    public enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
    }
    
    /// Time allowed to fetch the location continuously for accuracy
    public var locationFetchTimeInSeconds = 1.0
    /// LocationClosure
    public typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    /// locationCompletionHandler
    public var locationCompletionHandler: LocationClosure?
    /// ReverseGeoLocationClosure
    public typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    /// geoLocationCompletionHandler
    public var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    /// Variable of type CLLocationManager used for user location
    public var locationManager:CLLocationManager?
    /// Variable used for manage accuracy of user location
    public var locationAccuracy = kCLLocationAccuracyBest
    /// Last location that app knows about user
    public var lastLocation:CLLocation?
    /// Support variable about last location
    public var lastLocationCopy: Variable<CLLocation?> = Variable(nil)
    /// Boolean that indicate if reverse geocoding is active or not
    public var reverseGeocoding = false
    
    /// Singleton Instance
    public static let sharedInstance: LocationManager = {
        let instance = LocationManager()
        // setup code
        return instance
    }()
    
    // MARK: - Deinit methods
    deinit {
        destroyLocationManager()
    }
    
    /**
     This method remove from memory location manager
     */
    public func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }

    // MARK: - Setup methods
    
    /**
     This method setup location manager variable with its properties
     */
    public func setupLocationManager() {
        //Setting of location manager
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    //MARK: - Selectors methods
    
    /**
     This method setup location manager variable with its properties
     */
    public func startThread() {
        self.perform(#selector(sendLocation), with: nil, afterDelay: locationFetchTimeInSeconds)
    }
    
    /**
     This method setup location manager variable with its properties
     */
    public func startGeocodeThread() {
        self.perform(#selector(sendPlacemark), with: nil, afterDelay: locationFetchTimeInSeconds)
    }
    
    /**
     This method setup location manager variable with its properties
     */
    @objc public func sendPlacemark() {
        guard let _ = lastLocation else {
            
            self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
                        
            lastLocation = nil
            return
        }
        
        self.reverseGeoCoding(location: lastLocation)
        lastLocation = nil
    }
    
    /**
     This method setup location manager variable with its properties
     */
    @objc public func sendLocation() {
        guard let _ = lastLocation else {
            self.didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            lastLocation = nil
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        lastLocation = nil
    }

    /**
     This method change the fetch waiting time for location. Default is 1 second
      - Parameter seconds: seconds given for GPS to fetch location
     */
    public func setTimerForLocation(seconds:Double) {
        locationFetchTimeInSeconds = seconds
    }
    
    /**
     This method get current location
     - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
     */
    public func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Cancelling the previous selector handlers if any
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        setupLocationManager()
    }
    
    /**
     This method get Reverse Geocoded Placemark address by passing CLLocation
     - Parameter location: location Passed which is a CLLocation object
     - Parameter completionHandler: will return CLLocation object and CLPlacemark of the CLLocation and NSError in case of error
     */
    public func getReverseGeoCodedLocation(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        //Cancelling the previous selector handlers if any
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(location: location)
        }

    }
    
    /**
     This method get Latitude and Longitude of the address as CLLocation object
     - Parameter address: address given by the user in String
     - Parameter completionHandler: will return CLLocation object and CLPlacemark of the address entered and NSError in case of error
     */
    public func getReverseGeoCodedLocation(address:String,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        //Cancelling the previous selector handlers if any
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(address: address)
        }
    }
    
    /**
     This method get current location with placemark
     - Parameter completionHandler: will return Location,Placemark and error
     */
    public func getCurrentReverseGeoCodedLocation(completionHandler:@escaping ReverseGeoLocationClosure) {
        
        if !reverseGeocoding {
            
            reverseGeocoding = true
            
            //Cancelling the previous selector handlers if any
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            
            //Resetting last location
            lastLocation = nil
            
            self.geoLocationCompletionHandler = completionHandler
            
            setupLocationManager()
        }
    }

    // MARK: - Reverse GeoCoding
    
    /**
     This method execute reverse geocoding of a location
     - Parameter location: location Passed which is a CLLocation object
     */
    public  func reverseGeoCoding(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let _ = location {
                    self.didCompleteGeocoding(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    /**
     This method execute reverse geocoding of an address
     - Parameter address: address given by the user in String
     */
    public func reverseGeoCoding(address:String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                if let placemark = placemarks?[0] {
                    self.didCompleteGeocoding(location: placemark.location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //MARK: - CLLocationManager Delegate methods
    
    /**
     Delegate method that update last location
     */
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        lastLocationCopy.value = lastLocation
        
        //Manager is stopped as per the timer given
    }
    
    /**
     Delegate method that notifies if user change app's authorization about location
     */
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .authorizedWhenInUse,.authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            if self.reverseGeocoding {
                startGeocodeThread()
            } else {
                startThread()
            }
            
        case .denied:
            let deniedError = NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
            
            if reverseGeocoding {
                didCompleteGeocoding(location: nil, placemark: nil, error: deniedError)
            } else {
                didComplete(location: nil,error: deniedError)
            }
            
        case .restricted:
            if reverseGeocoding {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            } else {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            }
            break
            
        case .notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
            break
        }
    }
    
    /**
     Delegate method that notifies if there is some problem with CLLocationManager
     */
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        self.didComplete(location: nil, error: error as NSError?)
    }
    
    // MARK: - Final closure/callback
    
    /**
     didComplete
     */
    public func didComplete(location: CLLocation?,error: NSError?) {
        lastLocationCopy.value = location
        //locationManager?.stopUpdatingLocation()
        locationCompletionHandler?(location,error)
        //locationManager?.delegate = nil
        //locationManager = nil
    }
    
    /**
     didCompleteGeocoding
     */
    public func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        geoLocationCompletionHandler?(location,placemark,error)
        locationManager?.delegate = nil
        locationManager = nil
        reverseGeocoding = false
    }
}
