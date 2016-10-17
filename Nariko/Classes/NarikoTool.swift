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

open class NarikoTool: UIResponder, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    static open let sharedInstance = NarikoTool()
    
    var apiKey: String?
    
    let APPDELEGATE: UIApplicationDelegate = UIApplication.shared.delegate!
    
    let backgroundView = UIView()
    var narikoAlertView = UIView()
    var alertView = AlertView()
    
    var bubble: BubbleControl!
    var isAuth: Bool = false
    var WINDOW: UIWindow?
    var textView: UITextView = UITextView(frame: CGRect.zero)
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func showActivityIndicator() {
        let screenSize: CGRect =  UIApplication.shared.keyWindow!.bounds
        
        container.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        container.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        
        container.backgroundColor = UIColor(red: 234.0/255.0, green: 237.0/255.0, blue: 242.0/255.0, alpha: 0.5)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = CGPoint(x: screenSize.width/2, y: (screenSize.height-50)/2)
        
        loadingView.backgroundColor = UIColor.gray
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkAuth), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBubble), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        if UserDefaults.standard.string(forKey: "appAlreadyLaunched") == nil {
           
            isOnboarding = true
            let view = self.APPDELEGATE.window!!.rootViewController!.view
            
            print("recog")
            print(view?.gestureRecognizers)
            
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            backgroundView.frame = (view?.frame)!
            view?.addSubview(backgroundView)
            
            narikoAlertView = OnboardingFirst.instanceFromNib() as! OnboardingFirst
            narikoAlertView.frame = CGRect(x: 20, y: 40, width: (view?.frame.width)! - 40, height: (view?.frame.height)! - 80)
            narikoAlertView.clipsToBounds = true
            
            let longPressRecog = UILongPressGestureRecognizer()
            
            longPressRecog.addTarget(self, action: #selector(tap(_:)))
            longPressRecog.minimumPressDuration = 1.5
            longPressRecog.numberOfTouchesRequired = 3
            longPressRecog.delegate = self
            
            
            narikoAlertView.addGestureRecognizer(longPressRecog)
            
            view?.addSubview(narikoAlertView)
            
            
            narikoAlertView.layoutIfNeeded()
            
            backgroundView.alpha = 0
            narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                self.backgroundView.alpha = 1
                self.narikoAlertView.transform = CGAffineTransform.identity
                }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    
    @objc fileprivate func tap(_ g: UILongPressGestureRecognizer) {
        
        
        switch g.state {
            
        case .began:
            let view = self.APPDELEGATE.window!!.rootViewController!.view
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                
                }, completion: { (finished) in
                    
                    if finished{
                        self.narikoAlertView.removeFromSuperview()
                      
                        UserDefaults.standard.set(true, forKey: "appAlreadyLaunched")
                        self.narikoAlertView = OnboardingSecond.instanceFromNib() as! OnboardingSecond
                        self.narikoAlertView.frame = CGRect(x: ((view?.frame.width)! / 2) - (((view?.frame.width)! - 40)/2), y: (view?.frame.height)! / 2 - 200, width: (view?.frame.width)! - 40, height: 400)
                      
                        self.narikoAlertView.clipsToBounds = true
                        
                        view?.addSubview(self.narikoAlertView)
                        
                        self.narikoAlertView.layoutIfNeeded()
                        
                        self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                            self.backgroundView.alpha = 1
                            self.narikoAlertView.transform = CGAffineTransform.identity
                            }, completion: { (finished) in
                                if finished{
                                    self.perform(#selector(self.close), with: nil, afterDelay: 3)
                                }
                        })
                    }
            })
            
        default: break
            
        }
    }
    
   @objc fileprivate func close(){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished) in
                if finished{
                    isOnboarding = false
                    self.backgroundView.removeFromSuperview()
                    self.narikoAlertView.removeFromSuperview()
                    self.alertView.removeFromSuperview()
                    
                }
        })
    }
    
    open func closeNarikoAlertView() {
        narikoAlertView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.backgroundView.alpha = 0
            self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: {(finished: Bool) -> Void in
                self.backgroundView.removeFromSuperview()
                self.narikoAlertView.removeFromSuperview()
        })
    }
    
    deinit { //Not needed for iOS9 and above. ARC deals with the observer.
        NotificationCenter.default.removeObserver(self)
    }
    
    open func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    open func checkAuth(){
        let defaults = UserDefaults.standard
        print(defaults.string(forKey: "nar_email"))
        print(defaults.string(forKey: "nar_pass"))
        
        print(Bundle.main.bundleIdentifier)
        
        if defaults.string(forKey: "nar_email") != nil && defaults.string(forKey: "nar_pass") != nil{
            print("check auth")
            CallApi().authRequest(["Email": defaults.string(forKey: "nar_email")! as AnyObject, "Password": defaults.string(forKey: "nar_pass")! as AnyObject, "BundleId": Bundle.main.bundleIdentifier! as AnyObject], callCompletion: { (success, errorCode, msg) in
                if success{
                    self.apiKey = msg
                    print("OOOKKK")
                    self.isAuth = true
                } else {
                    print(errorCode)
                    let alertController = UIAlertController (title: "Information", message: "Login failed, check your username and password!", preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                        if let url = settingsUrl {
                            UIApplication.shared.openURL(url)
                        }
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(settingsAction)
                    alertController.addAction(cancelAction)
                    
                    self.APPDELEGATE.window!!.rootViewController!.present(alertController, animated: true, completion: nil);
                    
                }
            })
            
        } else {
            print("Not logged in!")
        }
    }
    
    open func setupBubble() {
        let win = APPDELEGATE.window!!
        
        win.endEditing(true)
        print(UIApplication.shared.statusBarOrientation.rawValue)
        bubble = BubbleControl (win: win, size: CGSize(width: 80, height: 80))
        bubble.tag = 3333
        
        let podBundle = Bundle(for: NarikoTool.self)
        if let url = podBundle.url(forResource: "Nariko", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            bubble.image = UIImage(named: "Nariko_logo_200", in: bundle, compatibleWith: nil)
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
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation){
            if UIDevice.current.userInterfaceIdiom == .pad{
                max = win.h - 500
            } else {
                max = win.h - 350
            }
            
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad{
                max = win.h - 430
            } else {
                max = win.h - 180
            }
        }
        
        let v = UIView (frame: CGRect (x: 0, y: 0, width: win.w, height: max!))
        v.backgroundColor = UIColor(red: 234/255, green: 237/255, blue: 242/255, alpha: 1.0)
        
        let title = UILabel(frame: CGRect.zero)
        title.text = "Feedback"
        title.textColor = UIColor.darkGray
        title.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(title)
        
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        v.addConstraint(NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 15))
        
        let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        sendButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.borderWidth = 0.7
        sendButton.layer.borderColor = UIColor.darkGray.cgColor
        sendButton.layer.cornerRadius = 3.0
        v.addSubview(sendButton)
        
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70))
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: sendButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10))
        
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 20))
        closeButton.setTitle("Close", for: UIControlState())
        closeButton.addTarget(self, action: #selector(self.removeBubbleForce), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.darkGray, for: UIControlState())
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.layer.borderWidth = 0.7
        closeButton.layer.borderColor = UIColor.darkGray.cgColor
        closeButton.layer.cornerRadius = 3.0
        v.addSubview(closeButton)
        
        
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70))
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: closeButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 10))
        
        textView.text = ""
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.darkGray.cgColor
        textView.layer.borderWidth = 0.7
        v.addSubview(textView)
        
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 15))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 60))
        v.addConstraint(NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: v, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -10))
        
        bubble.contentView = v
        
        win.addSubview(bubble)
        prevOrient = UIDeviceOrientation.faceUp
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation){
            bubble.moveY(20.0)
            bubble.contentView?.moveY(20.0+bubble.size.height)
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad{
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
                    let view = self.APPDELEGATE.window!!.rootViewController!.view
                    self.alertView = AlertView.instanceFromNib() as! AlertView
                    self.alertView.frame = CGRect(x: ((view?.frame.width)! / 2) - (((view?.frame.width)! - 40)/2), y: (view?.frame.height)! / 2 - 150, width: (view?.frame.width)! - 40, height: 300)
                    self.alertView.clipsToBounds = true
                    self.alertView.updateUI(text1: "Your feedback has been submitted.", text2: "Thank you.")
                    
                    self.APPDELEGATE.window!!.rootViewController!.view?.addSubview(self.alertView)
                    self.alertView.layoutIfNeeded()
                    self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                        self.alertView.transform = CGAffineTransform.identity
                        
                        }, completion: { (finished) in
                            if finished{
                                self.perform(#selector(self.close), with: nil, afterDelay: 3)
                            
                            }
                    })

                } else {
                    self.hideActivityIndicator()
                    let alert = UIAlertController(title: "Error", message: "The screenshot could not be sent!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                    self.APPDELEGATE.window!!.rootViewController!.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            hideActivityIndicator()
            let alert = UIAlertController(title: "Information", message: "The screenshot could not be taken!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            APPDELEGATE.window!!.rootViewController!.present(alert, animated: true, completion: nil)
        }
    }
    
    var prevOrient: UIDeviceOrientation = UIDeviceOrientation.faceUp
    
    @objc fileprivate func removeBubbleForce (){
        removeBubble(true)
    }
    open func removeBubble(_ force: Bool = false){
        
        print(prevOrient.rawValue)
        if force {
            print("remove")
            if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
                bubble.closeContentView()
                viewWithTag.removeFromSuperview()
            }
        } else {
            if (prevOrient.isPortrait && UIDevice.current.orientation.isLandscape) || (prevOrient.isLandscape && UIDevice.current.orientation.isPortrait) {
                
                print("remove")
                if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
                    bubble.closeContentView()
                    viewWithTag.removeFromSuperview()
                }
            }
            if !UIDevice.current.orientation.isFlat{
                if prevOrient != UIDevice.current.orientation {
                    prevOrient = UIDevice.current.orientation
                }
            }
        }
    }
}
