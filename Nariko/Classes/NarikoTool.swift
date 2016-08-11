//
//  NarikoTool.swift
//  Nariko
//
//  Created by Zsolt Papp on 10/06/16.
//  Copyright © 2016 Nariko. All rights reserved.
//

import UIKit
import SwiftHTTP

public let okButton = UIButton()

public class NarikoTool: UIResponder, UITextViewDelegate {
    
    static public let sharedInstance = NarikoTool()
    
    var apiKey: String?
    
    let APPDELEGATE: UIApplicationDelegate = UIApplication.sharedApplication().delegate!
    
    let backgroundView = UIView()
    let narikoAlertView = UIView()
    
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
        
        if NSUserDefaults.standardUserDefaults().stringForKey("appAlreadyLaunched") == nil {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "appAlreadyLaunched")
            
            let view = self.APPDELEGATE.window!!.rootViewController!.view
            
            backgroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
            backgroundView.frame = view.frame
            view.addSubview(backgroundView)
            
            narikoAlertView.backgroundColor = UIColor.whiteColor()
            narikoAlertView.layer.cornerRadius = 20
            narikoAlertView.layer.shadowColor = UIColor.blackColor().CGColor
            narikoAlertView.layer.shadowOpacity = 1
            narikoAlertView.layer.shadowOffset = CGSizeZero
            narikoAlertView.layer.shadowRadius = 30
            
            let headline = UILabel()
            headline.text = "This app uses Nariko"
            headline.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
            headline.numberOfLines = 0
            headline.textColor = UIColorFromHex(0xEF4438)
            headline.textAlignment = .Center
            narikoAlertView.addSubview(headline)
            
            let spacer1 = UIView()
            narikoAlertView.addSubview(spacer1)
            
            let topDescription = UILabel()
            topDescription.text = "Hold 3 fingers for 3 seconds to activate Nariko."
            topDescription.font = UIFont(name: "HelveticaNeue", size: 16)
            topDescription.numberOfLines = 0
            topDescription.textColor = UIColorFromHex(0xEF4438)
            topDescription.textAlignment = .Center
            narikoAlertView.addSubview(topDescription)
            
            let spacer2 = UIView()
            narikoAlertView.addSubview(spacer2)
            
            let instructions = UIImageView()
            
            let podBundle = NSBundle(forClass: NarikoTool.self)
            
            if let url = podBundle.URLForResource("Nariko", withExtension: "bundle") {
                let bundle = NSBundle(URL: url)
                
                instructions.image = UIImage(named: "nariko_pic", inBundle: bundle, compatibleWithTraitCollection: nil)
            }
            
            narikoAlertView.addSubview(instructions)
            
            let spacer3 = UIView()
            narikoAlertView.addSubview(spacer3)
            
            let bottomDescription = UILabel()
            bottomDescription.text = "Tap the bubble to give feedback about the actual screen."
            bottomDescription.font = UIFont(name: "HelveticaNeue", size: 16)
            bottomDescription.numberOfLines = 0
            bottomDescription.textColor = UIColorFromHex(0xEF4438)
            bottomDescription.textAlignment = .Center
            narikoAlertView.addSubview(bottomDescription)
            
            let spacer4 = UIView()
            narikoAlertView.addSubview(spacer4)
            
            let okButtonInsets: CGFloat = 18
            
            okButton.setTitle("OK", forState: .Normal)
            okButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            okButton.setTitleColor(UIColorFromHex(0xEF4438), forState: .Normal)
            okButton.contentEdgeInsets = UIEdgeInsetsMake(okButtonInsets, okButtonInsets, okButtonInsets, okButtonInsets)
            narikoAlertView.addSubview(okButton)
            
            let spacers = [spacer1, spacer2, spacer3, spacer4]
            
            narikoAlertView.translatesAutoresizingMaskIntoConstraints = false
            headline.translatesAutoresizingMaskIntoConstraints = false
            spacer1.translatesAutoresizingMaskIntoConstraints = false
            topDescription.translatesAutoresizingMaskIntoConstraints = false
            spacer2.translatesAutoresizingMaskIntoConstraints = false
            instructions.translatesAutoresizingMaskIntoConstraints = false
            spacer3.translatesAutoresizingMaskIntoConstraints = false
            bottomDescription.translatesAutoresizingMaskIntoConstraints = false
            spacer4.translatesAutoresizingMaskIntoConstraints = false
            okButton.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(narikoAlertView)
            
            let outsideHorizontalMargin: CGFloat = 24
            let outsideVerticalMargin: CGFloat = 48
            
            view.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: outsideHorizontalMargin))
            view.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -outsideHorizontalMargin))
            view.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: outsideVerticalMargin))
            view.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -outsideVerticalMargin))
            
            let insideMargin: CGFloat = 24
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .Top, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Top, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .Leading, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .Trailing, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .Bottom, relatedBy: .Equal, toItem: spacer1, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer1, attribute: .Bottom, relatedBy: .Equal, toItem: topDescription, attribute: .Top, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .Leading, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .Trailing, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .Bottom, relatedBy: .Equal, toItem: spacer2, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer2, attribute: .Bottom, relatedBy: .Equal, toItem: instructions, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer2, attribute: .Height, relatedBy: .Equal, toItem: spacer1, attribute: .Height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 262))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .Height, relatedBy: .Equal, toItem: instructions, attribute: .Width, multiplier: 72/262, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .Leading, relatedBy: .GreaterThanOrEqual, toItem: narikoAlertView, attribute: .Leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .Trailing, relatedBy: .GreaterThanOrEqual, toItem: narikoAlertView, attribute: .Trailing, multiplier: 1, constant: -insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .CenterX, relatedBy: .Equal, toItem: narikoAlertView, attribute: .CenterX, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .Bottom, relatedBy: .Equal, toItem: spacer3, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer3, attribute: .Bottom, relatedBy: .Equal, toItem: bottomDescription, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer3, attribute: .Height, relatedBy: .Equal, toItem: spacer1, attribute: .Height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .Leading, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .Trailing, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .Bottom, relatedBy: .Equal, toItem: spacer4, attribute: .Top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer4, attribute: .Bottom, relatedBy: .Equal, toItem: okButton, attribute: .Top, multiplier: 1, constant: -insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer4, attribute: .Height, relatedBy: .Equal, toItem: spacer1, attribute: .Height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .CenterX, relatedBy: .Equal, toItem: narikoAlertView, attribute: .CenterX, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .Bottom, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Bottom, multiplier: 1, constant: -insideMargin / 2))
            
            for spacer in spacers {
                narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer, attribute: .Leading, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Leading, multiplier: 1, constant: 0))
                narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer, attribute: .Trailing, relatedBy: .Equal, toItem: narikoAlertView, attribute: .Trailing, multiplier: 1, constant: 0))
            }
            
            narikoAlertView.layoutIfNeeded()
            
            backgroundView.alpha = 0
            narikoAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {() -> Void in
                self.backgroundView.alpha = 1
                self.narikoAlertView.transform = CGAffineTransformIdentity
                }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    
    public func closeNarikoAlertView() {
        narikoAlertView.transform = CGAffineTransformIdentity
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {() -> Void in
            self.backgroundView.alpha = 0
            self.narikoAlertView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }, completion: {(finished: Bool) -> Void in
                self.backgroundView.removeFromSuperview()
                self.narikoAlertView.removeFromSuperview()
        })
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
                    let alertController = UIAlertController (title: "Information", message: "Login failed, check your username and password!", preferredStyle: .Alert)
                    
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
            bubble.image = UIImage(named: "nariko_logo", inBundle: bundle, compatibleWithTraitCollection: nil)
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
                    let alert = UIAlertController(title: "Information", message: "Your ticket has been sent successfuly!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    self.APPDELEGATE.window!!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
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