//
//  EditWaypointController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol  setWayPoint  {
    func didSetName(originalName: String?, name: String?)
    func didSetHint(name: String?, hint: String?)
    func didSetImage(name: String?, image: UIImage?)
    func didSetChallenge(name: String?, challenge: String?)
    func didSetURL(name: String?, URL:String?)
}

class EditWaypointController: UIViewController, UIDropInteractionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var setWayPoint: setWayPoint!
    var me:HiddingViewController!
    
    //MARK: Camera and Library routines
    
    @IBOutlet weak var CameraButton: UIButton! {
        didSet {
            CameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    
    @IBAction func WebBrowser(_ sender: Any) {
        performSegue(withIdentifier: Constants.WebViewController, sender: view)
    }
    
    @IBAction func Camera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: {
            // code
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = (info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage) {
            DispatchQueue.main.async {
//                self.updateImage(image2U: image)
                self.setWayPoint.didSetImage(name: self.nameTextField.text, image: image)
            }
        }
        picker.presentingViewController?.dismiss(animated: true, completion: {
            // code
        })
    }
    
    @IBAction func Library(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var challengeTextField: UITextField!
    
    var nameText: String?
    var hintText: String?
    var challengeText: String?
    
    // MARK: View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = nameText
        hintTextField.text = hintText
        challengeTextField.text = challengeText
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        if segue.identifier == Constants.WebViewController {
            let svc = destination as? WebViewController
            svc?.firstViewController = self
            svc?.secondViewController = me
            svc?.nameOfNode = nameText
        }
    }
    
    // MARK: Observers
    
    private var namedObserver: NSObjectProtocol!
    private var hintObserver: NSObjectProtocol!
    private var challengeObserver: NSObjectProtocol!
    
    private func listenToTextFields() {
//        weak var presentingController = self.presentingViewController as? HiddingViewController
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = NSNotification.Name.UITextFieldTextDidEndEditing
        namedObserver = center.addObserver(forName: alert2Monitor, object: nameTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetName(originalName:self.nameText, name: self.nameTextField.text)
        }
        hintObserver = center.addObserver(forName: alert2Monitor, object: hintTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetHint(name: self.nameTextField.text,hint: self.hintTextField.text)
        }
        challengeObserver = center.addObserver(forName: alert2Monitor, object: challengeTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetChallenge(name: self.nameTextField.text, challenge: self.challengeTextField.text)
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
        if challengeObserver != nil {
            center.removeObserver(challengeObserver)
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
//        return  session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        return session.hasItemsConforming(toTypeIdentifiers:
            [kUTTypeImage as String]) || session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: NSURL.self) &&
            session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    private func updateImage(image2U: UIImage) {
        let image2D = UIImageView(frame: self.dropZone.frame)
        image2D.image = image2U
        self.dropZone.addSubview(image2D)
        image2D.translatesAutoresizingMaskIntoConstraints  = false
        image2D.widthAnchor.constraint(equalToConstant: 64).isActive = true
        image2D.heightAnchor.constraint(equalToConstant: 64).isActive = true
        image2D.centerXAnchor.constraint(equalTo: self.dropZone.centerXAnchor).isActive = true
        image2D.centerYAnchor.constraint(equalTo: self.dropZone.centerYAnchor).isActive = true
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        imageFetcher = ImageFetcher() { (url, image) in
//            DispatchQueue.main.async {
////               self.updateImage(image2U: image)
//                self.setWayPoint.didSetImage(name: self.nameTextField.text, image: image)
//            }
//        }
        if session.canLoadObjects(ofClass: UIImage.self) {
            session.loadObjects(ofClass: UIImage.self) { (items) in
                if let images = items as? [UIImage] {
                    self.setWayPoint.didSetImage(name: self.nameTextField.text, image: images.first)
                }
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            if let url = nsurl.first as? URL {
                self.setWayPoint.didSetURL(name: self.nameTextField.text, URL: url.absoluteString)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { images in
//            if let image = images.first as? UIImage {
//                self.imageFetcher.backup = image
//            }
        }
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
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }
    
}
