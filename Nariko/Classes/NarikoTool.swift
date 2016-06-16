//
//  NarikoTool.swift
//  Nariko
//
//  Created by Zsolt Papp on 10/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import SwiftHTTP

public class NarikoTool: UIResponder, UITextViewDelegate {
    
    static public let sharedInstance = NarikoTool()
    
    var apiKey: String?
    
    let APPDELEGATE: UIApplicationDelegate = UIApplication.sharedApplication().delegate!
    
    var bubble: BubbleControl!
    var isAuth: Bool = false
    var WINDOW: UIWindow?
    var textView: UITextView = UITextView(frame: CGRectZero)
    
    public override init() {
        super.init()
        registerSettingsBundle()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.checkAuth), name: NSUserDefaultsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.removeBubble), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit { //Not needed for iOS9 and above. ARC deals with the observer.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
    }
    
    public func checkAuth(){
        let defaults = NSUserDefaults.standardUserDefaults()
        print(defaults.stringForKey("nar_email"))
        print(defaults.stringForKey("nar_pass"))
        
        print(NSBundle.mainBundle().bundleIdentifier)
        
        if defaults.stringForKey("nar_email") != nil && defaults.stringForKey("nar_pass") != nil{
            print("check auth")
            CallApi().authRequest(["Email": defaults.stringForKey("nar_email")!, "Password": defaults.stringForKey("nar_pass")!, "BundleId": NSBundle.mainBundle().bundleIdentifier!], callCompletion: { (success, errorCode, msg) in
                if success{
                    self.apiKey = msg
                    print("OOOKKK")
                    self.isAuth = true
                }
            })
            
        } else {
            print("Not logged in!")
            /* CallApi().authRequest(["Email": "teszt", "Password": "alma"], callCompletion: { (success, errorCode, msg) in
             if success{
             self.apiKey = msg
             print("OOOKKK2222")
             self.isAuth = true
             }
             }) */
            
        }
    }
    
    
    public func setupBubble () {
        let win = APPDELEGATE.window!!
        
        win.endEditing(true)
        
        bubble = BubbleControl (win: win, size: CGSizeMake(80, 80))
        bubble.tag = 3333
        
        let podBundle = NSBundle(forClass: NarikoTool.self)
        if let url = podBundle.URLForResource("Nariko", withExtension: "bundle") {
            let bundle = NSBundle(URL: url)
            bubble.image = UIImage(named: "debugme_logo_rc", inBundle: bundle, compatibleWithTraitCollection: nil)
        }
        
        bubble.setOpenAnimation = { content, background in
            self.bubble.contentView!.bottom = win.bottom
            if (self.bubble.center.x > win.center.x) {
                self.bubble.contentView!.left = win.right
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.right = win.right
                    }, completion: nil)
            } else {
                self.bubble.contentView!.right = win.left
                self.bubble.contentView!.spring({ () -> Void in
                    self.bubble.contentView!.left = win.left
                    }, completion: nil)
            }
        }
        var max: CGFloat?
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation){
            max = win.h - 350
        } else {
            max = win.h - 180
            
        }
        
        let v = UIView (frame: CGRect (x: 0, y: 0, width: win.w, height: max!))
        v.backgroundColor = UIColor.grayColor()
        
        let title = UILabel(frame: CGRectZero)
        title.text = "Feedback"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(title)
        
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15))
        
        let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(send), forControlEvents: .TouchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(sendButton)
        
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15))
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: #selector(removeBubble), forControlEvents: .TouchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(closeButton)
        
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15))
        
        textView.text = ""
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(textView)
        
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 60))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10))
        
        bubble.contentView = v
        
        win.addSubview(bubble)
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation){
            bubble.moveY(20.0)
            bubble.contentView?.moveY(20.0+bubble.size.height)
        } else {
            bubble.moveY(-bubble.size.height)
            bubble.contentView?.moveY(0.0)
        }
    }
    
    func send(){
        if bubble.screenShot != nil{
            CallApi().sendData(bubble.screenShot!, comment: textView.text) { (success, errorCode, msg) in
                if success {
                    print("send success")
                    self.removeBubble()
                }
            }
        } else {
            let alert = UIAlertController(title: "Information", message: "The screenshot could not be taken!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            APPDELEGATE.window!!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    public func removeBubble(){
        if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
            bubble.closeContentView()
            viewWithTag.removeFromSuperview()
        }
    }
}


