//
//  BubbleLongPressGestureRecognizer.swift
//  Nariko
//
//  Created by Zsolt Papp on 13/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public class BubbleLongPressGestureRecognizer: UILongPressGestureRecognizer, UIGestureRecognizerDelegate {
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        self.addTarget(self, action: #selector(tap(_:)))
        self.minimumPressDuration = 1.5
        self.numberOfTouchesRequired = 3
        delegate = self
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension BubbleLongPressGestureRecognizer {
    func tap(g:UILongPressGestureRecognizer) {
        
        print("long")
        
        switch g.state {
            
        case .Began:
            if NarikoTool.sharedInstance.isAuth{
                NarikoTool.sharedInstance.setupBubble()
            } else {
                let alertController = UIAlertController (title: "Information", message: "Please login in the settings", preferredStyle: .Alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                    let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                
                NarikoTool.sharedInstance.APPDELEGATE.window!!.rootViewController!.presentViewController(alertController, animated: true, completion: nil);
                
            }
            
        default: break
        }
    }
    
}
