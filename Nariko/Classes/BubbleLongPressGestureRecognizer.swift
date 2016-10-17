//
//  BubbleLongPressGestureRecognizer.swift
//  Nariko
//
//  Created by Zsolt Papp on 13/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

open class BubbleLongPressGestureRecognizer: UILongPressGestureRecognizer, UIGestureRecognizerDelegate {
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        
        self.addTarget(self, action: #selector(tap(_:)))
        self.minimumPressDuration = 1.5
        self.numberOfTouchesRequired = 3
        delegate = self
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view == okButton {
            NarikoTool.sharedInstance.closeNarikoAlertView()
        }
        
        return true
    }
    
}

extension BubbleLongPressGestureRecognizer {
    func tap(_ g: UILongPressGestureRecognizer) {
        if !isOnboarding{
            print("long")
            
            switch g.state {
                
            case .began:
                if NarikoTool.sharedInstance.isAuth {
                    NarikoTool.sharedInstance.setupBubble()
                } else {
                    let alertController = UIAlertController (title: "Information", message: "Please login in the settings", preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                        if let url = settingsUrl {
                            UIApplication.shared.openURL(url)
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(settingsAction)
                    alertController.addAction(cancelAction)
                    
                    NarikoTool.sharedInstance.APPDELEGATE.window!!.rootViewController!.present(alertController, animated: true, completion: nil);
                    
                }
                
            default: break
                
            }
        }
    }
}
