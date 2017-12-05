//
//  LocationManager.swift
//  KoderMobile
//
//  Created by Aaron Satterfield on 10/16/17.
//  Copyright © 2017 Koder, Inc. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationObserver {
    func didUpdateLocation(location: CLLocation?)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static var shared: LocationManager?
    var status = CLAuthorizationStatus.notDetermined
    
    private var _observers: [AnyObject] = []
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let last = locations.last
        for o in _observers {
            if let observer = o as? LocationObserver {
                observer.didUpdateLocation(location: last)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for o in _observers {
            if let observer = o as? LocationObserver {
                observer.didUpdateLocation(location: nil)
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    public func add(observer: AnyObject) {
        guard observer is LocationObserver else {
            fatalError("Implement LocationObserver in observer class")
        }
        _observers.append(observer)
        locationManager.startUpdatingLocation()
    }
    
    public func remove(observer: AnyObject) {
        if let index = _observers.index(where: { (o) -> Bool in
            return o === observer
        }) {
            _observers.remove(at: index)
        }
        if _observers.count < 1 {
            locationManager.stopUpdatingLocation()
        }
    }
    
    public func requestLocation() {
        
    }
    
}
