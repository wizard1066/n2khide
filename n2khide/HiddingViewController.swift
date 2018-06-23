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



class HiddingViewController: UIViewController, UIDropInteractionDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, setWayPoint, zap, UICloudSharingControllerDelegate, showPoint, CLLocationManagerDelegate {
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
    @IBOutlet weak var debug2: UILabel!
    @IBOutlet weak var debug1: UILabel!
    @IBOutlet weak var debug3: UILabel!
    @IBOutlet weak var debug4: UITextView!
    
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
        let pin = MyPointAnnotation()
        pin.coordinate  = cord2D
        pin.title = title
        mapView.addAnnotation(pin)
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
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        var shouldHideBeaconDetails = true

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
                    print("Beacon Major = \(closestBeacon.major.intValue) \nMinor \(closestBeacon.minor.intValue) Distance: \(proximityMessage)")
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
    
    func getLocationDegreesFromV2(latitude: Double, longitude: Double) -> (latitude: String, longitude: String) {
        var latitudeSeconds = latitude * 3600
    
    let latitudeDegrees = latitudeSeconds / 3600
    
    latitudeSeconds = latitudeSeconds.truncatingRemainder(dividingBy: 3600)
    
    let latitudeMinutes = latitudeSeconds / 60
    
    latitudeSeconds = latitudeSeconds.truncatingRemainder(dividingBy: 60)
    
    // Calculating the degrees, minutes and seconds for the given longitude value (DD)
    
    var longitudeSeconds = longitude * 3600
    
    let longitudeDegrees = longitudeSeconds / 3600
    
    longitudeSeconds = longitudeSeconds.truncatingRemainder(dividingBy: 3600)
    
    let longitudeMinutes = longitudeSeconds / 60
    
    longitudeSeconds = longitudeSeconds.truncatingRemainder(dividingBy: 60)
    
    // Analyzing if it's North or South. (Latitude)
    
    let latitudeCardinalDirection = latitudeDegrees >= 0 ? "N" : "S"
    
    // Analyzing if it's East or West. (Longitude)
    
    let longitudeCardinalDirection = longitudeDegrees >= 0 ? "E" : "W"
    
    // Final strings with format <degrees>°<minutes>'<seconds>"<cardinal direction>
    
//    let latitudeDescription = String(format:"%.2f-%.2f-%.2f-%@",
      let latitudeDescription = String(format:"%.0f-%.0f-%.0f-%@",
                                     abs(latitudeDegrees), abs(latitudeMinutes),
                                     abs(latitudeSeconds), latitudeCardinalDirection)
    
//    let longitudeDescription = String(format:"%.2f-%.2f-%.2f-%@",
           let longitudeDescription = String(format:"%.0f-%.0f-%.0f-%@",
                                      abs(longitudeDegrees), abs(longitudeMinutes),
                                      abs(longitudeSeconds), longitudeCardinalDirection)
    return (latitudeDescription, longitudeDescription)

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
        orderLabel.text = String(order!)
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
            if listOfPoint2Seek.count > 0, order! <  listOfPoint2Seek.count {
                let nextWP2S = listOfPoint2Seek[order!]
                self.debug4.text = "\(WP2M)"
                if WP2M[latValue + longValue] != nil {
                    let  alert2Post = WP2M[latValue + longValue]
                    
                    if alert2Post == nextWP2S.name {
                        let alert = UIAlertController(title: "WP2M Triggered", message: alert2Post, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        let wayPointRec = wayPoints[alert2Post!]
//                        self.centerImage.image = wayPointRec?.image
                        let image2Show = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                        image2Show.image = wayPointRec?.image
                        self.mapView.addSubview(image2Show)
                        image2Show.translatesAutoresizingMaskIntoConstraints  = false
                        let THighConstraint = NSLayoutConstraint(item: image2Show, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 30)
                        let TLowConstraint = NSLayoutConstraint(item: image2Show, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
                        let TLeftConstraint = NSLayoutConstraint(item: image2Show, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
                        let TRightConstraint = NSLayoutConstraint(item: image2Show, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
                        self.view.addConstraints([THighConstraint,TLowConstraint,TLeftConstraint,TRightConstraint])
                        NSLayoutConstraint.activate([THighConstraint,TLowConstraint,TLeftConstraint,TRightConstraint])
                        self.hintLabel.text = wayPointRec?.hint
                        self.orderLabel.text = String(order!)
                        WP2M[latValue + longValue] = nil
                        order? += 1
                        UIView.animate(withDuration: 8, animations: {
                            image2Show.alpha = 0
                            self.hintLabel.alpha = 0
                        }, completion: { (result) in
                            image2Show.removeFromSuperview()
                            self.hintLabel.text = ""
                            self.hintLabel.alpha = 1
                            self.nextLocation2Show()
                        })
                    }
                }
            }
       }
        if angle2U != nil {
            self.angle2U = self.getBearing(toPoint: nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
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
    
    func wayPoint2G(wayPoint2G: String) {
        for wayP in mapView.annotations {
            if wayP.title == wayPoint2G {
                mapView.removeAnnotation(wayP)
            }
        }
    }
    
    // MARK: setWayPoint protocl implementation
    
    func didSetName(name: String?) {
         if pinViewSelected != nil, name != nil {
            pinViewSelected?.title = name
            mapView.selectAnnotation(pinViewSelected!, animated: true)
            updateWayname(waypoint2U: pinViewSelected, image2U: nil)
        }
    }
    
    func didSetHint(hint: String?) {
        if pinViewSelected != nil, hint != nil {
            pinViewSelected?.subtitle = hint
            mapView.selectAnnotation(pinViewSelected!, animated: true)
            updateWayname(waypoint2U: pinViewSelected, image2U: nil)
        }
    }
    
    func didSetImage(image: UIImage?) {
        if pinViewSelected != nil, image != nil {
            if let thumbButton = pinView.leftCalloutAccessoryView as? UIButton {
                thumbButton.setImage(image, for: .normal)
                mapView.selectAnnotation(pinViewSelected!, animated: true)
                updateWayname(waypoint2U: pinViewSelected, image2U: image)
            }
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
    
    private func convert2nB(latitude2D: Double, longitude2D:Double) -> CLLocationCoordinate2D {
//        let (latitudeDMS, longitudeDMS) = self.getLocationDegreesFromV2(latitude: latitude2D, longitude: longitude2D)
        let longValue =  self.getLocationDegreesFrom(longitude: (longitude2D))
        let latValue = self.getLocationDegreesFrom(latitude: (latitude2D))
//        print("fuck2--> long \(longValue) \(longitudeDMS) lat \(latValue) \(latitudeDMS)")
       let (latD, longD) = getDigitalFromDegrees(latitude: latValue, longitude: longValue)
        return CLLocationCoordinate2D(latitude: latD, longitude: longD)
    }
    
    private func drawBox(Cords2E: CLLocationCoordinate2D,  boxColor: UIColor) {
        var cords2D:[CLLocationCoordinate2D] = []
        let SWLatitude = Cords2E.latitude - Constants.Variable.magic
        let SWLongitude = Cords2E.longitude - Constants.Variable.magic
        var cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        //        doPin(cord2D: cord2U, title: "SW")
        cords2D.append(cord2U)
        let NWLatitude = Cords2E.latitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: SWLongitude)
        //        doPin(cord2D: cord2U, title: "NW")
        cords2D.append(cord2U)
        let NELongitude = Cords2E.longitude + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NELongitude)
//        doPin(cord2D: cord2U, title: "NE")
        cords2D.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: NELongitude)
        //        doPin(cord2D: cord2U, title: "SE")
        cords2D.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        cords2D.append(cord2U)
        let polyLine = MKPolyline(coordinates: &cords2D, count: cords2D.count)
        
        DispatchQueue.main.async {
            self.polyColor = boxColor
            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    private func doBoxV2(latitude2D: Double, longitude2D: Double) {
        var coordinates:[CLLocationCoordinate2D] = []
        var sector:[CLLocationCoordinate2D] = []
        
        
        if latitude2D + (Constants.Variable.magic/2)  > latitude2D {
            var cords2U = convert2nB(latitude2D: latitude2D + (Constants.Variable.magic*1.5), longitude2D: longitude2D)
            drawBox(Cords2E: cords2U, boxColor: UIColor.blue)
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D)
            drawBox(Cords2E: cords2U, boxColor: UIColor.orange)
//            print("fcuk greater than \(self.getLocationDegreesFrom(latitude: latitude2D + Constants.Variable.magic * 1.5))")
//            print("fcuk greater than \(self.getLocationDegreesFrom(latitude: latitude2D))")
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D)
            drawBox(Cords2E: cords2U, boxColor: UIColor.blue)
            cords2U = convert2nB(latitude2D: latitude2D - (Constants.Variable.magic * 1.5), longitude2D: longitude2D)
            drawBox(Cords2E: cords2U, boxColor: UIColor.orange)
//            print("fcuk less than \(self.getLocationDegreesFrom(latitude: latitude2D - Constants.Variable.magic * 1.5))")
//            print("fcuk less than \(self.getLocationDegreesFrom(latitude: latitude2D))")
        }
        if longitude2D + (Constants.Variable.magic/2) > longitude2D  {
            var cords2U = convert2nB(latitude2D: latitude2D + Constants.Variable.magic * 1.5, longitude2D: longitude2D + Constants.Variable.magic * 1.5)
            drawBox(Cords2E: cords2U, boxColor: UIColor.green)
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D + Constants.Variable.magic * 1.5)
            drawBox(Cords2E: cords2U, boxColor: UIColor.red)
        } else {
            var cords2U = convert2nB(latitude2D: latitude2D - Constants.Variable.magic * 1.5, longitude2D: longitude2D - Constants.Variable.magic * 1.5)
            drawBox(Cords2E: cords2U, boxColor: UIColor.green)
            cords2U = convert2nB(latitude2D: latitude2D, longitude2D: longitude2D - Constants.Variable.magic * 1.5)
            drawBox(Cords2E: cords2U, boxColor: UIColor.red)
        }
        
        let SWLatitude = latitude2D - Constants.Variable.magic
        let SWLongitude = longitude2D - Constants.Variable.magic
        var cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        let SW = cord2U
        sector.append(convert2nB(latitude2D: SWLatitude, longitude2D: SWLongitude))
//        doPin(cord2D: cord2U, title: "SW")
        coordinates.append(cord2U)
        let NWLatitude = latitude2D + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: SWLongitude)
        let NW = cord2U
        sector.append(convert2nB(latitude2D: NWLatitude, longitude2D: SWLongitude))
//        doPin(cord2D: cord2U, title: "NW")
        coordinates.append(cord2U)
        let NELongitude = longitude2D + Constants.Variable.magic
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NELongitude)
        let NE = cord2U
        sector.append(convert2nB(latitude2D: NWLatitude, longitude2D: NELongitude))
//        doPin(cord2D: cord2U, title: "NE")
        coordinates.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: NELongitude)
        let SE = cord2U
        sector.append(convert2nB(latitude2D: SWLatitude, longitude2D: NELongitude))
//        doPin(cord2D: cord2U, title: "SE")
        coordinates.append(cord2U)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        sector.append(convert2nB(latitude2D: SWLatitude, longitude2D: SWLongitude))
        coordinates.append(cord2U)
//        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
//        let polyLine2 = MKPolyline(coordinates: &sector, count: sector.count)
        
//        DispatchQueue.main.async {
//            self.polyColor = UIColor.red
////            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
//            self.polyColor = UIColor.blue
////            self.mapView.add(polyLine2, level: MKOverlayLevel.aboveRoads)
//            let point2M = MKMapPoint(x: NW.latitude, y: NW.longitude)
//            let point2D = MKMapPoint(x: latitude2D, y: longitude2D)
//
////            let site2M = MKMapSize(width: 0.0003, height: 0.0003)
////            let rect2G = MKMapRect(origin: point2M, size: site2M)
//
//
//
//            let rect2G = MKMapRectMake(NE.latitude, NE.longitude, 128, 128)
//            let pointInside = MKMapRectContainsPoint(rect2G, point2D)
//
////            let mkcr = MKCoordinateRegionForMapRect(rect2G)
////            let cgr = self.mapView.convertRegion(mkcr, toRectTo: self.view)
////            let win2S = UIView(frame: cgr)
////            win2S.backgroundColor = UIColor.yellow
////            self.view.addSubview(win2S)
////            win2S.bringSubview(toFront: self.mapView)
////
////            print("cgr \(pointInside)")
//        }
    }
    
    private func doBox(latitude2S: String, longitude2S: String) {
        var coordinates:[CLLocationCoordinate2D] = []
        print("latitude2S \(latitude2S) longitude2S \(longitude2S)")
        var latitude2P = latitude2S.split(separator: "-")
        var longitude2P = longitude2S.split(separator: "-")
        
        let lat2Pplus = Int(latitude2P[2])! + 1
        let lon2Pplus = Int(longitude2P[2])! + 1
        
        
//        let lat2Pminus = Int(latitude2P[2])! - 1
//        let lon2Pminus = Int(longitude2P[2])! - 1
        
        //        [(36,22)
        let start2PLatitude = "\(latitude2P[0])-\(latitude2P[1])-\(latitude2P[2])-\(latitude2P[3])"
        let (NWLatitude, NWLongitude) = getDigitalFromDegrees(latitude: start2PLatitude, longitude: longitude2S)
        var cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NWLongitude)
        coordinates.append(cord2U)
        
        //         (37,22)
        let source2PLatitude = "\(latitude2P[0])-\(latitude2P[1])-\(lat2Pplus)-\(latitude2P[3])"
        print("source2PLatitude \(source2PLatitude) longitude2S \(longitude2S)")
        let (SELatitude, SELongitude) = getDigitalFromDegrees(latitude: source2PLatitude, longitude: longitude2S)
        cord2U = CLLocationCoordinate2D(latitude: SELatitude, longitude: SELongitude)
        coordinates.append(cord2U)

        //        (37,23)
        let source2PLongitude = "\(longitude2P[0])-\(longitude2P[1])-\(lon2Pplus)-\(longitude2P[3])"
        print("source2PLongitude \(source2PLongitude) \(source2PLongitude)")
        let (SWLatitude, SWLongitude) = getDigitalFromDegrees(latitude: source2PLatitude, longitude: source2PLongitude)
        cord2U = CLLocationCoordinate2D(latitude: SWLatitude, longitude: SWLongitude)
        coordinates.append(cord2U)
//
//        //        (36,23)
        print("source2PLongitude \(latitude2S) \(source2PLongitude)")
        let (NELatitude, NELongitude) = getDigitalFromDegrees(latitude: latitude2S, longitude: source2PLongitude)
        cord2U = CLLocationCoordinate2D(latitude: NELatitude, longitude: NELongitude)
        coordinates.append(cord2U)
//
//        //        (36,22)]
//        print("source2PLongitude \(latitude2S) \(source2PLongitude)")
//        cord2D = getDigitalFromDegrees(latitude: latitude2S, longitude: longitude2S)
        cord2U = CLLocationCoordinate2D(latitude: NWLatitude, longitude: NWLongitude)
        coordinates.append(cord2U)
        
        
        let polyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        DispatchQueue.main.async {
            self.mapView.add(polyLine, level: MKOverlayLevel.aboveRoads)
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
        var pinTintColor: UIColor?
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //check annotation is not user location
        let userLongitude = mapView.userLocation.coordinate.longitude
        let userLatitiude = mapView.userLocation.coordinate.latitude
        if annotation.coordinate.longitude == userLongitude, annotation.coordinate.latitude == userLatitiude {
            return nil
        }
    
        var view: MKAnnotationView! = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)

            view.canShowCallout = true
        } else {
            view.annotation = annotation
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
    var recordZone: CKRecordZone!
    var recordZoneID: CKRecordZoneID!
    var recordID: CKRecordID!
    
    @IBAction func newMap(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Map Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Map Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
            if textField?.text != "" {
//                    self.mapRecord = CKRecord(recordType: Constants.Entity.mapLinks, zoneID: self.recordZone.zoneID)
//                    self.mapRecord.setObject(textField?.text as CKRecordValue?, forKey: Constants.Attribute.mapName)
//                    self.mapRecord?.parent = nil
//                    self.linksRecord = CKReference(record: self.mapRecord, action: .deleteSelf)
                    self.recordZone = CKRecordZone(zoneName: (textField?.text)!)
                    let operation = CKFetchRecordZonesOperation(recordZoneIDs: [self.recordZone.zoneID])
                    operation.fetchRecordZonesCompletionBlock = { _, error in
                        if error == nil {
                            print(error?.localizedDescription.debugDescription)
                            self.privateDB.save(self.recordZone, completionHandler: ({returnRecord, error in
                                if error != nil {
                                    // Zone creation failed
                                    print("Cloud privateDB Error\n\(error?.localizedDescription.debugDescription)")
                                } else {
                                    // Zone creation succeeded
                                    print("The 'privateDB LeZone' was successfully created in the private database.")
                                }
                            }))
                        }
                }
                self.privateDB.add(operation)
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
        return "My First Share"
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
    
    func save2Cloud() {
        if recordZone == nil {
            newMap(UIBarButtonItem())
            return
        }
        sharingApp = true
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//       let file2ShareURL = documentsDirectoryURL.appendingPathComponent("image2SaveX")
        if listOfPoint2Seek.count != wayPoints.count {
            listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
        }
        
//        self.recordZone = CKRecordZone(zoneName: "LeZone")
//        CKContainer.default().discoverAllIdentities { (users, error) in
//            print("identities \(users) \(error)")
//        }
//
//        CKContainer.default().discoverUserIdentity(withEmailAddress:"mark.lucking@gmail.com") { (id,error ) in
//            print("identities \(id.debugDescription) \(error)")
//            self.userID = id!
//        }
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.waitUntilAllOperationsAreFinished()
        
//        var rec2Save:[CKRecord] = []
        var p2S = 0
        for point2Save in listOfPoint2Seek {
//            let operation1 = BlockOperation {
            
                let ckWayPointRecord = CKRecord(recordType: Constants.Entity.wayPoints, zoneID: self.recordZone.zoneID)
                ckWayPointRecord.setObject(point2Save.coordinates?.longitude as CKRecordValue?, forKey: Constants.Attribute.longitude)
                ckWayPointRecord.setObject(point2Save.coordinates?.latitude as CKRecordValue?, forKey: Constants.Attribute.latitude)
                ckWayPointRecord.setObject(point2Save.name as CKRecordValue?, forKey: Constants.Attribute.name)
                ckWayPointRecord.setObject(point2Save.hint as CKRecordValue?, forKey: Constants.Attribute.hint)
                ckWayPointRecord.setObject(p2S as CKRecordValue?, forKey: Constants.Attribute.order)
                p2S += 1
//                ckWayPointRecord.setParent(self.mapRecord)
            var image2D: Data!
            if point2Save.image != nil {
                image2D = UIImageJPEGRepresentation(point2Save.image!, 1.0)
            } else {
                image2D = UIImageJPEGRepresentation(UIImage(named: "noun_1348715_cc")!, 1.0)
            }
                let file2ShareURL = documentsDirectoryURL.appendingPathComponent(point2Save.name!)
                try? image2D?.write(to: file2ShareURL, options: .atomicWrite)
                let newAsset = CKAsset(fileURL: file2ShareURL)
                ckWayPointRecord.setObject(newAsset as CKAsset?, forKey: Constants.Attribute.imageData)
                self.records2Share.append(ckWayPointRecord)
        }
        
        let modifyOp = CKModifyRecordsOperation(recordsToSave:
            records2Share, recordIDsToDelete: nil)
        modifyOp.savePolicy = .allKeys
        modifyOp.perRecordCompletionBlock = {(record,error) in
            print("error \(error.debugDescription)")
        }
        modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
            error) in
            if error != nil {
                print("error \(error.debugDescription)")
            }}
        self.privateDB.add(modifyOp)
        
        // new code added for parent setup 2nd try
        
        var recordID2Share:[CKReference] = []
        sharePoint = CKRecord(recordType: Constants.Entity.mapLinks, zoneID: self.recordZone.zoneID)
        
        for rex in self.records2Share {
            let parentR = CKReference(record: self.sharePoint, action: .none)
            rex.parent = parentR
            let childR = CKReference(record: rex, action: .deleteSelf)
            recordID2Share.append(childR)
        }
        
        sharePoint.setObject(self.recordZone.zoneID.zoneName as CKRecordValue, forKey: Constants.Attribute.mapName)
        sharePoint.setObject(recordID2Share as CKRecordValue, forKey: Constants.Attribute.wayPointsArray)
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
                }}
            self.privateDB.add(modifyOp)
        
//        let record2S = records2Share.first!
        let record2S = self.sharePoint
        
            let share = CKShare(rootRecord: record2S!)
                    share[CKShareTitleKey] = "My Next Share" as CKRecordValue
                    share.publicPermission = .none
                    
                    let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
                        @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                        let modifyOp = CKModifyRecordsOperation(recordsToSave:
                            [record2S!, share], recordIDsToDelete: nil)
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
                DispatchQueue.main.async {
                    self.present(sharingController, animated:true, completion:nil)
                }
        }
    }
        
    @IBAction func FetchShare(_ sender: Any) {
        getShare()
    }
    
    @IBAction func saveB(_ sender: Any) {
        saveImage()
    }
    
    @IBOutlet weak var pin: UIBarButtonItem!
    @IBAction func GetParts(_ sender: Any) {
        if currentLocation != nil {
            let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude)
            let wayNames = Array(wayPoints.keys)
            let uniqueName = "Clue".madeUnique(withRespectTo: wayNames)
            let waypoint2 = MyPointAnnotation()
            waypoint2.coordinate  = userLocation
            waypoint2.title = uniqueName
            let wp2FLat = self.getLocationDegreesFrom(latitude: waypoint2.coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: waypoint2.coordinate.longitude)
             let hint2D = wp2FLat + wp2FLog
            waypoint2.subtitle = hint2D
            waypoint2.pinTintColor = UIColor.green
            updateWayname(waypoint2U: waypoint2, image2U: nil)
            mapView.addAnnotation(waypoint2)
            let newWayPoint = wayPoint(major:nil, minor: nil, proximity: nil, coordinates: userLocation, name: uniqueName, hint: hint2D, image: nil, order: wayPoints.count)
            wayPoints[uniqueName] = newWayPoint
        }
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
        mapView.alpha = 0.7
        listOfPoint2Seek = []
        centerImage.image = UIImage(named: "compassClip")
        recordZone = CKRecordZone(zoneName: "work")
        recordZoneID = recordZone.zoneID
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Waypoints", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        privateDB.perform(query, inZoneWith: recordZoneID) { (records, error) in
            if error != nil {
                print("error \(error)")
            }
            for record in records! {
                self.plotPin(pin2P: record)
                let region2M = self.region(withPins: record)
                self.addRadiusOverlay(forGeotification: record)
               self.locationManager?.startMonitoring(for: region2M)
                let longitude = record.object(forKey:  Constants.Attribute.longitude) as? Double
                let latitude = record.object(forKey:  Constants.Attribute.latitude) as? Double
                let name = record.object(forKey:  Constants.Attribute.name) as? String
                let hint = record.object(forKey:  Constants.Attribute.hint) as? String
                let order = record.object(forKey:  Constants.Attribute.order) as? Int
                let wp2FLat = self.getLocationDegreesFrom(latitude: latitude!)
                let wp2FLog = self.getLocationDegreesFrom(longitude: longitude!)
                let wp2S = wayPoint(major:nil, minor: nil, proximity: nil, coordinates: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), name: name, hint: hint, image: nil, order: order)
                listOfPoint2Seek.append(wp2S)
                WP2M[wp2FLat+wp2FLog] = name
                DispatchQueue.main.async {
                    self.doBox(latitude2S: wp2FLat, longitude2S: wp2FLog)
                }
            }
        }
    
    let when = DispatchTime.now() + Double(8)
    DispatchQueue.main.asyncAfter(deadline: when){

        
        for points in listOfPoint2Seek {
            let long = self.getLocationDegreesFrom(longitude: (points.coordinates?.longitude)!)
            let lat = self.getLocationDegreesFrom(longitude: (points.coordinates?.latitude)!)
            print("listOfPoint2Seek \(long) \(lat)")
        }
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
    
    private func nextLocation2Show() {
        if listOfPoint2Seek.count == 0 { return }
        let nextWP2S = listOfPoint2Seek[(order!)]
        self.longitudeNextLabel.text = self.getLocationDegreesFrom(longitude: (nextWP2S.coordinates?.longitude)!)
        self.latitudeNextLabel.text = self.getLocationDegreesFrom(latitude: (nextWP2S.coordinates?.latitude)!)
        self.nextLocation = CLLocationCoordinate2DMake((nextWP2S.coordinates?.latitude)!, (nextWP2S.coordinates?.longitude)!)
        self.angle2U = self.getBearing(toPoint: self.nextLocation, longitude:  (self.locationManager?.location?.coordinate.longitude)!, latitude:  (self.locationManager?.location?.coordinate.latitude)!)
        self.hintLabel.text = nextWP2S.hint
        self.nameLabel.text = nextWP2S.name
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
        save2Cloud()
//        saveImage()
    }
     
     // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        let annotationView = sender as? MKAnnotationView
        if segue.identifier == Constants.EditUserWaypoint {
            let ewvc = destination as? EditWaypointController
            wayPoints.removeValue(forKey: ((pinViewSelected?.title)!)!)
            ewvc?.nameText = (pinViewSelected?.title)!
            ewvc?.hintText = (pinViewSelected?.subtitle)!
            ewvc?.setWayPoint = self
                if let ppc = ewvc?.popoverPresentationController {
                    ppc.sourceRect = (annotationView?.frame)!
                    ppc.delegate = self
                }
        }
        if segue.identifier == Constants.TableWaypoint {
            let tbvc = destination as?  HideTableViewController
            tbvc?.zapperDelegate = self
        }
        if segue.identifier == Constants.ScannerViewController {
            let svc = destination as? ScannerViewController
            svc?.firstViewController = self
        }
    }
    
    private func updateWayname(waypoint2U: MKPointAnnotation, image2U: UIImage?) {
        if image2U != nil {
            let waypoint2A = wayPoint(major:nil, minor: nil,proximity: nil, coordinates: waypoint2U.coordinate, name: waypoint2U.title, hint: waypoint2U.subtitle, image: image2U, order: wayPoints.count)
            wayPoints[waypoint2U.title!] = waypoint2A
        }
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let wayNames = Array(wayPoints.keys)
            let uniqueName = "Clue".madeUnique(withRespectTo: wayNames)
           let waypoint2 = MKPointAnnotation()
          waypoint2.coordinate  = coordinate
          waypoint2.title = uniqueName
            let wp2FLat = self.getLocationDegreesFrom(latitude: coordinate.latitude)
            let wp2FLog = self.getLocationDegreesFrom(longitude: coordinate.longitude)
          waypoint2.subtitle = wp2FLat + wp2FLog
            updateWayname(waypoint2U: waypoint2, image2U: nil)
            
            let hint2D = wp2FLat + wp2FLog
            let newWayPoint = wayPoint(major:nil, minor: nil, proximity: nil, coordinates: coordinate, name: uniqueName, hint:hint2D, image: nil, order: wayPoints.count)
            wayPoints[uniqueName] = newWayPoint
//            let wp2FLat = getLocationDegreesFrom(latitude: coordinate.latitude)
//            let wp2FLog = getLocationDegreesFrom(longitude: coordinate.longitude)
            WP2M[wp2FLat+wp2FLog] = uniqueName
            DispatchQueue.main.async() {
                self.mapView.addAnnotation(waypoint2)
//                self.doBox(latitude2S: wp2FLat, longitude2S: wp2FLog)
                self.doBoxV2(latitude2D: coordinate.latitude, longitude2D: coordinate.longitude)
            }
        }
    }
    
    // MARK: Popover Delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
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
        let record2S =  [metadata.rootRecordID].first
        DispatchQueue.main.async() {
            self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            self.spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 64, height: 64))
            self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(self.spinner)
            self.spinner.startAnimating()
        }
        let operation = CKFetchRecordsOperation(recordIDs: [record2S!])
        operation.perRecordCompletionBlock = { record, _, error in
            if error != nil {
                print(error?.localizedDescription.debugDescription)
            }
            if record != nil {
                let name2S = record?.object(forKey: Constants.Attribute.mapName) as? String
                DispatchQueue.main.async() {
                    self.navigationItem.title = name2S
                }
                let pins2Plot = record?.object(forKey: Constants.Attribute.wayPointsArray) as? Array<CKReference>
                self.queryShare(record2S: pins2Plot!)
                }
            }
        sharedDB.add(operation)
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
                self.plotPin(pin2P: record!)
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
                self.didSetImage(image: image2D)
                self.updateWayname(waypoint2U: waypoint, image2U: image2D)
                self.mapView.deselectAnnotation(waypoint, animated: false)
            } else {
                self.mapView.addAnnotation(waypoint)
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
        centerImage.alpha = 0.5
        order = 0
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
        static let TableWaypoint = "Table Waypoint"
        static let ScannerViewController = "Scan VC"
        
        struct Entity {
            static let wayPoints = "wayPoints"
            static let mapLinks = "mapLinks"
        }
        struct Attribute {
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
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }
}


