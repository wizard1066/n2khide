//
//  EditWaypointController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

class EditWaypointController: UIViewController {

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
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = NSNotification.Name.UITextViewTextDidChange
        namedObserver = center.addObserver(forName: nil, object: nameTextField, queue: queue) { (notification) in
            if notification.name.rawValue == "UITextFieldTextDidChangeNotification" {
                print("You edited text \(self.nameTextField.text) \(notification.name)")
            }
        }
        hintObserver = center.addObserver(forName: nil, object: hintTextField, queue: queue) { (notification) in
            print("You edited hint \(self.hintTextField.text)")
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
