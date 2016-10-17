//
//  BubbleTapGestureRecognizer.swift
//  Nariko
//
//  Created by Zsolt Papp on 13/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

open class BubbleTapGestureRecognizer: UITapGestureRecognizer {
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
       NarikoTool.sharedInstance.removeBubble()
    }
}
