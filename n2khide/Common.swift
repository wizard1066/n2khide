//
//  Common.swift
//  n2khide
//
//  Created by localuser on 31.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

// "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"

typealias Codable = Decodable & Encodable

struct wayPoint {
        var UUID: String?
        var major: Int?
        var minor: Int?
        var proximity:  CLProximity?
        var coordinates: CLLocationCoordinate2D?
        var name: String?
        var hint: String?
        var image: UIImage?
        var order: Int?
        var boxes:[CLLocation?]?
        var challenge: String?
//        var imageAsset: CKAsset?
    }

var wayPoints:[String:wayPoint] = [:]
var listOfPoint2Seek:[wayPoint] = []
var listOfPoint2Save:[wayPoint]? = []
var parentID: CKReference?

var zoneTable:[String:CKRecordZoneID] = [:]
var WP2M:[String:String] = [:]
var WP2P:[String:MKOverlay] = [:]
var order2Search:Int?  = nil
var order2SaveIndex:Int? = nil

enum tableViews  {
    case zones
    case points
}

var windowView: tableViews = .points

enum op {
    case playing
    case recording
}

var usingMode: op = .recording

enum point {
    case gps
    case ibeacon
}
var trigger: point = .gps

struct way2G: Codable
{
    var longitude: Double
    var latitude: Double
    var name: String
    var hint: String
    var imageURL: URL
}

var beaconRegion:CLBeaconRegion!
var currentZone: CKRecordZone!
var currentWayPoint: wayPoint!



    

