//
//  EditWaypointController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

protocol  setWayPoint  {
    func didSetName(name: String?)
    func didSetHint(hint: String?)
    func didSetImage(image: UIImage?)
}

class EditWaypointController: UIViewController, UIDropInteractionDelegate {
    
    var setWayPoint: setWayPoint!

    @IBAction func Camera(_ sender: Any) {
    }
    
    @IBAction func Library(_ sender: Any) {
    }
    
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
    
    private var namedObserver: NSObjectProtocol!
    private var hintObserver: NSObjectProtocol!
    
    private func listenToTextFields() {
//        weak var presentingController = self.presentingViewController as? HiddingViewController
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = NSNotification.Name.UITextFieldTextDidEndEditing
        namedObserver = center.addObserver(forName: alert2Monitor, object: nameTextField, queue: queue) { (notification) in
                self.setWayPoint.didSetName(name: self.nameTextField.text)
        }
        hintObserver = center.addObserver(forName: alert2Monitor, object: hintTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetHint(hint: self.hintTextField.text)
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
    
    // MARK: DropZone
    
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate:  self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return  session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                let image2D = UIImageView(frame: self.dropZone.frame)
                image2D.image = image
                 self.dropZone.addSubview(image2D)
                image2D.translatesAutoresizingMaskIntoConstraints  = false
                image2D.widthAnchor.constraint(equalToConstant: 64).isActive = true
                image2D.heightAnchor.constraint(equalToConstant: 64).isActive = true
                image2D.centerXAnchor.constraint(equalTo: self.dropZone.centerXAnchor).isActive = true
                image2D.centerYAnchor.constraint(equalTo: self.dropZone.centerYAnchor).isActive = true
                self.setWayPoint.didSetImage(image: image)
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            if let url = nsurl.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
}
