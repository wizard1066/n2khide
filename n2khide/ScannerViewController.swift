//
//  ScannerViewController.swift
//  n2khide
//
//  Created by localuser on 19.06.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import AVFoundation
import UIKit
import CoreBluetooth
import CoreLocation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CBPeripheralManagerDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var firstViewController: HiddingViewController?
    
    var peripheralManager =  CBPeripheralManager()
    var locationManager = CLLocationManager()
    var instructionView: UITextView!
    
    private var major2U: UInt16! = 1
    private var minor2U: UInt16! = 1
    private var uuid2U: String!
    private var dataDictionary:[String:Any] = [:]
    private var  beaconRegion: CLBeaconRegion!
    
    override func viewDidDisappear(_ animated: Bool) {
        peripheralManager.stopAdvertising()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        instructionView = UITextView(frame: previewLayer.frame)
        instructionView.text = "QR code of the ibeacon UUID you need search for ... "
        instructionView.font = UIFont(name: "StarStrella", size: 32)
        instructionView.textColor = UIColor.red
        instructionView.backgroundColor = UIColor.clear
        instructionView.textAlignment = .center
        self.view.addSubview(instructionView)
        instructionView.translatesAutoresizingMaskIntoConstraints  = false
        instructionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        instructionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        instructionView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        instructionView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(broadcast))
        navigationItem.rightBarButtonItem = rightBarButton
        
        captureSession.startRunning()
    }
    

    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if (captureSession?.isRunning == false) {
//            captureSession.startRunning()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let localUUID = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: localUUID)
        }
        
//        dismiss(animated: true)
    }
    
    func found(code: String) {
        let ac = UIAlertController(title: "Code Read", message:code, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//           self.presentingViewController?.dismiss(animated: true, completion: {
//                // nothing
//            })
            if UUID(uuidString: code) != nil {
                self.firstViewController?.globalUUID = code
                self.instructionView.text = "You're good to go,, use the play button to create a broadcast test"
            } else {
                self.instructionView.text = "Sorry, code isn't a valid UUID I can use"
                self.captureSession.startRunning()
            }
//            self.navigationController?.popViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: iBeacon code
    
    @objc func broadcast() {
        let alert = UIAlertController(title: "Map Name", message: "iBeacon MajorMinor", preferredStyle: .alert)
        alert.addTextField { (majorT2U) in
            majorT2U.placeholder = "major"
        }
        alert.addTextField { (minorT2U) in
            minorT2U.placeholder = "minor"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let major = alert?.textFields![0]
            let minor = alert?.textFields![1]
            if major?.text != "",  minor?.text != " "{
                self.major2U = UInt16(Int((major!.text)!)!)
                self.minor2U = UInt16(Int((minor!.text)!)!)
                print("start Beacon")
                let uuid2G = UUID(uuidString:(self.firstViewController?.globalUUID!)!)
                if uuid2G != nil {
                    self.peripheralManager.stopAdvertising()
                    self.beaconRegion = CLBeaconRegion(proximityUUID: uuid2G!, major: self.major2U, minor: self.minor2U, identifier: "broadcast")
                    if self.peripheralManager.state == .poweredOn {
                        let region = self.beaconRegion.peripheralData(withMeasuredPower: nil) as! [String : Any]
                        self.dataDictionary = region
                        self.peripheralManager.startAdvertising(self.dataDictionary)
                        _ = self.peripheralManager.startAdvertising
                        self.instructionView.text = "Broadcasting, use the backbutton to STOP"
                    }
                }
            }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""
        
        switch peripheral.state {
        case CBManagerState.poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case CBManagerState.poweredOff:
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBManagerState.resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBManagerState.unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBManagerState.unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
        }
    }
    
}
