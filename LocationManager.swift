//
//  LocationManager.swift
//  Prayer Pulse
//
//  Created by mac on 18/08/18.
//  Copyright © 2018 mac. All rights reserved.
//


import UIKit
import CoreLocation

protocol LocationManagerDelegate {
    func locationDidUpdated(success: Bool)
}

class LocationManager: NSObject , CLLocationManagerDelegate {
    
    // MARK: -  Variable
    
    static let sharedInstance = LocationManager()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var delegate: LocationManagerDelegate?
    
    // MARK: - Init
    
    
    override init() {
        super.init()
        //Set up CLLocationManager instance
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if [.authorizedWhenInUse, .authorizedAlways].contains(status) {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty {
            currentLocation = locations.last
            delegate?.locationDidUpdated(success: true)
        }
        //Save latitude and longitude in defaults
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        print(locations.last?.coordinate.latitude ?? 0, locations.last?.coordinate.longitude ?? 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        delegate?.locationDidUpdated(success: false)
    }
    
    // MARK: - Instance Method
    
    func startLocationTracking() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        case .denied:
            print("Show alert")
        case .restricted:
            break
        }
    }
    
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func restartLocationUpdating() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func isAutorizationStausDenined() -> Bool {
        return CLLocationManager.authorizationStatus() == .denied
    }
    

}
