//
//  SelectLocationViewController.swift
//  RestaurantsInALocation
//
//  Created by Sanket  Ray on 12/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class SelectLocationViewController: UIViewController {
    
    @IBOutlet weak var detectLocationButton: UIButton!
    @IBOutlet weak var enterLocationButton: UIButton!
    

    let manager = CLLocationManager()
    var latitude : CLLocationDegrees = 0.0
    var longitude : CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self
        detectLocationButton.layer.cornerRadius = 5
        detectLocationButton.layer.masksToBounds = true
        enterLocationButton.layer.cornerRadius = 5
        enterLocationButton.layer.masksToBounds = true
        
    }
    
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    @IBAction func detectLocation(_ sender: Any) {
        //detect location and dismiss
        print("getting location")
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    @IBAction func dismissSelectLocationVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func getAddress(completion: ()-> Void) {
        print("Running get address")
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            
            if error != nil {
                print("Error geocoding: \(error?.localizedDescription)")
                return
            }
            if ((placemarks?.count)! > 0) {
                let pm = placemarks![0] as! CLPlacemark
                ViewController.navigationTitleButton.setTitle(pm.name, for: .normal)
            }
        }
        completion()
    }
    
}
extension SelectLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationDetails = manager.location?.coordinate
        latitude = (locationDetails?.latitude)!
        longitude = (locationDetails?.longitude)!
        print(latitude,longitude)
        
        ViewController.locationLatitude = "\(latitude)"
        ViewController.locationLongitude = "\(longitude)"
        
        getAddress {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension SelectLocationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("🥕",place.coordinate.latitude,place.coordinate.longitude,"🥕")
        
        ViewController.locationLatitude = "\(place.coordinate.latitude)"
        ViewController.locationLongitude = "\(place.coordinate.longitude)"
        ViewController.navigationTitleButton.setTitle(place.name, for: .normal)
        
        dismiss(animated: false) {
            self.dismiss(animated: false, completion: nil)
        }
 
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}




