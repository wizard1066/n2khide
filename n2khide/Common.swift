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
        var major: Int?
        var minor: Int?
        var proximity:  CLProximity?
        var coordinates: CLLocationCoordinate2D?
        var name: String?
        var hint: String?
        var image: UIImage?
        var order: Int?
        var boxes:[CLLocation?]?
//        var imageAsset: CKAsset?
    }

var wayPoints:[String:wayPoint] = [:]
var listOfPoint2Seek:[wayPoint] = []
var WP2M:[String:String] = [:]
var order:Int?  = nil

enum tableViews  {
    case zones
    case points
}

var windowView: tableViews = .points

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



    

