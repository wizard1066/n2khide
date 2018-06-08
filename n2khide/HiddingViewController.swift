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

class HiddingViewController: UIViewController, UIDropInteractionDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, setWayPoint, zap, UICloudSharingControllerDelegate, showPoint {
    
    //MARK:  observer
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
    
    private func clearWaypoints() {
        mapView?.removeAnnotation(mapView.annotations as! MKAnnotation)
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .standard
            mapView.delegate = self
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
                _ckWayPointRecord = CKRecord(recordType: Constants.Entity.wayPoint )
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
    
    func save2Cloud() {
        sharingApp = true
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let file2ShareURL = documentsDirectoryURL.appendingPathComponent("image2SaveX")
        if listOfPoint2Seek.count != wayPoints.count {
            listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
        }
        
        let recordZone = CKRecordZone(zoneName: "LeZone")
        CKContainer.default().discoverAllIdentities { (users, error) in
            print("identities \(users) \(error)")
        }
        
        CKContainer.default().discoverUserIdentity(withEmailAddress:"mark.lucking@gmail.com") { (id,error ) in
            print("identities \(id.debugDescription) \(error)")
            self.userID = id!
        }
        
        for point2Save in listOfPoint2Seek {
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.waitUntilAllOperationsAreFinished()
            
            let ckWayPointRecord = CKRecord(recordType: "Waypoints", zoneID: recordZone.zoneID)
            ckWayPointRecord.setObject(point2Save.coordinates?.longitude as CKRecordValue?, forKey: Constants.Attribute.longitude)
            ckWayPointRecord.setObject(point2Save.coordinates?.latitude as CKRecordValue?, forKey: Constants.Attribute.latitude)
            ckWayPointRecord.setObject(point2Save.name as CKRecordValue?, forKey: Constants.Attribute.name)
            ckWayPointRecord.setObject(point2Save.hint as CKRecordValue?, forKey: Constants.Attribute.hint)
            let imageData = UIImageJPEGRepresentation((point2Save.image)!, 1.0)
            do {
                try imageData?.write(to: file2ShareURL)
                ckWayPointRecord.setObject(CKAsset(fileURL: file2ShareURL), forKey: Constants.Attribute.imageData)
                
                self.privateDB.save(recordZone, completionHandler: ({returnRecord, error in
                    if error != nil {
                        // Zone creation failed
                        print("Cloud privateDB Error\n\(error?.localizedDescription)")
                    } else {
                        // Zone creation succeeded
                        print("The 'privateDB LeZone' was successfully created in the private database.")
                    }
                }))
                
                privateDB.save(ckWayPointRecord) { (savedRecord, error) in
                    if error != nil {
                        print("error \(error.debugDescription)")
                    }
                    let share = CKShare(rootRecord: savedRecord!)
                    share[CKShareTitleKey] = "My First Share" as CKRecordValue
                    share.publicPermission = .none
                    savedRecord?.parent = nil
                    print("elf.userID \(self.userID)")
                    
                    let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
                        @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                        let modifyOp = CKModifyRecordsOperation(recordsToSave:
                            [savedRecord!, share], recordIDsToDelete: nil)
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
                    
                    
                    let fetchParticipantsOperation = CKFetchShareParticipantsOperation(userIdentityLookupInfos: [self.userID.lookupInfo!])
                    fetchParticipantsOperation.fetchShareParticipantsCompletionBlock = {error in
                        if let error = error {
                            print("error for completion" + error.localizedDescription)
                        }
                    }
                    fetchParticipantsOperation.shareParticipantFetchedBlock = {participant in
                        print("participant \(participant)")
                        participant.permission = .readWrite
                        share.addParticipant(participant)
                        fetchParticipantsOperation.fetchShareParticipantsCompletionBlock = { error in
                            //                                guard handleCloudKitError(error, operation: .fetchRecords) == nil else { return }
                            if error != nil {
                                print("fetchParticipantsOp \(error.debugDescription)")
                            }
                            print("fetchParticipantsOperation completed")
                            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [savedRecord!, share], recordIDsToDelete: nil)
                            modifyOperation.savePolicy = .ifServerRecordUnchanged
                            modifyOperation.perRecordCompletionBlock = {record, error in
                                print("record completion \(record) and \(error.debugDescription)")
                            }
                            modifyOperation.modifyRecordsCompletionBlock = {records, recordIDs, error in
                                guard let ckrecords: [CKRecord] = records, let record: CKRecord = ckrecords.first, error == nil else {
                                    print("error in modifying the records " + error!.localizedDescription)
                                    return
                                }
                                print("share url \(share.url?.debugDescription ?? "")")
                                DispatchQueue.main.async {
                                    UIApplication.shared.open(share.url!, options: [:], completionHandler: { (status) in
                                        // do nothing
                                })
                                }
                            }
                            self.operationQueue.addOperation(modifyOperation)
                        }
                    }
                    self.operationQueue.addOperation(fetchParticipantsOperation)
                }
            } catch {
                print(error)
            }
        }
    }
        
    @IBAction func FetchShare(_ sender: Any) {
        getShare()
    }
    
    @IBAction func GetParts(_ sender: Any) {
        getParticipant()
    }
    
    func getParticipant() {
        CKContainer.default().discoverAllIdentities { (identities, error) in
            print("identities \(identities.debugDescription)")
        }
    }
    
    private var userID: CKUserIdentity!
    
    func getShare() {
        let shareDB = CKContainer.default().sharedCloudDatabase
        let privateDB = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Waypoints", predicate: NSPredicate(value: true))
        let recordZone2U = CKRecordZone(zoneName: "LeZone").zoneID
       
        shareDB.perform(query, inZoneWith: recordZone2U) { (records, error) in
            print("mine record \(records.debugDescription) and error \(error.debugDescription)")
        }
    }
    
    func saveImage() {
//        if listOfPoint2Seek.count != wayPoints.count {
//            listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
//        }
        var w2GA:[way2G] = []
        for ways in listOfPoint2Seek {
            let w2G = way2G(longitude: (ways.coordinates?.longitude)!, latitude: (ways.coordinates?.latitude)!, name: ways.name!, hint: ways.hint!, imageURL: URL(string: "http://")!)
            w2GA.append(w2G)
        }
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(w2GA) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    var documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
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
    }
    
    private func updateWayname(waypoint2U: MKPointAnnotation, image2U: UIImage?) {
        let waypoint2A = wayPoint(coordinates: waypoint2U.coordinate, name: waypoint2U.title, hint: waypoint2U.subtitle, image: image2U)
        wayPoints[waypoint2U.title!] = waypoint2A
    }
    
    @IBAction func addWaypoint(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            let wayNames = Array(wayPoints.keys)
            let uniqueName = "Clue".madeUnique(withRespectTo: wayNames)
           let waypoint2 = MKPointAnnotation()
          waypoint2.coordinate  = coordinate
          waypoint2.title = uniqueName
          waypoint2.subtitle = "Hint"
            updateWayname(waypoint2U: waypoint2, image2U: nil)
            mapView.addAnnotation(waypoint2)
            let newWayPoint = wayPoint(coordinates: coordinate, name: uniqueName, hint: "Hint", image: nil)
            wayPoints[uniqueName] = newWayPoint
        }
    }
    
    // MARK: Popover Delegate
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        print("popoverPresentationControllerDidDismissPopover")
    }
    
     @IBOutlet weak var hideView: HideView!
    private var pinObserver: NSObjectProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let center = NotificationCenter.default
//        let queue = OperationQueue.main
//        let alert2Monitor = "showPin"
//        pinObserver = center.addObserver(forName: NSNotification.Name(rawValue: alert2Monitor), object: nil, queue: queue) { (notification) in
//            self.didSet(record2U: "showPin")
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
//         let center = NotificationCenter.default
//        if pinObserver != nil {
//            center.removeObserver(pinObserver)
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: {status, error in
            print("error \(error)")
        })
        // Do any additional setup after loading the view.
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
        
        struct Entity {
            static let wayPoint = "waypoint"
        }
        struct Attribute {
            static let longitude = "longitude"
            static let  latitude = "latitude"
            static let  name = "name"
            static let hint = "hint"
            static let  imageData = "image"
        }
    }
}


