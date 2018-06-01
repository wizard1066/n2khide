//
//  EditWaypointController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

protocol  setWayPoint  {
    func didSetVariable(image: UIImage?, name: String?, hint: String?)
}

class EditWaypointController: UIViewController {
    
    var setWayPoint: setWayPoint!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    
    var nameText: String?
    var hintText: String?
    
    // MARK: View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = nameText
        hintTextField.text = hintText
        nameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopListeningToTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    // MARK: Observers
    
    private var namedObserver: NSObjectProtocol?
    private var hintObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        weak var presentingController = self.presentingViewController as? HiddingViewController
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = NSNotification.Name.UITextFieldTextDidEndEditing
        namedObserver = center.addObserver(forName: alert2Monitor, object: nameTextField, queue: queue) { (notification) in
//            if notification.name.rawValue == "UITextFieldTextDidChangeNotification" {
                print("You edited text \(self.nameTextField.text) \(notification.name)")
//                presentingController?.Text2Pass = self.nameTextField.text
                self.setWayPoint.didSetVariable(image: nil, name: self.nameTextField.text, hint: self.hintTextField.text)
//            }
        }
        hintObserver = center.addObserver(forName: alert2Monitor, object: hintTextField, queue: queue) { (notification) in
//             if notification.name.rawValue == "UITextFieldTextDidChangeNotification" {
            print("You edited hint \(self.hintTextField.text)")
            self.setWayPoint.didSetVariable(image: nil, name: self.nameTextField.text, hint: self.hintTextField.text)
//            presentingController?.Text2Pass = self.nameTextField.text
//            }
        }
    }
    
    private func stopListeningToTextFields() {
        let center = NotificationCenter.default
        if namedObserver != nil {
            center.removeObserver(namedObserver)
        }
        if hintObserver != nil {
            center.removeObserver(hintObserver)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TextDelegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
