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
    
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showActivityIndicator() {
        let screenSize: CGRect =  UIApplication.sharedApplication().keyWindow!.bounds
        
        container.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        container.center = CGPointMake(screenSize.width/2, screenSize.height/2)

            container.backgroundColor = UIColor(red: 234.0/255.0, green: 237.0/255.0, blue: 242.0/255.0, alpha: 0.5)
        
            loadingView.frame = CGRectMake(0, 0, 60, 60)
            loadingView.center = CGPointMake(screenSize.width/2, (screenSize.height-50)/2)
            
            loadingView.backgroundColor = UIColor.grayColor()
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            
            self.activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            self.activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
            
            loadingView.addSubview(self.activityIndicator)
            
            
        container.addSubview(loadingView)
        APPDELEGATE.window!!.addSubview(container)
        self.activityIndicator.startAnimating()
        
    }
    
    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
     
     @param uiView - remove activity indicator from this view
     */
    func hideActivityIndicator() {
        for view in loadingView.subviews {
            view.removeFromSuperview()
        }
        loadingView.removeFromSuperview()
        container.removeFromSuperview()
        self.activityIndicator.stopAnimating()
        
    }
    
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
                } else {
                    print(errorCode)
                    let alertController = UIAlertController (title: "Information", message: "Login faild, check your username and password!", preferredStyle: .Alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                        if let url = settingsUrl {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                    alertController.addAction(settingsAction)
                    alertController.addAction(cancelAction)
                    
                    self.APPDELEGATE.window!!.rootViewController!.presentViewController(alertController, animated: true, completion: nil);

                }
            })
            
        } else {
            print("Not logged in!")
        }
    }
    
    
    public func setupBubble () {
        let win = APPDELEGATE.window!!
        
        win.endEditing(true)
        print(UIApplication.sharedApplication().statusBarOrientation.rawValue)
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
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
               max = win.h - 500
            } else {
                max = win.h - 350
            }
            
        } else {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
                max = win.h - 430
            } else {
                max = win.h - 180
            }
        }
        
        let v = UIView (frame: CGRect (x: 0, y: 0, width: win.w, height: max!))
        v.backgroundColor = UIColor(red: 234/255, green: 237/255, blue: 242/255, alpha: 1.0)
        
        let title = UILabel(frame: CGRectZero)
        title.text = "Feedback"
        title.textColor = UIColor.darkGrayColor()
        title.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(title)
        
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 15))
        
        let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.addTarget(self, action: #selector(send), forControlEvents: .TouchUpInside)
        sendButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.borderWidth = 0.7
        sendButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        sendButton.layer.cornerRadius = 3.0
        v.addSubview(sendButton)
        
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 70))
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 10))
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: #selector(self.removeBubbleForce), forControlEvents: .TouchUpInside)
        closeButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.layer.borderWidth = 0.7
        closeButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        closeButton.layer.cornerRadius = 3.0
        v.addSubview(closeButton)
        
        
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 70))
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 10))
        
        textView.text = ""
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.darkGrayColor().CGColor
        textView.layer.borderWidth = 0.7
        v.addSubview(textView)
        
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 60))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: v, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -10))
        
        bubble.contentView = v
        
        win.addSubview(bubble)
        prevOrient = UIDeviceOrientation.FaceUp
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation){
            bubble.moveY(20.0)
            bubble.contentView?.moveY(20.0+bubble.size.height)
        } else {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad{
                bubble.moveY(-bubble.size.height)
                bubble.contentView?.moveY(20.0)
            } else {
                bubble.moveY(-bubble.size.height)
                bubble.contentView?.moveY(0.0)
            }
        }
    }
    
    func send(){
        if bubble.screenShot != nil{
            showActivityIndicator()
            CallApi().sendData(bubble.screenShot!, comment: textView.text) { (success, errorCode, msg) in
                if success {
                    print("send success")
                    self.removeBubble(true)
                    self.hideActivityIndicator()
                } else {
                    self.hideActivityIndicator()
                    let alert = UIAlertController(title: "Error", message: "The screenshot could not be sent!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    self.APPDELEGATE.window!!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else {
            hideActivityIndicator()
            let alert = UIAlertController(title: "Information", message: "The screenshot could not be taken!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            APPDELEGATE.window!!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    var prevOrient: UIDeviceOrientation = UIDeviceOrientation.FaceUp
    
    @objc private func removeBubbleForce (){
        removeBubble(true)
    }
    public func removeBubble(force: Bool = false){
        
        print(prevOrient.rawValue)
        if force {
            print("remove")
            if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
                bubble.closeContentView()
                viewWithTag.removeFromSuperview()
            }
        } else {
        if (prevOrient.isPortrait && UIDevice.currentDevice().orientation.isLandscape) || (prevOrient.isLandscape && UIDevice.currentDevice().orientation.isPortrait) {
            
            print("remove")
            if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
                bubble.closeContentView()
                viewWithTag.removeFromSuperview()
            }
        }
        if !UIDevice.currentDevice().orientation.isFlat{
            if prevOrient != UIDevice.currentDevice().orientation {
                prevOrient = UIDevice.currentDevice().orientation
            }
        }
        }
    }
}


