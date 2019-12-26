//
//  ViewController.swift
//  nearhere
//
//  Created by Nick Pappas on 12/13/19.
//  Copyright © 2019 Nick Pappas. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var userLocation: UILabel!
    
    var contacts = [CNContact]()
    let locationManager = CLLocationManager()
    var locations = [CLLocation]()
    
    var names = [String]()
    var addresses = [String]()
    var ids = [String]()
    var lats = [Int]()
    var lons = [Int]()
    var contactInfo : NSArray?
    
    class Contact {
        var name : String?
        var address : String?
        var id : String?
        var lat : Int?
        var lon : Int?
    }
    
    var myContacts : [Contact] = []
    
    var previousLocation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.removeObject(forKey: "info")
        contactInfo = UserDefaults.standard.object(forKey: "info") as? NSArray
        if contactInfo == nil {
            fetchContacts()
            for contact in contacts {
                names.append(contact.givenName + " " + contact.familyName)
                
                ids.append(contact.identifier)
                let postalAddress = contact.postalAddresses[0].value
                let address = postalAddress.street + ", " + postalAddress.city + ", " + postalAddress.state + " " + postalAddress.postalCode
                addresses.append(address)
            }
            contactInfo = [names, addresses, ids, lats, lons]
            print("hi")
        }
        else {
            print(contactInfo?[0])
        }
        startTrackingUserLocation()
        //UserDefaults.standard.set(contactInfo, forKey: "info")
        UserDefaults.standard.set(myContacts, forKey: "info")
        let timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
        //updateLocation()
    }
    
    func startTrackingUserLocation() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            //convertContactAddressesToCoords()
        }
    }

    func convertContactAddressesToCoords() {
        let geoCoder = CLGeocoder()
        //let postalAddress = CNMutablePostalAddress()
        for contact in contacts {
            print("loop")
            let postalAddress = contact.postalAddresses[0].value
            let address = postalAddress.street + ", " + postalAddress.city + ", " + postalAddress.state + " " + postalAddress.postalCode
            print(address)
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    print("Location not found")
                    return
                }
                if let error = error {
                    print("Failed to convert to coords: ", error)
                    return
                }
                print(location)
                self.locations.append(location)
            }
        }
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (success, err) in
            if let err = err {
                print("Failed to fetch contacts: ", err)
                return
            }
            
            if success {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPostalAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request) { (contact, stopPointer) in
                        self.contacts.append(contact)
                    }
                }
                catch let err {
                    print("Could not enumerate contacts: ", err)
                }
            }
        }
    }
    /*
    func updateLocation () {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default
).async(execute: {

    let taskID = self.beginBackgroundUpdateTask()
    

            // Do something with the result
    self.endBackgroundUpdateTask(taskID: taskID)

            })
    }
 */
    
    @objc func runTimedCode() {
        print(locationManager.location)
        userLocation.text = locationManager.location?.description
    }

    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: ({}))
    }

    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
}

