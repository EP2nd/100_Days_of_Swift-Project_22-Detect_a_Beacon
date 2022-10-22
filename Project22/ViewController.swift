//
//  ViewController.swift
//  Project22
//
//  Created by Edwin Przeźwiecki Jr. on 20/10/2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    // Challenge 2:
    @IBOutlet var beaconName: UILabel!
    // Challenge 2:
    var currentBeaconUUID: UUID?
    var locationManager: CLLocationManager?
    
    // Challenge 1:
    var firstBeaconDetectedtAlertShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        distanceReading.text = "UNKNOWN"
        beaconName.text = "No beacon detected"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    // Challenge 2:
    func addBeacon(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let uuid = UUID(uuidString: uuidString)!
        let identityConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: identityConstraint, identifier: identifier)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: identityConstraint)
    }
    // Challenge 2:
    func startScanning() {
        addBeacon(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "Ed")
        addBeacon(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", major: 789, minor: 123, identifier: "Edd")
        addBeacon(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935", major: 456, minor: 789, identifier: "Eddy")
    }
    
    func update(distance: CLProximity, identifier: String) {
        UIView.animate(withDuration: 0.8) {
            self.beaconName.text = "\(identifier)"
            
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
                
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.beaconName.text = "No beacon detected."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            if currentBeaconUUID == nil { currentBeaconUUID = region.uuid }
            //guard currentBeaconUUID == region.uuid else { return }
            // Challenge 1:
            if firstBeaconDetectedtAlertShown == false {
                let ac = UIAlertController(title: "Beacon detected", message: "Follow the clues if you wish to get near it.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                firstBeaconDetectedtAlertShown = true
            }
            update(distance: beacon.proximity, identifier: region.identifier)
        } else {
            guard currentBeaconUUID == region.uuid else { return }
            currentBeaconUUID = nil
            update(distance: .unknown, identifier: "No beacon detected.")
        }
    }
}

