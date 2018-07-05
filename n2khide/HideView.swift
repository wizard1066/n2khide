//
//  HideView.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit

class HideView: UIView {
    
    var backgroundImage: UIImage? {didSet { setNeedsDisplay() } }
    
//    override func draw(_ rect: CGRect) {
//        backgroundImage?.draw(in: rect)
//    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
