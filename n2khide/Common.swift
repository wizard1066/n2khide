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
        var recordID: CKRecordID?
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
        var URL: String?
//        var imageAsset: CKAsset?
    }

struct wp2Search {
    var name: String?
    var find: String?
    var bon: Bool?
}

var wayPoints:[String:wayPoint] = [:]
var listOfPoint2Seek:[wayPoint] = []
//var listOfPoint2Save:[wayPoint]? = []
var listOfPoint2Search:[wp2Search] = []
var listOfZones:[String] = []
var parentID: CKReference?

var recordZone: CKRecordZone!
var zoneTable:[String:CKRecordZoneID] = [:]
var WP2M:[String:String] = [:]
var WP2P:[String:MKOverlay] = [:]
var order2Search:Int?  = nil
var order2SaveIndex:Int? = nil
var url2U: String?

enum tableViews  {
    case zones
    case points
    case playing
}

var windowView: tableViews = .points

enum gameplay {
    case initialized
    case playing
    case finished
    case defining
}

var codeRunState: gameplay = .initialized

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



    

