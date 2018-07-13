//
//  ImageViewController.swift
//  n2khide
//
//  Created by localuser on 02.07.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image2S: UIImage!
    var challenge2A: String?
    var index2U: Int?
    weak var callingViewController: HiddingViewController?
    weak var tableCallingController: HideTableViewController?
    
    @IBOutlet weak var imageArea: UIImageView!
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true) {
            //do something
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageArea.image = image2S
        if challenge2A != nil {
            challenge()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: challenge code
    
    func challenge() {
        let alert = UIAlertController(title: "Challenge", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Challenge"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                if textField?.text == self.challenge2A {
                    if listOfPoint2Search.count > 0 {
                        listOfPoint2Search[self.index2U!].bon = true
                    }
                } else {
                    self.challenge()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: { [weak alert] (_) in
             if listOfPoint2Search.count > 0 {
                listOfPoint2Search[self.index2U!].bon = false
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
