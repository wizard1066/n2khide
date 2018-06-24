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

class HideTableViewController: UITableViewController {
    
    var zapperDelegate: zap!
    private let privateDB = CKContainer.default().privateCloudDatabase
    private var zoneTable:[String:CKRecordZoneID] = [:]
    private var shadowTable:[wayPoint?]? = []
    
    @objc func switchTable() {
        if windowView == .points {
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
                    let rex2S = wayPoint(major: 0, minor: 0, proximity: nil, coordinates: nil, name: rex.value.zoneID.zoneName, hint: nil, image: nil, order: nil, boxes: nil)
                     listOfPoint2Seek.append(rex2S)
                    self.zoneTable[rex.value.zoneID.zoneName] = rex.value.zoneID
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            privateDB.add(operation)
        } else {
            windowView = .points
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
    
    override func viewWillAppear(_ animated: Bool) {
        listOfPoint2Seek = Array(wayPoints.values.map{ $0 })
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(switchTable))
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

    
    override func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let closeAction = UIContextualAction(style: .normal, title:  "Show", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Closed")
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
                let rex2Zap = self.zoneTable[index2Zap!]
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

}
