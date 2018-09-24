//
//  ViewController.swift
//  IntDevTask
//
//  Created by Ahmed Ezzat on 9/22/18.
//  Copyright © 2018 Ahmed Ezzat. All rights reserved.
//

import UIKit
import GoogleSignIn
import CoreLocation
import GooglePlacePicker

//import Firebase



class ViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate {
    
    var lat:String = "" , long :String = ""
    var currentLat: Double?
    var currentLng: Double?
    let locationManager = CLLocationManager()
    
    let id = UserDefaults.standard.string(forKey: "id")
    
    let googleSignInButton = GIDSignInButton()
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        googleSignInButton.center = view.center
        view.addSubview(googleSignInButton)
        //adding the delegates
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        //getting the signin button and adding it to view
        
        
        //        view.addSubview(googleSignInButton)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // handle loggedIn
    
    @objc func openMap() {
        setLocationManager()
        
        let center = CLLocationCoordinate2D(latitude: self.currentLat ?? 30.044281, longitude: self.currentLng ?? 31.340002)
        print(self.currentLat, self.currentLng)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001,
                                               longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001,
                                               longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    
    
    // Location Manager
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    let fullAddress = "\(pm.subThoroughfare ?? ""), \(pm.thoroughfare ?? ""), \(pm.name ?? ""), \(pm.subLocality ?? ""), \(pm.locality ?? ""), \(pm.country ?? "")"
                    var formatted_address: String!
                    formatted_address = fullAddress.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "-", with: " ")
                    
                    print(formatted_address)
                    
                }
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        //if any error stop and print the error
        if error != nil{
            print(error ?? "google error")
            return
        }
        else {
            guard let id = user.authentication.idToken else { return }
            UserDefaults.standard.set(id, forKey: "id")
            guard let email = user.profile.email else { return }
            UserDefaults.standard.set(email, forKey: "email")
            print("\(String(describing: user.profile.email))")
            openMap()
            
        }
        
    }
}


// Get Current Location
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch status {
        case .denied:
            ()
        case .notDetermined:
            setLocationManager()
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = locations.last {
                self.currentLat = location.coordinate.latitude
                self.currentLng = location.coordinate.longitude
                print(self.currentLat!, self.currentLng!)
                locationManager.stopUpdatingLocation()
            }
        default:
            break
        }
        
    }
    
    
}

// Google PlacePicker
extension ViewController: GMSPlacePickerViewControllerDelegate {
    // pick place
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        print(place.formattedAddress!.components(separatedBy: ", ").joined(separator: ","))
        if place.formattedAddress == nil {
            getAddressFromLatLon(pdblLatitude: "\(place.coordinate.latitude)", withLongitude: "\(place.coordinate.longitude)")
        }
        self.lat = "\(place.coordinate.latitude)"
        self.long = "\(place.coordinate.longitude)"
        //viewController.dismiss(animated: true, completion: nil)
        
        //  openDirc()
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(String(describing: self.lat)),\(String(describing: self.long))&zoom=14&views=traffic&q=\(String(describing: self.lat)),\(String(describing: self.long))")!, options: [:], completionHandler: nil)
        }else{
            
            UIApplication.shared.open(URL(string: "itms://itunes.apple.com/eg/app/google-maps-gps-navigation/id585027354?mt=8")!)
            
            
        }
    }
    
    // cancel
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
}
