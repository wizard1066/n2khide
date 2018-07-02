//
//  HideTableViewController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import CloudKit

protocol zap  {
    func wayPoint2G(wayPoint2G: String)
}

class HideTableViewController: UITableViewController, setWayPoint, UIPopoverPresentationControllerDelegate {
    
    func didSetName(name: String?) {
        // code
    }
    
    func didSetHint(name: String?, hint: String?) {
        // code
    }
    
    func didSetImage(name: String?, image: UIImage?) {
        // code
    }
    
    func didSetChallenge(name: String?, challenge: String?) {
        // code
    }
    
    

    
    var zapperDelegate: zap!
    private let privateDB = CKContainer.default().privateCloudDatabase

    private var shadowTable:[wayPoint?]? = []
    
    @objc func switchTable() {
        print("switchin")
        if windowView == .points {
            let button = UIButton(type: .custom)
            button.setImage(UIImage (named: "map_marker"), for: .normal)
            button.frame = CGRect(x: 0.0, y: 0.0, width: 35.0, height: 35.0)
            button.addTarget(self, action: #selector(switchTable), for: .touchUpInside)
            
            let barButtonItem = UIBarButtonItem(customView: button)
            
            self.navigationItem.leftBarButtonItems = [barButtonItem]
            
            
            if listOfPoint2Seek.count > 0 {
                shadowTable = listOfPoint2Seek
            }
            windowView = .zones
            listOfPoint2Seek.removeAll()
            let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
            operation.fetchRecordZonesCompletionBlock = { records, error in
                if error != nil {
                    print(error?.localizedDescription.debugDescription)
                }
                for rex in records! {
                    let rex2S = wayPoint(UUID: nil, major: 0, minor: 0, proximity: nil, coordinates: nil, name: rex.value.zoneID.zoneName, hint: nil, image: nil, order: nil, boxes: nil, challenge: nil)
                     listOfPoint2Seek.append(rex2S)
                    zoneTable[rex.value.zoneID.zoneName] = rex.value.zoneID
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            privateDB.add(operation)
        } else {
            windowView = .points
            
//            let closeButtonImage = UIImage(named: "ic_close_white")
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action:  #selector(ResetPasswordViewController.barButtonDidTap(_:)))

            let button = UIButton(type: .custom)
            button.setImage(UIImage (named: "marker"), for: .normal)
            button.frame = CGRect(x: 0.0, y: 0.0, width: 35.0, height: 35.0)
            button.addTarget(self, action: #selector(switchTable), for: .touchUpInside)
            
            let barButtonItem = UIBarButtonItem(customView: button)
            
            self.navigationItem.leftBarButtonItems = [barButtonItem]
            listOfPoint2Seek = shadowTable! as! [wayPoint]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func byebye() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func setEditing (_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing,animated:animated)
        if(self.isEditing)
        {
            self.editButtonItem.title = "Back"
        } else {
            self.editButtonItem.title = "Reorder"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
        
         let doneBarB = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(byebye))
        self.editButtonItem.title = "Reorder"
        self.navigationItem.rightBarButtonItems = [ doneBarB , self.editButtonItem]
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(switchTable))
        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "marker"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 35.0, height: 35.0)
        button.addTarget(self, action: #selector(switchTable), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem!.title = "Back"
        self.navigationItem.leftBarButtonItems = [barButtonItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
         return listOfPoint2Seek.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RuleCell", for: indexPath)

        // Configure the cell...
        if listOfPoint2Seek.count > 0 {
            let waypoint = listOfPoint2Seek[indexPath.row]
            cell.detailTextLabel?.text = waypoint.hint
            cell.textLabel? .text = waypoint.name
    
            return cell
        } else {
            return cell
        }
    }
 
    @IBAction func newRule(_ sender: Any) {
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//
//    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = listOfPoint2Seek[sourceIndexPath.row]
        listOfPoint2Seek.remove(at: sourceIndexPath.row)
        listOfPoint2Seek.insert(movedObject, at: destinationIndexPath.row)

        // To check for correctness enable: self.tableView.reloadData()
    }
    
    var classIndexPath: IndexPath!
    var rowView: UIView!

    
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
            self.classIndexPath = indexPath
            self.rowView = view
            self.performSegue(withIdentifier: Constants.EditUserWaypoint, sender: view)
            success(true)
        })
        closeAction.image = UIImage(named: "tick")
        closeAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [closeAction])
        
    }
    
    override func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if windowView == .points {
                let index2Zap = listOfPoint2Seek[indexPath.row].name
                self.zapperDelegate.wayPoint2G(wayPoint2G: index2Zap!)
                wayPoints.removeValue(forKey: index2Zap!)
                listOfPoint2Seek.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                success(true)
            }
            if windowView == .zones {
                let index2Zap = listOfPoint2Seek[indexPath.row].name
                let rex2Zap = zoneTable[index2Zap!]
                self.deleteZoneV2(zone2Zap: rex2Zap!)
                listOfPoint2Seek.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                success(true)
            }
        })
        modifyAction.image = UIImage(named: "hammer")
        modifyAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: CloudKit Code$
    func deleteZoneV2(zone2Zap: CKRecordZoneID) {
        let deleteOp = CKModifyRecordZonesOperation.init(recordZonesToSave: nil, recordZoneIDsToDelete: [zone2Zap])
        self.privateDB.add(deleteOp)
    }
    
    func modifyZone(zone2Zap: CKRecordID) {
        let modifyOp = CKModifyRecordsOperation(recordsToSave:nil, recordIDsToDelete: [zone2Zap])
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
    }
    
    // MARK: Segue Code
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        if segue.identifier == Constants.EditUserWaypoint {
            let ewvc = destination as? EditWaypointController
            ewvc?.nameText = listOfPoint2Seek[classIndexPath.row].name
            ewvc?.hintText = listOfPoint2Seek[classIndexPath.row].hint
            ewvc?.challengeText = listOfPoint2Seek[classIndexPath.row].challenge
            ewvc?.setWayPoint = self
            if let ppc = ewvc?.popoverPresentationController {
                ppc.sourceRect = (rowView.frame)
                ppc.delegate = self
            }
        }
//        if segue.identifier == Constants.EditUserWaypoint, trigger == point.ibeacon {
//            let ewvc = destination as? EditWaypointController
//            let uniqueName = "UUID"
//            ewvc?.nameText =  uniqueName
//            ewvc?.hintText = "ibeacon"
//            ewvc?.setWayPoint = self
//            if let ppc = ewvc?.popoverPresentationController {
//                ppc.sourceRect = tableView.frame
//                ppc.delegate = self
//            }
//        }
    }
    
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
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }

}
