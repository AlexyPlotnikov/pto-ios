//
//  LocationManager.swift
//  TO
//
//  Created by RX Group on 19.02.2021.
//

import Foundation
import CoreLocation

@objc protocol LocationManagerDelegate {
    func locationUpdeted()
    func getLocationUpdate()
}

class LocationManager: NSObject
{
  
    weak var delegate: LocationManagerDelegate?
    
    public static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    public var lastLocation: CLLocation?

    func updateLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
    }
}

extension LocationManager: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        self.lastLocation = location
        self.delegate?.getLocationUpdate()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let location = manager.location else { return }
        self.lastLocation = location
        self.delegate?.locationUpdeted()
    }
}
