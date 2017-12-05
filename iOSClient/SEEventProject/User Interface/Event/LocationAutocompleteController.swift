//
//  LocationAutocompleteController.swift
//  KoderMobile
//
//  Created by Aaron Satterfield on 10/16/17.
//  Copyright © 2017 Koder, Inc. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import SVProgressHUD
import GoogleMaps

/// Handles the selection of a location in the `LocationAutocompleteController`
protocol LocationPickerDelegate {
    func didPickLocation(location: EventLocation)
}

/// Allows the user to search for citys via the Google Maps API with auto complete
class LocationAutocompleteController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    let barContainer = UIView()
    var delegate: LocationPickerDelegate?
    
    lazy var currentLocationButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = UIColor.gray
        b.imageView?.contentMode = .scaleAspectFit
        b.frame = CGRect(x: 16.0, y: 64.0, width: UIScreen.main.bounds.width, height: 60.0)
        b.titleEdgeInsets = UIEdgeInsets(top: 8, left: 16.0, bottom: 8, right: 0)
        b.setTitle("Use current location", for: .normal)
        b.contentHorizontalAlignment = .left
        b.addTarget(self, action: #selector(self.actionCurrentLocation), for: .touchUpInside)
        return b
    }()
    
    /// Create the controller with a delegate so we can perform the action on complete
    convenience init(delegate: LocationPickerDelegate) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.actionCancel))
        title = "Add Location"
        view.backgroundColor = UIColor.white
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        resultsViewController?.autocompleteFilter = filter
        navigationController?.hidesNavigationBarHairline = true
        
    
        
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = [UIRectEdge.top, UIRectEdge.bottom]
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController!.searchBar.backgroundColor = UIColor.clear
        searchController!.searchBar.placeholder = "Search for your city"
        searchController!.searchBar.showsCancelButton = true
        searchController!.searchBar.searchBarStyle = .minimal
        barContainer.addSubview((searchController?.searchBar)!)
        barContainer.frame = CGRect(x: 0.0, y: 20.0, width: UIScreen.main.bounds.width, height: 44.0)
        view.addSubview(barContainer)
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.delegate = self
        
        resultsViewController?.tableCellBackgroundColor = UIColor.white
        view.addSubview(currentLocationButton)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    /// Get the user's current location and select it
    @objc func actionCurrentLocation() {
        SVProgressHUD.show()
        if LocationManager.shared == nil {
            LocationManager.shared = LocationManager()
        }
        LocationManager.shared?.add(observer: self)
        DispatchQueue.main.asyncAfter(deadline: .now()+10) {
            if SVProgressHUD.isVisible() {
                SVProgressHUD.dismiss()
                self.presentAlert(title: "Could Not Determine Location", description: nil, dismissed: nil)
            }
        }
    }
    
    /// User has tapped a location, handle it
    func didSelectPlace(place: GMSPlace) {
        didUpdateLocation(location: CLLocation.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
    }
    
}

extension LocationAutocompleteController: LocationObserver {
    
    /// Called when the LocationManager gets the updated user location
    /// Looks up the location in the Google Maps api and gets the current city
    func didUpdateLocation(location: CLLocation?) {
        LocationManager.shared?.remove(observer: self)
        guard let coordinate = location?.coordinate else {
            SVProgressHUD.dismiss()
            return
        }
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (response, error) in
            SVProgressHUD.dismiss()
            guard let result = response?.firstResult(), let country = result.country else {
                log.error("Could not lookup location: \(error?.localizedDescription ?? "")")
                DispatchQueue.main.async {
                    self.presentAlert(title: "Could Not Determine Location", description: "Try again or try search.", dismissed: nil)
                }
                return
            }
            let lat = coordinate.latitude
            let long = coordinate.longitude
            var displayName = country
            // if the it is US then do city and state
            if country == "United States",
                let city = result.locality,
                let state = result.administrativeArea {
                displayName = "\(city), \(state)"
            } else if let city = result.locality {
                // outside of US we do city and country
                displayName = "\(city), \(country)"
            }
            // create location
            let location = EventLocation(longitude: long, latitude: lat, title: displayName, subtitle: country)
            // finish up and send back to the form view
            self.didGetUserLocation(userLocation: location)
        }
    }
    
    func didGetUserLocation(userLocation: EventLocation) {
        DispatchQueue.main.async {
            self.delegate?.didPickLocation(location: userLocation)
            if self.searchController?.presentingViewController != nil {
                // dismiss the search controller first if needed
                self.searchController?.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                // was not using the seach controller so just dismiss normally
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// Handle the user's selection.
extension LocationAutocompleteController: GMSAutocompleteResultsViewControllerDelegate, UISearchControllerDelegate {
    
    /// Handle selection of an autocomplete item
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        SVProgressHUD.show()
        searchController?.dismiss(animated: true, completion: {
            self.didSelectPlace(place: place)
        })
    }
    
    /// User canceled selecting location
    @objc
    func actionCancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Faield to look up inputted location
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    
    /// Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    /// Turn the network activity indicator on and off again.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    /// User stopped searching location.
    func willDismissSearchController(_ searchController: UISearchController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


