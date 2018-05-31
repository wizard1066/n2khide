//
//  Common.swift
//  n2khide
//
//  Created by localuser on 31.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import Foundation
import MapKit

struct wayPoint {
    var coordinates: CLLocationCoordinate2D?
    var name: String?
    var hint: String?
    var image: UIImage?
}

var wayPoints:[String:wayPoint] = [:]
