//
//  HiddingViewController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import MapKit

class HiddingViewController: UIViewController, UIDropInteractionDelegate, MKMapViewDelegate, UIPopoverPresentationControllerDelegate, setWayPoint  {
    
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
    
//    private var pinViewSelected: MKAnnotation?
    private var pinViewSelected: MKPointAnnotation!
    private var pinView: MKAnnotationView!
//    var pinViewSelected: eMapPin?
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("annotation selected \(pinViewSelected?.title)")
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        let annotationView = sender as? MKAnnotationView
        print("destination \(destination)")
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
    
    // MARK: DropZone
    
//    @IBOutlet var dropZone: UIView! {
//        didSet {
//            dropZone.addInteraction(UIDropInteraction(delegate:  self))
//        }
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
//        return  session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
//        return UIDropProposal(operation: .copy)
//    }
//
//    var imageFetcher: ImageFetcher!
//
//    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        print("dropInteraction")
//        imageFetcher = ImageFetcher() { (url, image) in
//            DispatchQueue.main.async {
//                self.hideView.backgroundImage = image
//            }
//        }
//        session.loadObjects(ofClass: NSURL.self) { nsurl in
//            if let url = nsurl.first as? URL {
//                self.imageFetcher.fetch(url)
//            }
//        }
//        session.loadObjects(ofClass: UIImage.self) { images in
//            if let image = images.first as? UIImage {
//                self.imageFetcher.backup = image
//
//            }
//        }
//    }
    
     @IBOutlet weak var hideView: HideView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
    }
    

}
