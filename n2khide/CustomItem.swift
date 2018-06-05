//
//  CustomItem.swift
//  n2khide
//
//  Created by localuser on 05.06.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

class CustomItem : UIActivityItemProvider {
    
    let photoURL: URL
    
    init(_ photoURL: URL) {
        self.photoURL = photoURL
        super.init(placeholderItem: photoURL)
    }
    
    override var item: Any {
        do {
            let image = try Data(contentsOf: photoURL)
            return image
        } catch {
            return [photoURL]
        }
    }
    
    }

