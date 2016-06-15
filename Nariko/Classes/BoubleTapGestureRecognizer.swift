//
//  BoubleTapGestureRecognizer.swift
//  Nariko
//
//  Created by Zsolt Papp on 13/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class BoubleTapGestureRecognizer: UITapGestureRecognizer {
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
       NarikoTool.sharedInstance.removeBubble()
    }
}
