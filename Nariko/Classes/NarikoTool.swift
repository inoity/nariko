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
    var needReopen: Bool = false
    
    var textView = CustomTextView(frame: CGRect.zero)
    var textViewBackgroundView = UIView(frame: CGRect.zero)
    let textPlaceholderString = "Write your feedback here..."
    var firstKeyboardTime = true
    
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
        
        //  loadingView.backgroundColor = UIColor.gray
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = loadingView.layer.frame.size
        gradientLayer.colors = [UIColor.gradTop.cgColor, UIColor.gradBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        loadingView.layer.addSublayer(gradientLayer)
        
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkAuth), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.removeBubble), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        if UserDefaults.standard.string(forKey: "appAlreadyLaunched") == nil {
            
            isOnboarding = true
            let view = self.APPDELEGATE.window!!.rootViewController!.view
            
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            backgroundView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
            
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
                    
                    if finished {
                        self.narikoAlertView.removeFromSuperview()
                        
                        UserDefaults.standard.set(true, forKey: "appAlreadyLaunched")
                        self.narikoAlertView = OnboardingSecond.instanceFromNib() as! OnboardingSecond
                        self.narikoAlertView.frame = CGRect(x: ((view?.frame.width)! / 2) - (((view?.frame.width)! - 40)/2), y: ((view?.frame.height)! / 2) - (((view?.frame.height)! - 100)/2), width: (view?.frame.width)! - 40, height: (view?.frame.height)! - 100)
                        
                        self.narikoAlertView.clipsToBounds = true
                        
                        view?.addSubview(self.narikoAlertView)
                        
                        self.narikoAlertView.layoutIfNeeded()
                        
                        self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        
                        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                            self.backgroundView.alpha = 1
                            self.narikoAlertView.transform = CGAffineTransform.identity
                            }, completion: { (finished) in
                                if finished {
                                    self.needReopen = false
                                    self.perform(#selector(self.close), with: nil, afterDelay: 3)
                                }
                        })
                    }
            })
            
        default: break
            
        }
    }
    
    @objc fileprivate func close() {
       
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
            self.narikoAlertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: { (finished) in
                if finished{
                    isOnboarding = false
                    self.backgroundView.removeFromSuperview()
                    self.narikoAlertView.removeFromSuperview()
                    self.alertView.removeFromSuperview()
                    if self.needReopen{
                        self.setupBubble()
                    }
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
    
    open func registerSettingsBundle() {
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    
    open func checkAuth() {
        let defaults = UserDefaults.standard
        //   print(defaults.string(forKey: "nar_email"))
        //   print(defaults.string(forKey: "nar_pass"))
        
        //   print(Bundle.main.bundleIdentifier)
        
        if defaults.string(forKey: "nar_email") != nil && defaults.string(forKey: "nar_pass") != nil{
            
            CallApi().authRequest(["Email": defaults.string(forKey: "nar_email")! as AnyObject, "Password": defaults.string(forKey: "nar_pass")! as AnyObject, "BundleId": Bundle.main.bundleIdentifier! as AnyObject], callCompletion: { (success, errorCode, msg) in
                if success{
                    self.apiKey = msg
                   
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
        if APPDELEGATE.window!!.viewWithTag(3333) == nil{
            let win = APPDELEGATE.window!!
            
            win.endEditing(true)
            bubble = BubbleControl(win: win, size: CGSize(width: 130, height: 80))
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
                    self.bubble.contentView!.right = win.right
                } else {
                    self.bubble.contentView!.right = win.left
                    self.bubble.contentView!.left = win.left
                }
            }
            
            firstKeyboardTime = true
            // firstRot = true
            
            textViewBackgroundView.frame = CGRect(x: 0, y: 0, width: win.w, height: 41)
            textViewBackgroundView.backgroundColor = UIColor.white
            
            let topSeparatorView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
            topSeparatorView.backgroundColor = UIColor.lightGray
            textViewBackgroundView.addSubview(topSeparatorView)
            
            textView.delegate = self
            textView.layer.cornerRadius = 14
            
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1
            textView.autoresizingMask =  [.flexibleWidth]
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.textContainerInset = UIEdgeInsetsMake(4, 6, 4, 6)
            textView.scrollIndicatorInsets = UIEdgeInsetsMake(6, 6, 6, 6)
            textView.returnKeyType = .send
            textView.frame = CGRect(x: 16, y: 5, width: UIScreen.main.bounds.width - 32, height: 32)
            textViewBackgroundView.addSubview(textView)
            textPlaceholder()
            
            bubble.contentView = textViewBackgroundView
            
            win.addSubview(bubble)
        }
        //  prevOrient = UIDeviceOrientation.portrait
    }
    
    fileprivate func textPlaceholder() {
        textView.text = textPlaceholderString
        textView.textColor = UIColor.lightGray
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        textView.isEmpty = true
        
        updateTextHeight()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            send()
            return false
        }
        
        return true
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text  == "" {
            textPlaceholder()
        } else if self.textView.isEmpty && textView.text != "" {
            let textPlaceholderStringCount = textPlaceholderString.characters.count
            
            textView.text = textView.text.substring(to: textView.text.index(textView.text.endIndex, offsetBy: -textPlaceholderStringCount))
            textView.textColor = UIColor.black
            
            self.textView.isEmpty = false
            
            textView.selectedTextRange = textView.textRange(from: textView.endOfDocument, to: textView.endOfDocument)
        }
        
        updateTextHeight()
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if self.textView.isEmpty {
            textView.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    fileprivate func updateTextHeight() {
        let textViewHeight = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat(FLT_MAX))).height
        let textViewClampedHeight = max(28, min(96, textViewHeight))
        
        let heightDiff = textViewClampedHeight - textView.frame.height
        
        textView.isScrollEnabled = textViewClampedHeight == 96
        
        if textView.frame.height != textViewClampedHeight {
            UIView.animate(withDuration: 0.3) {
                self.textView.frame = CGRect(x: self.textView.frame.origin.x, y: 5, width: self.textView.frame.width, height: textViewClampedHeight)
                self.textViewBackgroundView.frame = CGRect(x: 0, y: self.textViewBackgroundView.frame.origin.y - heightDiff, width: UIScreen.main.bounds.width, height: textViewClampedHeight + 9)
                self.bubble.frame = CGRect(x: self.bubble.x, y: self.bubble.y - heightDiff, width: self.bubble.size.width, height: self.bubble.size.height)
            }
        }
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            var yOffset: CGFloat = 0
            
            if (endFrame?.origin.y)! < UIScreen.main.bounds.height {
                yOffset = endFrame!.size.height
            }
            
            if firstKeyboardTime {
                setContentViewKeyboardFrame(yOffset)
                if bubble != nil {
                    bubble.moveY(UIScreen.main.bounds.height - yOffset - textViewBackgroundView.frame.height - bubble.size.height)
                }
                
                firstKeyboardTime = false
            } else {
                UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
                    self.setContentViewKeyboardFrame(yOffset)
                    }, completion: nil)
                if bubble != nil {
                    bubble.moveY(UIScreen.main.bounds.height - yOffset - textViewBackgroundView.frame.height - bubble.size.height)
                }
            }
            
            if bubble != nil {
                self.bubble.moveX(UIScreen.main.bounds.width - self.bubble.size.width)
            }
        }
    }
    
    func setContentViewKeyboardFrame(_ yOffset: CGFloat) {
        self.textViewBackgroundView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - yOffset - self.textViewBackgroundView.frame.height, width: UIScreen.main.bounds.width, height: self.textViewBackgroundView.frame.height)
    }
    
    func send() {
        if bubble.screenShot != nil {
            showActivityIndicator()
            CallApi().sendData(bubble.screenShot!, comment: textView.text) { (success, errorCode, msg) in
                if success {
                    self.removeBubbleForce()
                    self.hideActivityIndicator()
                    let view = self.APPDELEGATE.window!!.rootViewController!.view
                    self.alertView = AlertView.instanceFromNib() as! AlertView
                    self.alertView.frame = CGRect(x: ((view?.frame.width)! / 2) - (((view?.frame.width)! - 40)/2), y: ((view?.frame.height)! / 2) - (((view?.frame.height)! - 100)/2), width: (view?.frame.width)! - 40, height: (view?.frame.height)! - 100)
                    self.alertView.clipsToBounds = true
                    self.alertView.updateUI(text1: "Your feedback has been submitted.", text2: "Thank you.")
                    
                    self.APPDELEGATE.window!!.rootViewController!.view?.addSubview(self.alertView)
                    self.alertView.layoutIfNeeded()
                    self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                        self.alertView.transform = CGAffineTransform.identity
                        
                        }, completion: { (finished) in
                            if finished{
                                self.needReopen = true
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
    
    var prevOrient: UIDeviceOrientation = UIDeviceOrientation.unknown
    var firstRot = true
    
    open func removeBubbleForce() {
        
        if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
            bubble.closeContentView()
            viewWithTag.removeFromSuperview()
        }
    }
    open func removeBubble(){
        
        if (prevOrient.isPortrait && UIDevice.current.orientation.isLandscape ) || (prevOrient.isLandscape && UIDevice.current.orientation.isPortrait) {
            
            if let viewWithTag = APPDELEGATE.window!!.viewWithTag(3333) {
                bubble.closeContentView()
                viewWithTag.removeFromSuperview()
                self.perform(#selector(self.setupBubble), with: nil, afterDelay: 0.1)
            }
        }
        if !UIDevice.current.orientation.isFlat{
            prevOrient = UIDevice.current.orientation
            
        }
    }
}

