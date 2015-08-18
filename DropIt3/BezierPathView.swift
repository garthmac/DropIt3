//
//  BezierPathView.swift
//  DropIt3
//
//  Created by iMac21.5 on 4/30/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class BezierPathView: UIView {

    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
}
