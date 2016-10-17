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

open class NarikoTool: UIResponder, UITextViewDelegate {
    
    static open let sharedInstance = NarikoTool()
    
    var apiKey: String?
    
    let APPDELEGATE: UIApplicationDelegate = UIApplication.shared.delegate!
    
    let backgroundView = UIView()
    var narikoAlertView = UIView()
    
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
        
        if UserDefaults.standard.string(forKey: "appAlreadyLaunched") != nil {
            UserDefaults.standard.set(true, forKey: "appAlreadyLaunched")
            
            let view = self.APPDELEGATE.window!!.rootViewController!.view
            
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            backgroundView.frame = (view?.frame)!
            view?.addSubview(backgroundView)
            
            
            //narikoAlertView = OnboardingFirst()
            
            
            narikoAlertView = OnboardingFirst.instanceFromNib() as! OnboardingFirst
            
            //    OnboardingFirst(frame: CGRect(x: 20, y: 40, width: (view?.frame.width)! - 40, height: (view?.frame.height)! - 80))
            
          /*   narikoAlertView.translatesAutoresizingMaskIntoConstraints = false
            let outsideHorizontalMargin: CGFloat = 24
            let outsideVerticalMargin: CGFloat = 48
            
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: outsideHorizontalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -outsideHorizontalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: outsideVerticalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -outsideVerticalMargin))*/
            
            /*
            
            narikoAlertView.backgroundColor = UIColor.white
            narikoAlertView.layer.cornerRadius = 20
            narikoAlertView.layer.shadowColor = UIColor.black.cgColor
            narikoAlertView.layer.shadowOpacity = 1
            narikoAlertView.layer.shadowOffset = CGSize.zero
            narikoAlertView.layer.shadowRadius = 30
            
            let headline = UILabel()
            headline.text = "This app uses Nariko"
            headline.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
            headline.numberOfLines = 0
            headline.textColor = UIColorFromHex(0xEF4438)
            headline.textAlignment = .center
            narikoAlertView.addSubview(headline)
            
            let spacer1 = UIView()
            narikoAlertView.addSubview(spacer1)
            
            let topDescription = UILabel()
            topDescription.text = "Hold 3 fingers for 3 seconds to activate Nariko."
            topDescription.font = UIFont(name: "HelveticaNeue", size: 16)
            topDescription.numberOfLines = 0
            topDescription.textColor = UIColorFromHex(0xEF4438)
            topDescription.textAlignment = .center
            narikoAlertView.addSubview(topDescription)
            
            let spacer2 = UIView()
            narikoAlertView.addSubview(spacer2)
            
            let instructions = UIImageView()
            
            let podBundle = Bundle(for: NarikoTool.self)
            
            if let url = podBundle.url(forResource: "Nariko", withExtension: "bundle") {
                let bundle = Bundle(url: url)
                
                instructions.image = UIImage(named: "nariko_pic", in: bundle, compatibleWith: nil)
            }
            
            narikoAlertView.addSubview(instructions)
            
            let spacer3 = UIView()
            narikoAlertView.addSubview(spacer3)
            
            let bottomDescription = UILabel()
            bottomDescription.text = "Tap the bubble to give feedback about the actual screen."
            bottomDescription.font = UIFont(name: "HelveticaNeue", size: 16)
            bottomDescription.numberOfLines = 0
            bottomDescription.textColor = UIColorFromHex(0xEF4438)
            bottomDescription.textAlignment = .center
            narikoAlertView.addSubview(bottomDescription)
            
            let spacer4 = UIView()
            narikoAlertView.addSubview(spacer4)
            
            let okButtonInsets: CGFloat = 18
            
            okButton.setTitle("OK", for: UIControlState())
            okButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            okButton.setTitleColor(UIColorFromHex(0xEF4438), for: UIControlState())
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
            
            view?.addSubview(narikoAlertView)
            
            let outsideHorizontalMargin: CGFloat = 24
            let outsideVerticalMargin: CGFloat = 48
            
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: outsideHorizontalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -outsideHorizontalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: outsideVerticalMargin))
            view?.addConstraint(NSLayoutConstraint(item: narikoAlertView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -outsideVerticalMargin))
            
            let insideMargin: CGFloat = 24
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .top, relatedBy: .equal, toItem: narikoAlertView, attribute: .top, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .leading, relatedBy: .equal, toItem: narikoAlertView, attribute: .leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .trailing, relatedBy: .equal, toItem: narikoAlertView, attribute: .trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: headline, attribute: .bottom, relatedBy: .equal, toItem: spacer1, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer1, attribute: .bottom, relatedBy: .equal, toItem: topDescription, attribute: .top, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .leading, relatedBy: .equal, toItem: narikoAlertView, attribute: .leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .trailing, relatedBy: .equal, toItem: narikoAlertView, attribute: .trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: topDescription, attribute: .bottom, relatedBy: .equal, toItem: spacer2, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer2, attribute: .bottom, relatedBy: .equal, toItem: instructions, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer2, attribute: .height, relatedBy: .equal, toItem: spacer1, attribute: .height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 262))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .height, relatedBy: .equal, toItem: instructions, attribute: .width, multiplier: 72/262, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: narikoAlertView, attribute: .leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: narikoAlertView, attribute: .trailing, multiplier: 1, constant: -insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .centerX, relatedBy: .equal, toItem: narikoAlertView, attribute: .centerX, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: instructions, attribute: .bottom, relatedBy: .equal, toItem: spacer3, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer3, attribute: .bottom, relatedBy: .equal, toItem: bottomDescription, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer3, attribute: .height, relatedBy: .equal, toItem: spacer1, attribute: .height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .leading, relatedBy: .equal, toItem: narikoAlertView, attribute: .leading, multiplier: 1, constant: insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .trailing, relatedBy: .equal, toItem: narikoAlertView, attribute: .trailing, multiplier: 1, constant: -insideMargin))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: bottomDescription, attribute: .bottom, relatedBy: .equal, toItem: spacer4, attribute: .top, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer4, attribute: .bottom, relatedBy: .equal, toItem: okButton, attribute: .top, multiplier: 1, constant: -insideMargin))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer4, attribute: .height, relatedBy: .equal, toItem: spacer1, attribute: .height, multiplier: 1, constant: 0))
            
            narikoAlertView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .centerX, relatedBy: .equal, toItem: narikoAlertView, attribute: .centerX, multiplier: 1, constant: 0))
            narikoAlertView.addConstraint(NSLayoutConstraint(item: okButton, attribute: .bottom, relatedBy: .equal, toItem: narikoAlertView, attribute: .bottom, multiplier: 1, constant: -insideMargin / 2))
            
            for spacer in spacers {
                narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer, attribute: .leading, relatedBy: .equal, toItem: narikoAlertView, attribute: .leading, multiplier: 1, constant: 0))
                narikoAlertView.addConstraint(NSLayoutConstraint(item: spacer, attribute: .trailing, relatedBy: .equal, toItem: narikoAlertView, attribute: .trailing, multiplier: 1, constant: 0))
            }
            */
            
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
    
    
    open func setupBubble () {
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
                    let alert = UIAlertController(title: "Information", message: "Your ticket has been sent successfuly!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                    self.APPDELEGATE.window!!.rootViewController!.present(alert, animated: true, completion: nil)
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
