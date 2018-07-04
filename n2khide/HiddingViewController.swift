//
//  HiddingViewController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreLocation
import SafariServices

// 2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6 UUID

extension String {
    func reformatIntoDMS() -> String {
        let parts2F = split(separator: "-")
        let partsF = parts2F.map { String($0) }
        return String(
            format: "%@°%@'%@\"%@",
            partsF[0],
            partsF[1],
            partsF[2],
            partsF[3]
        )
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



class HiddingViewController: UIViewController, UIDropInteractionDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, setWayPoint, zap, UICloudSharingControllerDelegate, showPoint, CLLocationManagerDelegate,save2Cloud, table2Map, SFSafariViewControllerDelegate {
 
    
    
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var longitudeNextLabel: UILabel!
    @IBOutlet weak var latitudeNextLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loadingSV: UIStackView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var pin: UIBarButtonItem!
    
    @IBAction func searchButton(_ sender: Any) {
        let url = URL(string: "https://elearning.swisseducation.com")
        let svc = SFSafariViewController(url: url!)
        present(svc, animated: true, completion: nil)
    }
    @IBAction func debug(_ sender: Any) {
        
        for overlays in mapView.overlays {
            
            let latitude = overlays.coordinate.latitude
            let longitude = overlays.coordinate.longitude
           
            var box2M: String!
            for (k2U, V2U) in WP2P {
//                print("\(k2U) \(V2U.coordinate.longitude) \(V2U.coordinate.latitude)")
                if V2U.coordinate.longitude == longitude, V2U.coordinate.latitude == latitude {
                    box2M = k2U
                }
            }
            print("fcuk2962018 overlay \(overlays.coordinate) \(latitude) \(longitude) \(box2M)")
        }
        
    }
    
    @IBAction func pinButton(_ sender: Any) {
        if currentLocation != nil {
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
            let wayNames = Array(wayPoints.keys)
            let uniqueName = "GPS".madeUnique(withRespectTo: wayNames)
            
            let waypoint2 = MyPointAnnotation()
            waypoint2.coordinate  = userLocation
            waypoint2.title = uniqueName
            MKPinAnnotationView.greenPinColor()
            
            let wp2FLat = self.getLocationDegreesFrom(latitude: waypoint2.coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: waypoint2.coordinate.longitude)
            let hint2D = wp2FLat + wp2FLog
            waypoint2.subtitle = hint2D
            
//            updateWayname(waypoint2U: waypoint2, image2U: nil)
            mapView.addAnnotation(waypoint2)
             let boxes = self.doBoxV2(latitude2D: waypoint2.coordinate.latitude, longitude2D: waypoint2.coordinate.longitude, name: uniqueName)
            var box2F:[CLLocation] = []
            for box in boxes {
                box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
            }
            let newWayPoint = wayPoint(recordID:nil,UUID: nil, major:nil, minor: nil, proximity: nil, coordinates: userLocation, name: uniqueName, hint: hint2D, image: nil, order: wayPoints.count, boxes:box2F, challenge: nil, URL: nil)
            wayPoints[uniqueName] = newWayPoint
            listOfPoint2Save?.append(newWayPoint)
        }
    }
    
    private func selectSet(set2U:[CLLocation], type2U: Int, size2R: Int) -> CLLocationCoordinate2D {
        
        print("fcuk01072018 selectSet \(set2U)")
        var selectedCord:Double!
        switch size2R {
            case size2U.min:
                selectedCord = Double(MAXFLOAT)
            case size2U.max:
                selectedCord = -Double(MAXFLOAT)
            default:
                break
        }
        var selectedSet:CLLocationCoordinate2D!
        for cord in set2U {
            if size2R == size2U.min, type2U == axis.longitude {
                selectedCord = Double.minimum(cord.coordinate.longitude , selectedCord)
                if cord.coordinate.longitude == selectedCord {
                    selectedCord = cord.coordinate.longitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.max, type2U == axis.longitude {
                selectedCord = Double.maximum(cord.coordinate.longitude , selectedCord)
                if cord.coordinate.longitude == selectedCord {
                    selectedCord = cord.coordinate.longitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.min, type2U == axis.latitude {
                selectedCord = Double.minimum(cord.coordinate.latitude , selectedCord)
                if cord.coordinate.latitude == selectedCord {
                    selectedCord = cord.coordinate.latitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
            if size2R == size2U.max, type2U == axis.latitude {
                selectedCord = Double.maximum(cord.coordinate.latitude , selectedCord)
                if cord.coordinate.latitude == selectedCord {
                    selectedCord = cord.coordinate.latitude
                    selectedSet = CLLocationCoordinate2D(latitude: cord.coordinate.latitude, longitude: cord.coordinate.longitude)
                }
            }
        }
        return selectedSet
    }
    
    private func listAllZones() -> [String:CKRecordZoneID] {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        operation.fetchRecordZonesCompletionBlock = { records, error in
            if error != nil {
                print(error?.localizedDescription.debugDescription)
            }
            for rex in records! {
                print("\(rex.value.zoneID.zoneName)")
                zoneTable[rex.value.zoneID.zoneName] = rex.value.zoneID
            }
        }
        privateDB.add(operation)
        return zoneTable
    }
    
    var geotifications = [Geotification]()
    var locationManager:CLLocationManager? = nil
    
    // MARK: DMS direction section
    
    func showDirection2Take(direction2G:CGFloat) {
        if self.angle2U != nil {
            DispatchQueue.main.async {
                let direction2GN = CGFloat(self.angle2U!) - direction2G
                let tr2 = CGAffineTransform.identity.rotated(by: direction2GN)
                let degree2S = self.radiansToDegrees(radians: Double(direction2GN))
                self.centerImage.transform = tr2
                self.directionLabel.text = String(Int(degree2S))
                self.directionLabel.isHidden = false
            }
        }
    }
    
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / Double.pi }
    func degreesToRadians(degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    
    func getBearing(toPoint point: CLLocationCoordinate2D, longitude:Double, latitude: Double) -> Double {
        
        let lat1 = degreesToRadians(degrees: latitude)
        let lon1 = degreesToRadians(degrees: longitude)
        let lat2 = degreesToRadians(degrees: point.latitude)
        let lon2 = degreesToRadians(degrees: point.longitude)
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        //        return radiansToDegrees(radians: radiansBearing)

        return radiansBearing
    }
    
    // MARK location Manager delegate code + more
    
    @IBAction func stateButton(_ sender: Any) {
        // draws a square around the current window
        // Disabled 21.06.2018
        let mRect = self.mapView.visibleMapRect
//        let cordSW = mapView.convert(getSWCoordinate(mRect: mRect), toPointTo: mapView)
//        let cordNE = mapView.convert(getNECoordinate(mRect: mRect), toPointTo: mapView)
//        let cordNW = mapView.convert(getNWCoordinate(mRect: mRect), toPointTo: mapView)
//        let cordSE = mapView.convert(getSECoordinate(mRect: mRect), toPointTo: mapView)
        
//        let DNELat = getLocationDegreesFrom(latitude: getNECoordinate(mRect: mRect).latitude)
//        let DNELog = getLocationDegreesFrom(longitude: getNECoordinate(mRect: mRect).longitude)
//        let (latCords,longCords) = getDigitalFromDegrees(latitude: DNELat, longitude: DNELog)
//        let cord2U = CLLocationCoordinate2D(latitude: latCords, longitude: longCords)
        
        var coordinates =  [getNWCoordinate(mRect: mRect),getNECoordinate(mRect: mRect), getSECoordinate(mRect: mRect),getSWCoordinate(mRect: mRect),getNWCoordinate(mRect: mRect)]
        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
    }
    
    
    private func doPin(cord2D: CLLocationCoordinate2D, title: String) {
        DispatchQueue.main.async() {
            let pin = MyPointAnnotation()
            pin.coordinate  = cord2D
            pin.title = title
            self.mapView.addAnnotation(pin)
        }
    }
    
    // MARK: // iBeacon code
    
    var globalUUID: String? {
        didSet {
            startScanning()
        }
    }
    
    
    func startScanning() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        locationManager = appDelegate.locationManager
        if globalUUID != nil {
            beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: globalUUID!)!, identifier: "nobody")
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(in: beaconRegion)
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
        }
    }
    
    var isSearchingForBeacons = false
    var lastFoundBeacon:CLBeacon!
    var lastProximity: CLProximity!
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "LocationMgr state", message:  "\(region.identifier) \(state)", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
        if beaconRegion != nil {
            if state == CLRegionState.inside {
                locationManager?.startRangingBeacons(in: beaconRegion)
            }
            else {
                locationManager?.stopRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print( "Beacon in range")
     
//        lblBeaconDetails.hidden = false
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("No beacons in range")
        
//        lblBeaconDetails.hidden = true
    }
    
    
    var beaconsInTheBag:[String:Bool?] = [:]
    var beaconsLogged:[String] = []
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        var shouldHideBeaconDetails = true
        print("fcuk26062018 beaconsInTheBag \(beaconsInTheBag)\n")
        if beacons.count > 0, usingMode == op.recording {
            let beacons2S = beacons.filter { $0.proximity != CLProximity.unknown }
            if beacons2S.count > 0 {
                if let closestBeacon = beacons2S[0] as? CLBeacon {
                        let k2U = closestBeacon.minor.stringValue + closestBeacon.major.stringValue
                        print("fcuk26062018 beaconsInTheBag \(beaconsInTheBag)")
                        if beaconsInTheBag[k2U] == nil {
                            beaconsInTheBag[k2U] = true
                            trigger = point.ibeacon

                            let uniqueName = "UUID".madeUnique(withRespectTo: beaconsLogged)
                            beaconsLogged.append(uniqueName)
                            let newWayPoint = wayPoint(recordID:nil, UUID: globalUUID, major:closestBeacon.major as? Int, minor: closestBeacon.minor as? Int, proximity: nil, coordinates: nil, name: uniqueName, hint:nil, image: nil, order: wayPoints.count, boxes: nil, challenge: nil,  URL: nil)
                            wayPoints[closestBeacon.proximityUUID.uuidString] = newWayPoint
                            listOfPoint2Save?.append(newWayPoint)
                            print("WTF \(listOfPoint2Save) \(uniqueName)")
                            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
                        }
                    }
                }
        }
        
        if beacons.count > 0, usingMode == op.playing {
            let beacons2S = beacons.filter { $0.proximity != CLProximity.unknown }
            if beacons2S.count > 0 {
                if let closestBeacon = beacons2S[0] as? CLBeacon {
                    if order2Search! < listOfPoint2Seek.count {
                         let nextWP2S = listOfPoint2Seek[order2Search!]
                        print("WP2M \(WP2M) Seeking \(listOfPoint2Seek[order2Search!])")
                        let k2U = beacons2S[0].minor.stringValue + beacons2S[0].major.stringValue
                        let  alert2Post = WP2M[k2U]
                        
                        if alert2Post == nextWP2S.name {
                            if nextWP2S.URL != nil {
                                if presentedViewController?.contents != WebViewController() {
                                    let url = URL(string: nextWP2S.URL! )
                                    let svc = SFSafariViewController(url: url!)
                                    present(svc, animated: true, completion: nil)
                                    self.orderLabel.text = String(order2Search!)
                                    if order2Search! < listOfPoint2Seek.count - 1 { order2Search! += 1 }
                                    self.nextLocation2Show()
                                }
                            } else {
                                if presentedViewController?.contents != ImageViewController() {
                                    print("present")
                                    performSegue(withIdentifier: Constants.ShowImageSegue, sender: view)
                                    self.orderLabel.text = String(order2Search!)
                                    if order2Search! < listOfPoint2Seek.count - 1 { order2Search! += 1 }
                                    self.nextLocation2Show()
                                }
                            }
                        }
                    }
                }
            }
        }

        if beacons.count > 0 {
            if let closestBeacon = beacons[0] as? CLBeacon {
                if closestBeacon != lastFoundBeacon, lastProximity != closestBeacon.proximity  {
                    lastFoundBeacon = closestBeacon
                    lastProximity = closestBeacon.proximity
                    var proximityMessage: String!
                    switch lastFoundBeacon.proximity {
                    case CLProximity.immediate:
                        proximityMessage = "Very close"
                        
                    case CLProximity.near:
                        proximityMessage = "Near"
                    case CLProximity.far:
                        proximityMessage = "Far"
                    default:
                        proximityMessage = "Where's the beacon?"
                    }
//                    shouldHideBeaconDetails = false
                    print("Beacon Major = \(closestBeacon.major.intValue) BeaconMinor = \(closestBeacon.minor.intValue) Distance: \(proximityMessage)\n")
                    
                }
            }
        
        }
//      lblBeaconDetails.hidden = shouldHideBeaconDetails
    }
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: NSError!) {
        print(error)
    }
    
//    func locationManager(_ manager: CLLocationManager!, monitoringDidFailFor region: CLRegion?, withError error: Error) {
//        print(error)
//    }

//    func locationManager(_ manager: CLLocationManager!, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
//        print(error)
//    }
    
    func getLocationDegreesFrom(latitude: Double) -> String {
        var latSeconds = Int(latitude * 3600)
//        var latitudeSeconds = abs(latitude * 3600).truncatingRemainder(dividingBy: 60)
        let latDegrees = latSeconds / 3600
        latSeconds = abs(latSeconds % 3600)
        let latMinutes = latSeconds / 60
        latSeconds %= 60
        
        return String(
//            format: "%d°%d'%d\"%@",
            format: "%d-%d-%d-%@",
            abs(latDegrees),
            latMinutes,
            latSeconds,
            latDegrees >= 0 ? "N" : "S"
        )
    }
    
 
    
    func getLocationDegreesFrom(longitude: Double) -> String {
        var longSeconds = Int(longitude * 3600)
        let longDegrees = longSeconds / 3600
        longSeconds = abs(longSeconds % 3600)
//        var longitudeSeconds = abs(longitude * 3600).truncatingRemainder(dividingBy: 60)
        let longMinutes = longSeconds / 60
        longSeconds %= 60
        
        return String(
//            format: "%d°%d'%d\"%@",
             format: "%d-%d-%d-%@",
            abs(longDegrees),
            longMinutes,
            longSeconds,
            longDegrees >= 0 ? "E" : "W"
        )
    }
    
    func getDigitalFromDegrees(latitude: String, longitude: String) -> (Double, Double) {
        
        var n2C = latitude.split(separator: "-")
        let latS = Double(n2C[2])! / 3600
        let latM = Double(n2C[1])! / 60
        let latD = Double(n2C[0])?.rounded(toPlaces: 0)
        var DDlatitude:Double!
        if n2C[3] == "S" {
            DDlatitude = -latD! - latM - latS
        } else {
            DDlatitude = latD! + latM + latS
        }
        n2C = longitude.split(separator: "-")
        let lonS = Double(n2C[2])! / 3600
        let lonM = Double(n2C[1])! / 60
        let lonD = Double(n2C[0])?.rounded(toPlaces: 0)
        var DDlongitude:Double!
        if n2C[3]  == "W" {
            DDlongitude = -lonD! - lonM - lonS
        } else {
            DDlongitude = lonD! + lonM + lonS
        }
        return (DDlatitude,DDlongitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("User still thinking")
        case .denied:
            print("User hates you")
        case .authorizedWhenInUse:
                locationManager?.stopUpdatingLocation()
            locationManager?.startUpdatingHeading()
        case .authorizedAlways:
                locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        case .restricted:
            print("User dislikes you")
        }
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    
    var regionHasBeenCentered = false
    var currentLocation: CLLocation!
    
 
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        pin.isEnabled = true
        orderLabel.text = String(order2Search!)
        currentLocation = locations.first
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
//        let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
//        self.mapView.setRegion(region, animated: true)
//        self.regionHasBeenCentered = true
        DispatchQueue.main.async {
            let longValue =  self.getLocationDegreesFrom(longitude: (self.locationManager?.location?.coordinate.longitude)!)
            let latValue = self.getLocationDegreesFrom(latitude: (self.locationManager?.location?.coordinate.latitude)!)
            self.longitudeLabel.text = self.getLocationDegreesFrom(longitude: (self.locationManager?.location?.coordinate.longitude)!)
            self.latitudeLabel.text =  self.getLocationDegreesFrom(latitude: (self.locationManager?.location?.coordinate.latitude)!)
            if listOfPoint2Seek.count > 0, order2Search! <  listOfPoint2Seek.count {
                let nextWP2S = listOfPoint2Seek[order2Search!]

                if WP2M[latValue + longValue] != nil {
                    let  alert2Post = WP2M[latValue + longValue]
                    
                    if alert2Post == nextWP2S.name, usingMode == op.playing {
                        if nextWP2S.URL != nil {
                            if self.presentedViewController?.contents != WebViewController() {
                                let url = URL(string: nextWP2S.URL! )
                                let svc = SFSafariViewController(url: url!)
                                self.present(svc, animated: true, completion: nil)
                                self.orderLabel.text = String(order2Search!)
                                if order2Search! < listOfPoint2Seek.count - 1 { order2Search! += 1 }
                                self.nextLocation2Show()
                            }
                        } else {
                            if self.presentedViewController?.contents != ImageViewController() {
                                print("present")
                                self.performSegue(withIdentifier: Constants.ShowImageSegue, sender: self.view)
                                self.orderLabel.text = String(order2Search!)
                                if order2Search! < listOfPoint2Seek.count - 1 { order2Search! += 1 }
                                self.nextLocation2Show()
                            }
                        }
//                        let alert = UIAlertController(title: "WP2M Triggered", message: alert2Post, preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                        let wayPointRec = wayPoints[alert2Post!]
////                        self.centerImage.image = wayPointRec?.image
//                        let image2Show = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//                        image2Show.image = wayPointRec?.image
//                        self.mapView.addSubview(image2Show)
//                        image2Show.translatesAutoresizingMaskIntoConstraints  = false
//                        let THighConstraint = NSLayoutConstraint(item: image2Show, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 30)
//                        let TLowConstraint = NSLayoutConstraint(item: image2Show, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
//                        let TLeftConstraint = NSLayoutConstraint(item: image2Show, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
//                        let TRightConstraint = NSLayoutConstraint(item: image2Show, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
//                        self.view.addConstraints([THighConstraint,TLowConstraint,TLeftConstraint,TRightConstraint])
//                        NSLayoutConstraint.activate([THighConstraint,TLowConstraint,TLeftConstraint,TRightConstraint])
//                        self.hintLabel.text = wayPointRec?.hint
//                        self.orderLabel.text = String(order2Search!)
////                        WP2M[latValue + longValue] = nil
//                        self.deleteWM2M(key2U: latValue + longValue)
//                        order2Search? += 1
//                        UIView.animate(withDuration: 8, animations: {
//                            image2Show.alpha = 0
//                            self.hintLabel.alpha = 0
//                        }, completion: { (result) in
//                            image2Show.removeFromSuperview()
//                            self.hintLabel.text = ""
//                            self.hintLabel.alpha = 1
//                            self.nextLocation2Show()
//                        })
                    }
                }
            }
       }
        if angle2U != nil {
            self.angle2U = self.getBearing(toPoint: nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
        }
    }
    
    private func deleteWM2M(key2U: String) {
        let key2D = WP2M[key2U]
        for rex in WP2M.keys {
            if WP2M[rex] == key2D {
                WP2M[rex] = nil
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "LocationMgr fail", message:  "\(error)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("moving")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        showDirection2Take(direction2G: CGFloat(newHeading.magneticHeading * Double.pi/180))
    }
    
//    func handleEvent(forRegion region: CLRegion!) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: "Geofence Triggered", message: "Geofence Triggered", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
//    }
    
    //MARK:  Observer
    

    
    func didSet(record2U: String) {
        if !sharingApp {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Alert", message: record2U, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: delete waypoints by name
    
    func deleteAllWayPointsInPlace() {
        for wayP in mapView.annotations {
                mapView.removeAnnotation(wayP)
        }
    }
    
    func wayPoint2G(wayPoint2G: String) {
        for wayP in mapView.annotations {
            if wayP.title == wayPoint2G {
                mapView.removeAnnotation(wayP)
            }
        }
    }
    
    // MARK: setWayPoint protocl implementation
    
    func didSetURL(name: String?, URL: String?) {
        if pinViewSelected != nil {
            updateURL(waypoint2U: pinViewSelected, URL: URL)
        } else {
            let wp2C = listOfPoint2Save?.popLast()
            let wp2S = wayPoint(recordID:wp2C?.recordID,UUID: wp2C?.UUID, major: wp2C?.major, minor: wp2C?.minor, proximity: nil, coordinates: nil, name: name, hint: wp2C?.hint, image: wp2C?.image, order: wayPoints.count, boxes: nil, challenge:wp2C?.challenge, URL: URL)
            listOfPoint2Save?.append(wp2S)
        }
    }
    
    func didSetChallenge(name: String?, challenge: String?) {
        if pinViewSelected != nil, challenge != nil {
//            mapView.selectAnnotation(pinViewSelected!, animated: true)
            updateChallenge(waypoint2U: pinViewSelected, challenge: challenge)
        } else {
            // must be a ibeacon
            
            let wp2C = listOfPoint2Save?.popLast()
            let wp2S = wayPoint(recordID:wp2C?.recordID,UUID: wp2C?.UUID, major: wp2C?.major, minor: wp2C?.minor, proximity: nil, coordinates: nil, name: name, hint: wp2C?.hint, image: wp2C?.image, order: wayPoints.count, boxes: nil, challenge:challenge, URL: wp2C?.URL)
            listOfPoint2Save?.append(wp2S)
            print("fcuk02072018 listOfPoint2Save \(listOfPoint2Save)" )
        }
    }
    
    
    func didSetName(name: String?) {
         if pinViewSelected != nil, name != nil {
            mapView.selectAnnotation(pinViewSelected!, animated: true)
            updateName(waypoint2U: pinViewSelected, name2D: name!)
            
         } else {
            // must be a ibeacon
            let wp2C = listOfPoint2Save?.popLast()
            let wp2S = wayPoint(recordID:wp2C?.recordID,UUID: wp2C?.UUID, major: wp2C?.major, minor: wp2C?.minor, proximity: nil, coordinates: nil, name: name, hint: wp2C?.hint, image: wp2C?.image, order: wayPoints.count, boxes: nil, challenge: wp2C?.challenge, URL: wp2C?.URL)
            listOfPoint2Save?.append(wp2S)
        }
    }
    
    func didSetHint(name: String?, hint: String?) {
        if pinViewSelected != nil, hint != nil {
            pinViewSelected?.subtitle = hint
            mapView.selectAnnotation(pinViewSelected!, animated: true)
            updateHint(waypoint2U: pinViewSelected, hint: hint!)
        } else {
            // must be a ibeacon
            let wp2C = listOfPoint2Save?.popLast()
            let wp2S = wayPoint(recordID:wp2C?.recordID,UUID: wp2C?.UUID, major: wp2C?.major, minor: wp2C?.minor, proximity: nil, coordinates: nil, name: wp2C?.name, hint: hint, image: wp2C?.image, order: wayPoints.count, boxes: nil, challenge: wp2C?.challenge, URL: wp2C?.URL)
            listOfPoint2Save?.append(wp2S)
        }
    }
    
    func didSetImage(name: String?, image: UIImage?) {
        if pinViewSelected != nil, image != nil {
            if let thumbButton = pinView.leftCalloutAccessoryView as? UIButton {
                thumbButton.setImage(image, for: .normal)
                mapView.selectAnnotation(pinViewSelected!, animated: true)
//                updateWayname(waypoint2U: pinViewSelected, image2U: image)
            }
        } else {
            // must be a ibeacon
            let wp2C = listOfPoint2Save?.popLast()
            let wp2S = wayPoint(recordID:wp2C?.recordID,UUID: wp2C?.UUID, major: wp2C?.major, minor: wp2C?.minor, proximity: nil, coordinates: nil, name: wp2C?.name, hint: wp2C?.hint, image: image, order: wayPoints.count, boxes: nil, challenge: wp2C?.challenge, URL: wp2C?.URL)
            listOfPoint2Save?.append(wp2S)
        }
    }
    
    // MARK: MapView
    
private func getNECoordinate(mRect: MKMapRect) ->  CLLocationCoordinate2D {
        return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y: mRect.origin.y)
}
    
private func getNWCoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
        return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMinX(mRect), y: mRect.origin.y)
}

private func getSECoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
    return getCoordinateFromMapRectanglePoint(x: MKMapRectGetMaxX(mRect), y: MKMapRectGetMaxY(mRect))
}
    
    private func getSWCoordinate(mRect: MKMapRect) -> CLLocationCoordinate2D {
    return getCoordinateFromMapRectanglePoint(x: mRect.origin.x, y: MKMapRectGetMaxY(mRect))
}
    
    private func getCoordinateFromMapRectanglePoint(x: Double, y: Double) -> CLLocationCoordinate2D  {
        let swMapPoint = MKMapPointMake(x, y)
        return MKCoordinateForMapPoint(swMapPoint);
    }

//    private func getBoundingBox(mRect: MKMapRect) ->(Double, Double, Double, Double) {
////        let botLeft = getSWCoordinate(mRect: mRect)
////        let topRight = getNECoordinate(mRect: mRect)
//
//
////        let BLP = MyPointAnnotation()
////        BLP.coordinate  = CLLocationCoordinate2D(latitude: botLeft.latitude, longitude: botLeft.longitude)
////        BLP.title = "botLeft"
////        mapView.addAnnotation(BLP)
////
////        let TRP = MyPointAnnotation()
////        TRP.coordinate  = CLLocationCoordinate2D(latitude: topRight.latitude, longitude: topRight.longitude)
////        TRP.title = "topRight"
////        mapView.addAnnotation(TRP)
//
//        return (botLeft.latitude, botLeft.longitude, topRight.latitude, topRight.longitude)
//    }

    @IBAction func boxButton(_ sender: Any) {
        // Disabled 21.06.2018
        // 7-0-36-E
        // 46-20-22-N
        let box2D:[(Double,Double)] = [(36,22),(37,22),(37,23),(36,23),(36,22)]
        var coordinates:[CLLocationCoordinate2D] = []
        for sec2U in box2D {
                let lat2P = "7-0-\(sec2U.0)-E"
                let lon2P  = "46-20-\(sec2U.1)-N"
                let (cordLat, cordLong) = getDigitalFromDegrees(latitude: lat2P, longitude: lon2P)
                let cord2U = CLLocationCoordinate2D(latitude: cordLat, longitude: cordLong)
                coordinates.append(cord2U)
        }
        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
    }
    
    private func convert2nB(latitude2D: Double, longitude2D:Double, name2U:String) -> CLLocationCoordinate2D {

        let longValue =  self.getLocationDegreesFrom(longitude: (longitude2D))
        let latValue = self.getLocationDegreesFrom(latitude: (latitude2D))

       let (latD, longD) = getDigitalFromDegrees(latitude: latValue, longitude: longValue)
        WP2M[latValue + longValue] = name2U
        return CLLocationCoordinate2D(latitude: latD, longitude: longD)
    }
    
    var neCord:CLLocationCoordinate2D?
    var nwCord:CLLocationCoordinate2D?
    var seCord:CLLocationCoordinate2D?
    var swCord:CLLocationCoordinate2D?
    
    private func drawBox(Cords2E: CLLocationCoordinate2D,  boxColor: UIColor, corner2R: Int?) -> MKOverlay {
        var cords2D:[CLLocationCoordinate2D] = []
        
        let SWLatitude = Cords2E.latitude - Constants.Variable.magic
        let SWLongitude = Cords2E.longitude - Constants.Variable.magic
        var cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        
        if corner2R == corners.southWest {
//            doPin(cord2D: cord2U, title: "SW")
            swCord = cord2U
        }
        cords2D.append(cord2U)
        let NWLatitude = Cords2E.latitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: SWLongitude)
       
        if corner2R == corners.northWest {
//            doPin(cord2D: cord2U, title: "NW")
            nwCord = cord2U
        }
        cords2D.append(cord2U)
        let NELongitude = Cords2E.longitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NELongitude)
        
        if corner2R == corners.northEast {
//            doPin(cord2D: cord2U, title: "NE")
            neCord = cord2U
        }
        cords2D.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: NELongitude)
        if corner2R == corners.southEast {
//            doPin(cord2D: cord2U, title: "SE")
            seCord = cord2U
        }
        cords2D.append(cord2U)
        
//        let polyLine:MKOverlay = MKPolyline(coordinates: &cords2D, count: cords2D.count)
        let polygon:MKOverlay = MKPolygon(coordinates: &cords2D, count: cords2D.count)
        
        DispatchQueue.main.async {
            self.polyColor = boxColor
//            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
//            self.mapView.add(polygon, level: MKOverlayLevel.aboveRoads)
        }
//        return polyLine
        return polygon
    }
    
    private func doBoxV2(latitude2D: Double, longitude2D: Double, name: String) -> [MKOverlay]
    {
        var boxes2R:[CLLocation] = []
        var boxes2S:[MKOverlay] = []
        
        if latitude2D + (Constants.Variable.magic/2)  > latitude2D {
            var cords2U = convert2nB(latitude2D: latitude2D + (Constants.Variable.magic*1.5), longitude2D: longitude2D, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
            var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.blue, corner2R: corners.northWest)
            
            boxes2S.append(poly2F)
            WP2P["blue"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D, name2U: name)
           cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
            poly2F =  drawBox(Cords2E: cords2U, boxColor: UIColor.orange, corner2R:  corners.southWest)
            boxes2S.append(poly2F)
            WP2P["orange"] = poly2F
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
           
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.yellow, corner2R: corners.northWest)
            boxes2S.append(poly2F)
            WP2P["yellow"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D - (Constants.Variable.magic * 1.5), longitude2D: longitude2D, name2U: name)
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.orange, corner2R: corners.northWest)
            boxes2S.append(poly2F)
            WP2P["red"] = poly2F
        }
        if longitude2D + (Constants.Variable.magic/2) > longitude2D  {
            var cords2U = convert2nB(latitude2D: latitude2D + Constants.Variable.magic * 1.5, longitude2D: longitude2D + Constants.Variable.magic * 1.5, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.green, corner2R:  corners.northEast)
            boxes2S.append(poly2F)
            WP2P["purple"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D + Constants.Variable.magic * 1.5, name2U: name)
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
           
            boxes2R.append(cords2F)
                poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.red, corner2R: corners.southEast)
            boxes2S.append(poly2F)
            WP2P["pink"] = poly2F
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D - Constants.Variable.magic * 1.5, longitude2D: longitude2D - Constants.Variable.magic * 1.5, name2U: name)
            var cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            
            boxes2R.append(cords2F)
             var poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.green, corner2R: corners.northEast)
            boxes2S.append(poly2F)
            WP2P["cyan"] = poly2F
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D - Constants.Variable.magic * 1.5, name2U: name)
            
            cords2F = CLLocation(latitude: cords2U.latitude, longitude: cords2U.longitude)
            boxes2R.append(cords2F)
             poly2F = drawBox(Cords2E: cords2U, boxColor: UIColor.red, corner2R:  corners.southWest)
            boxes2S.append(poly2F)
            WP2P["brown"] = poly2F
        }
        
        // newcode to draw around 4 smaller boxes
        // struct axis and size2U
        var cords2D:[CLLocationCoordinate2D] = []
        if nwCord != nil {
            cords2D.append(nwCord!)
        }
        if neCord != nil {
            cords2D.append(neCord!)
        }
        if seCord != nil {
            cords2D.append(seCord!)
        }
        if swCord != nil {
            cords2D.append(swCord!)
        }
        if cords2D.count == 4 {
             let polygon:MKOverlay = MKPolygon(coordinates: &cords2D, count: cords2D.count)
            boxes2S.append(polygon)
            DispatchQueue.main.async {
                self.polyColor = UIColor.black
                self.mapView.add(polygon, level: MKOverlayLevel.aboveRoads)
            }
        }
//        return boxes2R
        return boxes2S
    }
    
//    private func doBox(latitude2S: String, longitude2S: String) {
//        var coordinates:[CLLocationCoordinate2D] = []
//        print("latitude2S \(latitude2S) longitude2S \(longitude2S)")
//        var latitude2P = latitude2S.split(separator: "-")
//        var longitude2P = longitude2S.split(separator: "-")
//
//        let lat2Pplus = Int(latitude2P[2])! + 1
//        let lon2Pplus = Int(longitude2P[2])! + 1
//
//        //        [(36,22)
//        let start2PLatitude = "\(latitude2P[0])-\(latitude2P[1])-\(latitude2P[2])-\(latitude2P[3])"
//        let (NWLatitude, NWLongitude) = getDigitalFromDegrees(latitude: start2PLatitude, longitude: longitude2S)
//        var cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NWLongitude)
//        coordinates.append(cord2U)
//
//        //         (37,22)
//        let source2PLatitude = "\(latitude2P[0])-\(latitude2P[1])-\(lat2Pplus)-\(latitude2P[3])"
//        print("source2PLatitude \(source2PLatitude) longitude2S \(longitude2S)")
//        let (SELatitude, SELongitude) = getDigitalFromDegrees(latitude: source2PLatitude, longitude: longitude2S)
//        cord2U = CLLocationCoordinate2D(latitude: SELatitude, longitude: SELongitude)
//        coordinates.append(cord2U)
//
//        //        (37,23)
//        let source2PLongitude = "\(longitude2P[0])-\(longitude2P[1])-\(lon2Pplus)-\(longitude2P[3])"
//        print("source2PLongitude \(source2PLongitude) \(source2PLongitude)")
//        let (SWLatitude, SWLongitude) = getDigitalFromDegrees(latitude: source2PLatitude, longitude: source2PLongitude)
//        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
//        coordinates.append(cord2U)
////
////        //        (36,23)
//        print("source2PLongitude \(latitude2S) \(source2PLongitude)")
//        let (NELatitude, NELongitude) = getDigitalFromDegrees(latitude: latitude2S, longitude: source2PLongitude)
//        cord2U = CLLocationCoordinate2D(latitude: NELatitude, longitude: NELongitude)
//        coordinates.append(cord2U)
////
////        //        (36,22)]
//        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NWLongitude)
//        coordinates.append(cord2U)
//
//
//        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
//        DispatchQueue.main.async {
//            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        let pinMoving = view.annotation?.title
        print("fcuk30062018 pinMoving \(pinMoving) \(newState.rawValue) \(oldState.rawValue) ")
        if newState == MKAnnotationViewDragState.starting {
            let wP2E = wayPoints[((view.annotation?.title)!)!]
            print("fcuk30112018 \(wP2E)")
            let boxes2D = wP2E?.boxes
            for overlays in mapView.overlays {
                let latitude = overlays.coordinate.latitude
                let longitude = overlays.coordinate.longitude
                for boxes in boxes2D! {
                    let long2C:Double = ((boxes?.coordinate.longitude)!)
                    let lat2C:Double = (boxes?.coordinate.latitude)!
                    print("\(long2C) \(lat2C) \(longitude) \(latitude)")
                    if long2C == longitude, lat2C == latitude {
                        mapView.remove(overlays)
                    }
                }
            }
        }
        if newState == MKAnnotationViewDragState.ending {
            let boxes = self.doBoxV2(latitude2D: (view.annotation?.coordinate.latitude)!, longitude2D: (view.annotation?.coordinate.longitude)!, name: ((view.annotation?.title)!)!)
            var box2F:[CLLocation] = []
            for box in boxes {
                box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
            }
            wayPoints[((view.annotation?.title)!)!]?.boxes = box2F
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapview region changed")
//        let answer = getBoundingBox(mRect: mapView.visibleMapRect)
//        print("mapview region changed \(answer)")
    }
    
    private func clearWaypoints() {
        mapView?.removeAnnotation(mapView.annotations as! MKAnnotation)
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    
    class MyPointAnnotation : MKPointAnnotation {
//        var pinColor: UIColor
//
//        init(pinColor: UIColor) {
//            self.pinColor = pinColor
//            super.init()
//        }
        var tintColor: UIColor?
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //check annotation is not user location
//        let userLongitude = mapView.userLocation.coordinate.longitude
//        let userLatitiude = mapView.userLocation.coordinate.latitude
//        if annotation.coordinate.longitude == userLongitude, annotation.coordinate.latitude == userLatitiude {
//            return nil
//        }
        if annotation is MKUserLocation {
            return nil
        }
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier) as? MKPinAnnotationView
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view.canShowCallout = true
//            let colorPointAnnotation = annotation as! MyPointAnnotation
            view.tintColor = .blue
            
        } else {
            view.annotation = annotation
            view?.tintColor = .green
        }
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view.leftCalloutAccessoryView  = UIButton(frame: Constants.LeftCalloutFrame)
        
     
        view.isDraggable = true
        
        return view
    }
    
    private var pinViewSelected: MKPointAnnotation!
    private var pinView: MKAnnotationView!
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        pinViewSelected = view.annotation as? MKPointAnnotation
        pinView = view
//        if usingMode == op.recording {
//            mapView.deselectAnnotation(view.annotation, animated: false)
//            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
//        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            print("you tapped left callout")
        } else if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
        }
    }
    
    var polyColor: UIColor = UIColor.red
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.yellow.withAlphaComponent(0.2)
            return circleRenderer
        } else  if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = polyColor
            renderer.lineWidth = 1
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.strokeColor = polyColor
            renderer.lineWidth = 1
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    private func region(withPins region2D: CKRecord) -> CLCircularRegion {
        let longitude = region2D.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = region2D.object(forKey:  Constants.Attribute.latitude) as? Double
        let name = region2D.object(forKey:  Constants.Attribute.name) as? String
        let r2DCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude:longitude!)
        let maxDistance = locationManager?.maximumRegionMonitoringDistance
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Monitoring available")
        }
        
        let region = CLCircularRegion(center: r2DCoordinates, radius: CLLocationDistance(Constants.Variable.radius), identifier: name!)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
    
    func addRadiusOverlay(forGeotification region2D: CKRecord) {
        let longitude = region2D.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = region2D.object(forKey:  Constants.Attribute.latitude) as? Double
       
        let r2DCoordinates = CLLocationCoordinate2D(latitude: latitude!, longitude:longitude!)
        DispatchQueue.main.async {
            self.mapView?.add(MKCircle(center: r2DCoordinates, radius: CLLocationDistance(Constants.Variable.radius)))
        }
    }
    
    // MARK: UIAlertController + iCloud code
    
    var linksRecord: CKReference!
    var mapRecord: CKRecord!

    var recordZoneID: CKRecordZoneID!
    var recordID: CKRecordID!
    
    @IBAction func newMap(_ sender: UIBarButtonItem) {
        usingMode = op.recording
        let alert = UIAlertController(title: "Map Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Map Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
            if textField?.text != "" {
                let _ = self.listAllZones()
                if zoneTable[(textField?.text)!] != nil {
                    self.share2Load(zoneNamed: (textField?.text)!)
                    if listOfPoint2Seek.count == 0 {
                        // if you have no records in a zone, you need to go get the zone
                        self.zoneRecord2Load(zoneNamed: (textField?.text)!)
                    }
                } else {
                    recordZone = CKRecordZone(zoneName: (textField?.text)!)
                    self.privateDB.save(recordZone, completionHandler: ({returnRecord, error in
                        if error != nil {
                            // Zone creation failed
                            print("Cloud privateDB Error\n\(error?.localizedDescription.debugDescription)")
                        } else {
                            // Zone creation succeeded
                            print("The 'privateDB LeZone' was successfully created in the private database.")
                        }
                    }))
                        let operation = CKFetchRecordZonesOperation(recordZoneIDs: [recordZone.zoneID])
                        operation.fetchRecordZonesCompletionBlock = { _, error in
                            if error != nil {
                                print(error?.localizedDescription.debugDescription)
                            }
                            self.doshare(rexShared: nil)
                    }
                    self.privateDB.add(operation)
                }
            }
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: CloudSharing delegate
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print(error)
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return recordZone.zoneID.zoneName
    }
    
    func itemThumbnailData(for: UICloudSharingController) -> Data? {
        return nil
    }
    
    // MARK: iCloudKit
    
    private var _ckWayPointRecord: CKRecord? {
        didSet {
            
        }
    }
    
    var ckWayPointRecord: CKRecord {
        get {
            if _ckWayPointRecord == nil {
                _ckWayPointRecord = CKRecord(recordType: Constants.Entity.wayPoints )
            }
            return _ckWayPointRecord!
        }
        set {
            _ckWayPointRecord = newValue
        }
    }
    
    private let privateDB = CKContainer.default().privateCloudDatabase
    private let sharedDB = CKContainer.default().sharedCloudDatabase
    private var operationQueue = OperationQueue()
    private var sharingApp = false
    private var records2Share:[CKRecord] = []
    private var sharePoint: CKRecord!
    
    func save2Cloud(rex2S:[wayPoint]?, rex2D:[CKRecordID]?, sharing: Bool) {
        if recordZone == nil {
            newMap(UIBarButtonItem())
            return
        }
        sharingApp = true
        
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.waitUntilAllOperationsAreFinished()
        
//        var rec2Save:[CKRecord] = []
//        print("fcuk26062018 listOfPoint2Save \(listOfPoint2Save)")
        var p2S = 0
        
//        for point2Save in listOfPoint2Save! {
        for point2Save in rex2S! {
            print("fcuk02072018 challenge \(point2Save.challenge)")
//            let operation1 = BlockOperation {
            
                let ckWayPointRecord = CKRecord(recordType: Constants.Entity.wayPoints, zoneID: recordZone.zoneID)
                ckWayPointRecord.setObject(point2Save.coordinates?.longitude as CKRecordValue?, forKey: Constants.Attribute.longitude)
                ckWayPointRecord.setObject(point2Save.coordinates?.latitude as CKRecordValue?, forKey: Constants.Attribute.latitude)
                ckWayPointRecord.setObject(point2Save.name as CKRecordValue?, forKey: Constants.Attribute.name)
                ckWayPointRecord.setObject(point2Save.hint as CKRecordValue?, forKey: Constants.Attribute.hint)
                ckWayPointRecord.setObject(point2Save.boxes as CKRecordValue?, forKey:  Constants.Attribute.boxes)
                ckWayPointRecord.setObject(point2Save.major as CKRecordValue?, forKey:  Constants.Attribute.major)
                ckWayPointRecord.setObject(point2Save.minor as CKRecordValue?, forKey:  Constants.Attribute.minor)
                ckWayPointRecord.setObject(point2Save.UUID as CKRecordValue?, forKey: Constants.Attribute.UUID)
                ckWayPointRecord.setObject(point2Save.challenge as CKRecordValue?, forKey: Constants.Attribute.challenge)
                ckWayPointRecord.setObject(point2Save.URL as CKRecordValue?, forKey: Constants.Attribute.URL)
                ckWayPointRecord.setObject(p2S as CKRecordValue?, forKey: Constants.Attribute.order)
                ckWayPointRecord.setParent(sharePoint)
                p2S += 1
//                ckWayPointRecord.setParent(self.mapRecord)
            var image2D: Data!
            if point2Save.image != nil {
                image2D = UIImageJPEGRepresentation((point2Save.image!), 1.0)
            } else {
                image2D = UIImageJPEGRepresentation(UIImage(named: "noun_1348715_cc")!, 1.0)
            }
            if let _ = point2Save.name {
                let file2ShareURL = documentsDirectoryURL.appendingPathComponent(point2Save.name!)
                try? image2D?.write(to: file2ShareURL, options: .atomicWrite)
                let newAsset = CKAsset(fileURL: file2ShareURL)
                ckWayPointRecord.setObject(newAsset as CKAsset?, forKey: Constants.Attribute.imageData)
           }
             self.records2Share.append(ckWayPointRecord)
        }
        
        let modifyOp = CKModifyRecordsOperation(recordsToSave:
            records2Share, recordIDsToDelete: rex2D)
        modifyOp.savePolicy = .ifServerRecordUnchanged
        modifyOp.perRecordCompletionBlock = {(record,error) in
            print("error \(error.debugDescription)")
        }
        modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
            error) in
            if error != nil {
                print("error \(error.debugDescription)")
            }
//            self.doshare(rexShared: record!)
            if sharing {
                self.sharing(record2S: self.sharePoint)
            }
        }
        
        self.privateDB.add(modifyOp)
    }
        
        // new code added for parent setup 2nd try
    func doshare(rexShared: [CKRecord]?) {
        
//        if listOfPoint2Seek.count == 0 {
            sharePoint = CKRecord(recordType: Constants.Entity.mapLinks, zoneID: recordZone.zoneID)
            parentID = CKReference(record: self.sharePoint, action: .none)
//        }
        var recordID2Share:[CKReference] = []
        
//        for rex in self.records2Share {
////            let parentR = CKReference(record: self.parentID, action: .none)
//            rex.parent = parentID
//            let childR = CKReference(record: rex, action: .deleteSelf)
//            recordID2Share.append(childR)
//        }
        
        sharePoint.setObject(recordZone.zoneID.zoneName as CKRecordValue, forKey: Constants.Attribute.mapName)
//        sharePoint.setObject(recordID2Share as CKRecordValue, forKey: Constants.Attribute.wayPointsArray)
        privateDB.save(sharePoint) { (savedRecord, error) in
            if error != nil {
                print("error \(error.debugDescription)")
            }
        
            let modifyOp = CKModifyRecordsOperation(recordsToSave:
                self.records2Share, recordIDsToDelete: nil)
            modifyOp.savePolicy = .changedKeys
            modifyOp.perRecordCompletionBlock = {(record,error) in
                print("error \(error.debugDescription)")
            }
            modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                error) in
                if error != nil {
                    print("error \(error.debugDescription)")
                }
//                self.sharing(record2S: self.sharePoint)
            }
            self.privateDB.add(modifyOp)
        }
        return
    }
    
    //       let file2ShareURL = documentsDirectoryURL.appendingPathComponent("image2SaveX")
    //        if listOfPoint2Seek.count != wayPoints.count {
    //            listOfPoint2Save = Array(wayPoints.values.map{ $0 })
    //        }
    
    //        self.recordZone = CKRecordZone(zoneName: "LeZone")
    //        CKContainer.default().discoverAllIdentities { (users, error) in
    //            print("identities \(users) \(error)")
    //        }
    //
    //        CKContainer.default().discoverUserIdentity(withEmailAddress:"mark.lucking@gmail.com") { (id,error ) in
    //            print("identities \(id.debugDescription) \(error)")
    //            self.userID = id!
    //        }
        
    func sharing(record2S: CKRecord) {
        
//        let record2S = records2Share.first!
//        let record2S = self.sharePoint
        
        let share = CKShare(rootRecord: record2S)
                    share[CKShareTitleKey] = "My Next Share" as CKRecordValue
                    share.publicPermission = .none
            
            DispatchQueue.main.async {
                    let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
                        @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                        let modifyOp = CKModifyRecordsOperation(recordsToSave:
                            [record2S, share], recordIDsToDelete: nil)
                        modifyOp.savePolicy = .allKeys
                        modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
                            error) in
                            handler(share, CKContainer.default(), error)
                        }
                        CKContainer.default().privateCloudDatabase.add(modifyOp)
                    })
                    sharingController.availablePermissions = [.allowReadWrite,
                                                              .allowPrivate]
                    sharingController.delegate = self
                    sharingController.popoverPresentationController?.sourceView = self.view
            
                    self.present(sharingController, animated:true, completion:nil)
                }
        }
    
        
    @IBAction func FetchShare(_ sender: Any) {
        getShare()
    }
    
    @IBAction func saveB(_ sender: Any) {
        saveImage()
    }
    
    
    
    func getParticipant() {
//        CKContainer.default().discoverAllIdentities { (identities, error) in
//            print("identities \(identities.debugDescription)")
//        }
    }
//
//    private var userID: CKUserIdentity!
//
    
    var nextLocation: CLLocationCoordinate2D!
    var angle2U: Double? = nil
    
func getShare() {
        usingMode = op.playing
        windowView = .points
        mapView.alpha = 0.7
        listOfPoint2Seek = []
        centerImage.image = UIImage(named: "compassClip")
    if currentZone == nil {
        let alert = UIAlertController(title: "Map Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Map Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                self.share2Load(zoneNamed: (textField?.text)!)
                self.zoneRecord2Load(zoneNamed: (textField?.text)!)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    }
    
    func share2Source(zoneID: CKRecordZoneID?) {
        windowView = .points
        DispatchQueue.main.async {
            self.mapView.alpha = 0.7
            listOfPoint2Seek = []
            self.centerImage.image = UIImage(named: "compassClip")
        }
        recordZoneID = zoneID
        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "owningList == %@", recordZoneID)
        //        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        sharedDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(error)")
            }
            for record in records! {
                print("fcuk26062018 record \(record)")
                self.buildWaypoint(record2U: record)
                
            
            }
        }
        
        let when = DispatchTime.now() + Double(2)
        DispatchQueue.main.asyncAfter(deadline: when){
            self.spinner.stopAnimating()
            for points in listOfPoint2Seek {
                let long = self.getLocationDegreesFrom(longitude: (points.coordinates?.longitude)!)
                let lat = self.getLocationDegreesFrom(longitude: (points.coordinates?.latitude)!)
                
            }
            self.lowLabel.isHidden = false
            self.highLabel.isHidden = false
            self.nextLocation2Show()
        }
    }
    
    func zoneRecord2Load(zoneNamed: String?) {
        recordZone = CKRecordZone(zoneName: zoneNamed!)
        recordZoneID = recordZone.zoneID
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "mapLinks", predicate: predicate)
        privateDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(error)")
            }
            for record in records! {
                print("fcuk26062018 record \(record)")
                // there is always only a single record here!!
                self.sharePoint = record
            }
        }
    }
    
    func share2Load(zoneNamed: String?) {
        print("fcuk03072018 \(zoneNamed)")
            recordZone = CKRecordZone(zoneName: zoneNamed!)
            recordZoneID = recordZone.zoneID
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        privateDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(error)")
            }
            for record in records! {
                print("fcuk26062018 record \(record)")
                self.buildWaypoint(record2U: record)
            }
            
            
        }
    
    let when = DispatchTime.now() + Double(4)
    DispatchQueue.main.asyncAfter(deadline: when){
            self.countLabel.text  = String(listOfPoint2Seek.count)
//        for points in listOfPoint2Seek {
//            let long = self.getLocationDegreesFrom(longitude: (points.coordinates?.longitude)!)
//            let lat = self.getLocationDegreesFrom(longitude: (points.coordinates?.latitude)!)
//            print("listOfPoint2Seek \(long) \(lat)")
//        }
        self.lowLabel.isHidden = false
        self.highLabel.isHidden = false
        self.nextLocation2Show()
    }
    
        
    
    
//        let predicate = NSPredicate(format: "owningList == %@", recordID)
//        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
//
//        shareDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
//            print("mine record \(records.debugDescription) and error \(error.debugDescription)")
//        }
    }
    
    private func buildWaypoint(record2U: CKRecord) {

        let longitude = record2U.object(forKey:  Constants.Attribute.longitude) as? Double
        let latitude = record2U.object(forKey:  Constants.Attribute.latitude) as? Double
        let major = record2U.object(forKey: Constants.Attribute.major) as? Int
        let minor = record2U.object(forKey: Constants.Attribute.minor) as? Int
        globalUUID = record2U.object(forKey: Constants.Attribute.UUID) as? String

            parentID = record2U.parent
            let url2U = record2U.object(forKey: Constants.Attribute.URL) as? String
            let name = record2U.object(forKey:  Constants.Attribute.name) as? String
            let hint = record2U.object(forKey:  Constants.Attribute.hint) as? String
            let order = record2U.object(forKey:  Constants.Attribute.order) as? Int
            let boxes = record2U.object(forKey: Constants.Attribute.boxes) as? [CLLocation]
            let challenge = record2U.object(forKey: Constants.Attribute.challenge) as? String
            let file : CKAsset? = record2U.object(forKey: Constants.Attribute.imageData) as? CKAsset
            var image2D: UIImage!
            if let data = NSData(contentsOf: (file?.fileURL)!) {
                image2D = UIImage(data: data as Data)
            }
            if major == nil {
                let wp2S = wayPoint(recordID: record2U.recordID, UUID: nil, major:major, minor: minor, proximity: nil, coordinates: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), name: name, hint: hint, image: image2D, order: order, boxes: boxes, challenge: challenge, URL: url2U)
                 listOfPoint2Seek.append(wp2S)
            } else {
                let wp2S = wayPoint(recordID: record2U.recordID,UUID: globalUUID, major:major, minor: minor, proximity: nil, coordinates: nil, name: name, hint: hint, image: image2D, order: order, boxes: nil, challenge: challenge, URL: url2U)
                listOfPoint2Seek.append(wp2S)
                // set this just in case you want to define more ibeacons
                let k2U = String(minor!) + String(major!)
                beaconsInTheBag[k2U] = true
                WP2M[k2U] = name
            }
            self.plotPin(pin2P: record2U)
//            let region2M = self.region(withPins: record2U)
//            self.addRadiusOverlay(forGeotification: record2U)
//            self.locationManager?.startMonitoring(for: region2M)
           
            DispatchQueue.main.async {
                if boxes != nil {
                    for boxes2D in boxes! {
//                        self.drawBox(Cords2E: boxes2D.coordinate, boxColor: UIColor.red)
                        let wp2FLat = self.getLocationDegreesFrom(latitude: latitude!)
                        let wp2FLog = self.getLocationDegreesFrom(longitude: longitude!)
                        WP2M[wp2FLat+wp2FLog] = name
                    }
                }
        }
    }
    
    private func nextLocation2Show() {
        
        if order2Search == 0, usingMode == op.playing {
            // do splash
        }
        if order2Search! < listOfPoint2Seek.count, usingMode == op.playing {
            let nextWP2S = listOfPoint2Seek[(order2Search!)]
            print("nextWP2S nextWP2S.UUID \(nextWP2S.UUID)")
            if nextWP2S.UUID == nil {
                self.longitudeNextLabel.text = self.getLocationDegreesFrom(longitude: (nextWP2S.coordinates?.longitude)!)
                self.latitudeNextLabel.text = self.getLocationDegreesFrom(latitude: (nextWP2S.coordinates?.latitude)!)
                self.nextLocation = CLLocationCoordinate2DMake((nextWP2S.coordinates?.latitude)!, (nextWP2S.coordinates?.longitude)!)
                self.angle2U = self.getBearing(toPoint: self.nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
                self.hintLabel.text = nextWP2S.hint
                self.nameLabel.text = nextWP2S.name
                self.hintLabel.isHidden = false
                self.nameLabel.isHidden = false
                self.latitudeNextLabel.isHidden = false
                self.longitudeNextLabel.isHidden = false
                self.highLabel.text = "[You need to be here]"
                self.centerImage.image = UIImage(named: "compassClip")
            } else {
                    // you have a beacon record
                    self.centerImage.image = UIImage(named: "ibeacon-logo")
                    self.hintLabel.text = nextWP2S.hint
                    self.nameLabel.text = nextWP2S.name
                    self.hintLabel.isHidden = false
                    self.nameLabel.isHidden = false
                    self.latitudeNextLabel.isHidden = true
                    self.longitudeNextLabel.isHidden = true
                    self.highLabel.text = "<You need to search>"
                }
        } else {
            // do finale
        }
    }
    // MARK: Saving to the iPad as JSON
    
    func saveImage() {
//        if listOfPoint2Seek.count != wayPoints.count {
//            listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
//        }
        print("listOfPoint2Seek \(listOfPoint2Seek)")
        var w2GA:[way2G] = []
        for ways in listOfPoint2Seek {
            let w2G = way2G(longitude: (ways.coordinates?.longitude)!, latitude: (ways.coordinates?.latitude)!, name: ways.name!, hint: ways.hint!, imageURL: URL(string: "http://")!)
            w2GA.append(w2G)
        }
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(w2GA) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let file2ShareURL = documentsDirectoryURL.appendingPathComponent("config.n2khunt")
                    do {
                        try jsonString.write(to: file2ShareURL, atomically: false, encoding: .utf8)
                    } catch {
                        print(error)
                    }
                    
                    do {
                        let _ = try Data(contentsOf: file2ShareURL)
                        let activityViewController = UIActivityViewController(activityItems: [file2ShareURL], applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    } catch {
                        print("unable to read")
                    }
            }
        }
    }
}
    
    @IBAction func ShareButton2(_ sender: UIBarButtonItem) {
        save2Cloud(rex2S: listOfPoint2Save, rex2D: nil, sharing: true)
        
//        saveImage()
    }
     
     // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        let annotationView = sender as? MKAnnotationView
        if segue.identifier == Constants.EditUserWaypoint, trigger == point.gps {
            let ewvc = destination as? EditWaypointController
//            wayPoints.removeValue(forKey: ((pinViewSelected?.title)!)!)
            ewvc?.nameText = (pinViewSelected?.title)!
            ewvc?.hintText = (pinViewSelected?.subtitle)!
            ewvc?.me = self
            if let _ = wayPoints[(pinViewSelected?.title)!] {
                    ewvc?.challengeText = (wayPoints[(pinViewSelected?.title)!]?.challenge)
            }
            ewvc?.setWayPoint = self
                if let ppc = ewvc?.popoverPresentationController {
                    ppc.sourceRect = (annotationView?.frame)!
                    ppc.delegate = self
                }
        }
        if segue.identifier == Constants.EditUserWaypoint, trigger == point.ibeacon {
            let ewvc = destination as? EditWaypointController
            let uniqueName = "UUID".madeUnique(withRespectTo: beaconsLogged)
            ewvc?.nameText =  uniqueName
            ewvc?.hintText = "ibeacon"
            ewvc?.setWayPoint = self
             ewvc?.me = self
            if let ppc = ewvc?.popoverPresentationController {
                let point2U = mapView.convert( (locationManager?.location?.coordinate)!, toPointTo: mapView)
                ppc.sourceRect = CGRect(x: point2U.x, y: point2U.y, width: 1, height: 1)
                ppc.delegate = self
            }
        }
        if segue.identifier == Constants.TableWaypoint {
            let tbvc = destination as?  HideTableViewController
            tbvc?.zapperDelegate = self
            tbvc?.save2CloudDelegate = self
            tbvc?.table2MapDelegate = self
        }
        if segue.identifier == Constants.ScannerViewController {
            let svc = destination as? ScannerViewController
            svc?.firstViewController = self
        }
        if segue.identifier == Constants.ShowImageSegue {
            let svc = destination as? ImageViewController
            let nextWP2S = listOfPoint2Seek[order2Search!]
            if nextWP2S.image != nil {
                svc?.image2S = nextWP2S.image
                svc?.challenge2A = nextWP2S.challenge
            }
            svc?.callingViewController = self
        }
        if segue.identifier == Constants.WebViewController {
            let svc = destination as? WebViewController
            svc?.secondViewController = self
            svc?.nameOfNode = (pinViewSelected?.title)!
        }
    }
    
    private func updateHint(waypoint2U: MKPointAnnotation, hint: String?) {
        if hint != nil {
            let wp2Fix = wayPoints.filter { (arg) -> Bool in
                let (_, value2U) = arg
                return value2U.name == waypoint2U.title
            }
            let wp2F = wp2Fix.values.first
            let waypoint2A = wayPoint(recordID: wp2F?.recordID, UUID: wp2F?.UUID, major:wp2F?.major, minor: wp2F?.minor,proximity: nil, coordinates: waypoint2U.coordinate, name: wp2F?.name, hint: hint, image: wp2F?.image, order: wayPoints.count, boxes:wp2F?.boxes, challenge: wp2F?.challenge, URL: wp2F?.URL)
            wayPoints[waypoint2U.title!] = waypoint2A
        }
    }
    
    private func updateURL(waypoint2U: MKPointAnnotation, URL: String?) {
        if  URL != nil {
            let wp2Fix = wayPoints.filter { (arg) -> Bool in
                let (_, value2U) = arg
                return value2U.name == waypoint2U.title
            }
            print("fcuk29062018 updateURL \(wp2Fix)")
            let wp2F = wp2Fix.values.first
            let waypoint2A = wayPoint(recordID: wp2F?.recordID, UUID: wp2F?.UUID, major:wp2F?.major, minor: wp2F?.minor,proximity: nil, coordinates: waypoint2U.coordinate, name: wp2F?.name, hint: wp2F?.hint, image: wp2F?.image, order: wayPoints.count, boxes:wp2F?.boxes, challenge: wp2F?.challenge,URL: URL)
            wayPoints[waypoint2U.title!] = waypoint2A
            print("fcuk29062018 updateURL \(waypoint2A)")
        }
    }
    
    private func updateChallenge(waypoint2U: MKPointAnnotation, challenge: String?) {
        print("fcuk29062016 updateChallenge wayPoints \(waypoint2U.title)")
        if challenge != nil {
            let wp2Fix = wayPoints.filter { (arg) -> Bool in
                let (_, value2U) = arg
                print("fcuk29062018 updateChallenge \(arg)")
                return value2U.name == waypoint2U.title
            }
        print("fcuk29062018 updateChallenge \(wp2Fix)")
        let wp2F = wp2Fix.values.first
        let waypoint2A = wayPoint(recordID: wp2F?.recordID, UUID: wp2F?.UUID, major:wp2F?.major, minor: wp2F?.minor,proximity: nil, coordinates: waypoint2U.coordinate, name: wp2F?.name, hint: wp2F?.hint, image: wp2F?.image, order: wayPoints.count, boxes:wp2F?.boxes, challenge: challenge,URL: wp2F?.URL)
            wayPoints[waypoint2U.title!] = waypoint2A
            print("fcuk29062018 updateChallenge \(waypoint2A)")
        }
        
    }
    
    private func updateName(waypoint2U: MKPointAnnotation, name2D: String) {
        if name2D != nil {
            let wp2Fix = wayPoints.filter { (arg) -> Bool in
                let (_, value2U) = arg
                return value2U.name == waypoint2U.title
            }
            let wp2F = wp2Fix.values.first
            print("fcuk29062018 updateName \(wp2F) \(waypoint2U.title)")
            let waypoint2A = wayPoint(recordID: wp2F?.recordID, UUID: wp2F?.UUID, major:wp2F?.major, minor: wp2F?.minor,proximity: nil, coordinates: waypoint2U.coordinate, name: name2D, hint: wp2F?.hint, image: wp2F?.image, order: wayPoints.count, boxes:wp2F?.boxes, challenge: wp2F?.challenge, URL: wp2F?.URL)
            wayPoints[name2D] = waypoint2A
//            wayPoints.removeValue(forKey: ((pinViewSelected?.title)!)!)
            pinViewSelected?.title = name2D
        }
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            trigger = point.gps
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let wayNames = Array(wayPoints.keys)
            let uniqueName = "GPS".madeUnique(withRespectTo: wayNames)
//           let waypoint2 = MKPointAnnotation()
            let waypoint2 = MyPointAnnotation()
          waypoint2.coordinate  = coordinate
          waypoint2.title = uniqueName
//            waypoint2.tintColor = .purple
            let wp2FLat = self.getLocationDegreesFrom(latitude: coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: coordinate.longitude)
          waypoint2.subtitle = wp2FLat + wp2FLog
//            updateWayname(waypoint2U: waypoint2, image2U: nil)
            
            let hint2D = wp2FLat + wp2FLog

            DispatchQueue.main.async() {
                self.mapView.addAnnotation(waypoint2)
//                self.doBox(latitude2S: wp2FLat, longitude2S: wp2FLog)
                let boxes = self.doBoxV2(latitude2D: coordinate.latitude, longitude2D: coordinate.longitude, name: uniqueName)
                var box2F:[CLLocation] = []
                for box in boxes {
                    box2F.append(CLLocation(latitude: box.coordinate.latitude, longitude: box.coordinate.longitude))
                }
                let newWayPoint = wayPoint(recordID: nil, UUID: nil, major:nil, minor: nil, proximity: nil, coordinates: coordinate, name: uniqueName, hint:hint2D, image: nil, order: wayPoints.count, boxes: box2F, challenge: nil, URL: nil)
                wayPoints[uniqueName] = newWayPoint
                print("fcuk29062018 \(wayPoints) \(uniqueName)")
                listOfPoint2Save?.append(newWayPoint)
            }
        }
    }
    
    // MARK: Popover Delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        // code
    }
    
     @IBOutlet weak var hideView: HideView!
    private var pinObserver: NSObjectProtocol!
    private var regionObserver: NSObjectProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let when = DispatchTime.now() + Double(8)
        DispatchQueue.main.asyncAfter(deadline: when){
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.currentLocation!.coordinate.latitude, self.currentLocation!.coordinate.longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation, span)
            self.mapView.setRegion(region, animated: true)
            self.regionHasBeenCentered = true
            
            
        }

        let center = NotificationCenter.default
        let queue = OperationQueue.main
        var alert2Monitor = "regionEvent"
        regionObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
             let message2N = notification.userInfo!["region"] as? String
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Monitoring", message:  "\(message2N!)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
         alert2Monitor = "showPin"
        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
             let record2O = notification.userInfo!["pin"] as? CKShareMetadata
            if record2O != nil {
//                self.queryShare(record2O!)
                self.fetchParent(record2O!)
            }
        }
//        for family: String in UIFont.familyNames
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNames(forFamilyName: family)
//            {
//                print("== \(names)")
//            }
//        }
        highLabel.isHidden = true
        lowLabel.isHidden = true
    }
    
    // MARK: // StarStrella
    
    var spinner: UIActivityIndicatorView!
    
    func fetchParent(_ metadata: CKShareMetadata) {
        recordZoneID = metadata.share.recordID.zoneID
        recordID = metadata.share.recordID
        let record2S =  [metadata.rootRecordID].last
        DispatchQueue.main.async() {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating()
        }
        share2Source(zoneID: recordZoneID)
        
//        let operation = CKFetchRecordsOperation(recordIDs: [recordID])
//        operation.perRecordCompletionBlock = { record, _, error in
//            if error != nil {
//                print(error?.localizedDescription.debugDescription)
//            }
//            if record != nil {
//                let name2S = record?.object(forKey: Constants.Attribute.mapName) as? String
//                DispatchQueue.main.async() {
//                    self.navigationItem.title = name2S
//                }
//                DispatchQueue.main.async() {
//                    let pins2Plot = record?.object(forKey: Constants.Attribute.wayPointsArray) as? Array<CKReference>
//                    self.queryShare(record2S: pins2Plot!)
//                }
//                }
//            }
//        sharedDB.add(operation)
    }
    
    func queryShare(record2S: [CKReference]) {
        var pinID:[CKRecordID] = []
        for pins in record2S {
            pinID.append(pins.recordID)
        }
        let operation = CKFetchRecordsOperation(recordIDs: pinID)
        operation.perRecordCompletionBlock = { record, _, error in
            if error != nil {
                print(error?.localizedDescription)
            }
            if record != nil {
                DispatchQueue.main.async() {
                    self.plotPin(pin2P: record!)
                }
//                let region2M = self.region(withPins: record!)
//                self.locationManager?.startUpdatingLocation()
//                self.locationManager?.startUpdatingHeading()
//                self.locationManager?.startMonitoring(for: region2M)
//                self.locationManager.startMonitoringVisits()
            }
        }
        operation.fetchRecordsCompletionBlock = { _, error in
            if error != nil {
                print(error?.localizedDescription.debugDescription)
            }
            DispatchQueue.main.async() {
                self.spinner.stopAnimating()
                self.spinner.removeFromSuperview()
            }
        }
        CKContainer.default().sharedCloudDatabase.add(operation)
    }
    
    private func plotPin(pin2P: CKRecord) {
        let UUID = pin2P.object(forKey:  Constants.Attribute.UUID) as? String
        if UUID == nil {
        DispatchQueue.main.async() {
            let longitude = pin2P.object(forKey:  Constants.Attribute.longitude) as? Double
            let latitude = pin2P.object(forKey:  Constants.Attribute.latitude) as? Double
            let name = pin2P.object(forKey:  Constants.Attribute.name) as? String
            let order = pin2P.object(forKey:  Constants.Attribute.order) as? Int
            let wp2FLat = self.getLocationDegreesFrom(latitude: latitude!)
            let wp2FLog = self.getLocationDegreesFrom(longitude: longitude!)
            let hint2D = String(order!) + ":" + wp2FLat + wp2FLog
//            let hint = pin2P.object(forKey:  Constants.Attribute.hint) as? String
            let file : CKAsset? = pin2P.object(forKey: Constants.Attribute.imageData) as? CKAsset
            let waypoint = MKPointAnnotation()
            waypoint.coordinate  = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            waypoint.title = name
            waypoint.subtitle = hint2D
           
            if let data = NSData(contentsOf: (file?.fileURL)!) {
                let image2D = UIImage(data: data as Data)
                 self.mapView.addAnnotation(waypoint)
                self.pinViewSelected = waypoint
                self.mapView.selectAnnotation(self.pinViewSelected!, animated: true)
//                self.didSetImage(name: self.pinViewSelected.title, image: image2D)
//                self.updateWayname(waypoint2U: waypoint, image2U: image2D)
                self.mapView.deselectAnnotation(waypoint, animated: false)
            } else {
                self.mapView.addAnnotation(waypoint)
            }
        }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
         let center = NotificationCenter.default
        if pinObserver != nil {
            center.removeObserver(pinObserver)
        }
        if regionObserver != nil {
            center.removeObserver(regionObserver)
        }
    }

    override func viewDidLoad() {
        trigger = point.gps
        centerImage.alpha = 0.5
        directionLabel.isHidden = true
        nameLabel.isHidden = true
        hintLabel.isHidden = true
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: {status, error in
            print("error \(error.debugDescription)")
        })
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.activityType = CLActivityType.fitness
        locationManager?.allowsBackgroundLocationUpdates
        locationManager?.requestLocation()
        pin.isEnabled = true
        _ = self.listAllZones()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // do something
        return traitCollection.horizontalSizeClass == .compact ? UIModalPresentationStyle.overFullScreen : .none
    }
    
    @objc func byebye() {
//        self.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: {
            // code
        })
    }
  
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        
        if style == .fullScreen || style == .overFullScreen {
            let navcon = UINavigationController(rootViewController: controller.presentedViewController)
//            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//            visualEffectView.frame = navcon.view.bounds
//            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            visualEffectView.backgroundColor = UIColor.clear
//            navcon.view.insertSubview(visualEffectView, at: 0)
            
            let maskView = UIView()
            maskView.backgroundColor = UIColor(white: 1,  alpha: 0.5) //you can modify this to whatever you need
            maskView.frame = navcon.view.bounds
            maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navcon.view.insertSubview(maskView, at: 0)
             let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(byebye))
            controller.presentedViewController.navigationItem.rightBarButtonItem = rightBarButton
            return navcon
        } else {
            return nil
        }
    }
    
    
    // MARK: Constants
    
    private struct axis {
        static let longitude = 0
        static let latitude =  1
    }
    
    private struct size2U {
        static let min = 0
        static let max = 1
    }
    
    private struct corners {
        static let northEast = 0
        static let southEast = 1
        static let southWest = 3
        static let northWest = 4
    }
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
        static let TableWaypoint = "Table Waypoint"
        static let ScannerViewController = "Scan VC"
        static let WebViewController = "WebViewController"
       
        
        struct Entity {
            static let wayPoints = "wayPoints"
            static let mapLinks = "mapLinks"
        }
        struct Attribute {
            static let UUID = "UUID"
            static let minor = "minor"
            static let major = "major"
            static let proximity = "proximity"
            static let longitude = "longitude"
            static let  latitude = "latitude"
            static let  name = "name"
            static let hint = "hint"
            static let order = "order"
            static let  imageData = "image"
            static let mapName = "mapName"
            static let linkReference = "linkReference"
            static let wayPointsArray = "wayPointsArray"
            static let boxes = "boxes"
            static let challenge = "challenge"
            static let URL = "URL"
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }
}


