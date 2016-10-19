//
//  BubbleControl.swift
//  BubbleControl-Swift
//
//  Created by Cem Olcay on 11/12/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit

// MARK: - Animation Constants

private let BubbleControlMoveAnimationDuration: TimeInterval = 0.5
private let BubbleControlSpringDamping: CGFloat = 0.6
private let BubbleControlSpringVelocity: CGFloat = 0.6

let closeButton = UIButton(frame: CGRect(x: 0, y: 20, width: 40, height: 40))

// MARK: - UIView Extension

extension UIView {
    
    
    // MARK: Frame Extensions
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        } set (value) {
            self.frame = CGRect (x: value, y: self.y, width: self.w, height: self.h)
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        } set (value) {
            self.frame = CGRect (x: self.x, y: value, width: self.w, height: self.h)
        }
    }
    
    var w: CGFloat {
        get {
            return self.frame.size.width
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: value, height: self.h)
        }
    }
    
    var h: CGFloat {
        get {
            return self.frame.size.height
        } set (value) {
            self.frame = CGRect (x: self.x, y: self.y, width: self.w, height: value)
        }
    }
    
    
    var position: CGPoint {
        get {
            return self.frame.origin
        } set (value) {
            self.frame = CGRect (origin: value, size: self.frame.size)
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        } set (value) {
            self.frame = CGRect (origin: self.frame.origin, size: size)
        }
    }
    
    
    var left: CGFloat {
        get {
            return self.x
        } set (value) {
            self.x = value
        }
    }
    
    var right: CGFloat {
        get {
            return self.x + self.w
        } set (value) {
            self.x = value - self.w
        }
    }
    
    var top: CGFloat {
        get {
            return self.y
        } set (value) {
            self.y = value
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.y + self.h
        } set (value) {
            self.y = value - self.h
        }
    }
    
    
    
    func leftWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    func rightWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    func topWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    func botttomWithOffset (_ offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
    
    
    
    func spring (_ animations: @escaping ()->Void, completion:((Bool)->Void)?) {
        UIView.animate(withDuration: BubbleControlMoveAnimationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: BubbleControlSpringDamping,
                                   initialSpringVelocity: BubbleControlSpringVelocity,
                                   options: UIViewAnimationOptions(),
                                   animations: animations,
                                   completion: completion)
    }
    
    
    func moveY (_ y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.y = y
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func moveX (_ x: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (_ x: CGFloat, y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        moveRect.origin.y = y
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (_ point: CGPoint) {
        var moveRect = self.frame
        moveRect.origin = point
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    
    func setScale(_ s: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, s, s, s)
        
        self.layer.transform = transform
    }
    
    func alphaTo(_ to: CGFloat) {
        UIView.animate(withDuration: BubbleControlMoveAnimationDuration,
                                   animations: {
                                    self.alpha = to
        })
    }
    
    func bubble() {
        
        self.setScale(1.2)
        spring({ () -> Void in
            self.setScale(1)
            }, completion: nil)
    }
}


// MARK: - BubbleControl

class BubbleControl: UIControl {
    
    var WINDOW: UIWindow?
    
    var screenShot: UIImage?
    
    // MARK: Constants
    
    let snapOffsetMin: CGFloat = 0
    let snapOffsetMax: CGFloat = 0
    
    // MARK: Optionals
    
    var contentView: UIView?
    var snapsInside: Bool = false
    var movesBottom: Bool = false
    
    // MARK: Actions
    
    var didToggle: ((Bool) -> ())?
    var didNavigationBarButtonPressed: (() -> ())?
    
    var setOpenAnimation: ((_ contentView: UIView, _ backgroundView: UIView?)->())?
    var setCloseAnimation: ((_ contentView: UIView, _ backgroundView: UIView?) -> ())?
    
    // MARK: Bubble State
    
    enum BubbleControlState {
        case snap       // snapped to edge
        case drag       // dragging around
    }
    
    var bubbleState: BubbleControlState = .snap {
        didSet {
            if bubbleState == .snap {
                setupSnapInsideTimer()
            } else {
                snapOffset = snapOffsetMin
            }
        }
    }
    
    // MARK: Snap
    
    fileprivate var snapOffset: CGFloat!
    fileprivate var snapInTimer: Timer?
    fileprivate var snapInInterval: TimeInterval = 2
    
    // MARK: Toggle
    
    fileprivate var positionBeforeToggle: CGPoint?
    
    var toggle: Bool = false {
        didSet {
            didToggle? (toggle)
            if toggle {
                openContentView()
            } else {
                closeContentView()
            }
        }
    }
    
    // MARK: Image
    
    var imageView: UIImageView?
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    // MARK: Init
    
    init (win: UIWindow, size: CGSize) {
        super.init(frame: CGRect (origin: CGPoint.zero, size: size))
        defaultInit(win)
    }
    
    init (win: UIWindow, image: UIImage) {
        let size = image.size
        super.init(frame: CGRect (origin: CGPoint.zero, size: size))
        self.image = image
        
        defaultInit(win)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    func defaultInit (_ win: UIWindow) {
        
        self.WINDOW = win
        
        // self
        snapOffset = snapOffsetMin
        layer.cornerRadius = w/2
        
        // image view
        imageView = UIImageView(frame:CGRect(x: 50, y: 0, width: size.width - 50, height: size.height))
        imageView?.isUserInteractionEnabled = false
        imageView?.clipsToBounds = true
        
        addSubview(imageView!)
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel!.font = UIFont.systemFont(ofSize: 16)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.backgroundColor = UIColor.black
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(NarikoTool.sharedInstance, action: #selector(NarikoTool.removeBubbleForce), for: .touchUpInside)
        closeButton.isHidden = true
        
        addSubview(closeButton)
        
        // events
        addTarget(self, action: #selector(BubbleControl.touchDown), for: UIControlEvents.touchDown)
        addTarget(self, action: #selector(BubbleControl.touchUp), for: UIControlEvents.touchUpInside)
        addTarget(self, action: #selector(BubbleControl.touchDrag(_:event:)), for: UIControlEvents.touchDragInside)
        
        // place
        center.x = WINDOW!.w - w/2 + snapOffset
        center.y = 84 + h/2
        snap()
    }
    
    
    
    // MARK: Snap To Edge
    
    func snap() {
        
        var targetX = WINDOW!.leftWithOffset(snapOffset + 50)
        
        if center.x > WINDOW!.w/2 {
            targetX = WINDOW!.rightWithOffset(snapOffset) - w
        }
        
        // move to snap position
        moveX(targetX)
    }
    
    func snapInside() {
        print("snap inside !")
        if !toggle && bubbleState == .snap {
            snapOffset = snapOffsetMax
            snap()
        }
    }
    
    func setupSnapInsideTimer() {
        if !snapsInside {
            return
        }
        
        if let timer = snapInTimer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        
        snapInTimer = Timer.scheduledTimer(timeInterval: snapInInterval,
                                                             target: self,
                                                             selector: #selector(BubbleControl.snapInside),
                                                             userInfo: nil,
                                                             repeats: false)
    }
    
    
    func lockInWindowBounds() {
        
        if top < 64 {
            var rect = frame
            rect.origin.y = 64
            frame = rect
        }
        
        if left < -50 {
            var rect = frame
            rect.origin.x = -50
            frame = rect
        }
        
        if bottom > WINDOW!.h {
            var rect = frame
            rect.origin.y = WINDOW!.botttomWithOffset(-h)
            frame = rect
        }
        
        if right > WINDOW!.w {
            var rect = frame
            rect.origin.x = WINDOW!.rightWithOffset(-w)
            frame = rect
        }
    }
    
    // MARK: Events
    
    func touchDown() {
        bubble()
    }
    
    func touchUp() {
        if bubbleState == .snap {
            toggle = !toggle
        } else {
            bubbleState = .snap
            snap()
        }
    }
    
    func touchDrag (_ sender: BubbleControl, event: UIEvent) {
        if closeButton.isHidden {
            bubbleState = .drag
            
            if toggle {
                toggle = false
            }
            
            let touch = event.allTouches!.first!
            let location = touch.location(in: WINDOW!)
            
            center = location
            lockInWindowBounds()
        }
    }
    
    
    func navButtonPressed (_ sender: AnyObject) {
        didNavigationBarButtonPressed? ()
    }
    
    func degreesToRadians (_ angle: CGFloat) -> CGFloat {
        return (CGFloat (M_PI) * angle) / 180.0
    }
    
    
    // MARK: Toggle
    
    func openContentView() {
        if let v = contentView {
            screenShotMethod()
            let win = WINDOW!
            win.addSubview(v)
            win.bringSubview(toFront: self)
            
            snapOffset = snapOffsetMin
            snap()
            positionBeforeToggle = frame.origin
            
            if let anim = setOpenAnimation {
                anim(v, win.subviews[0])
            } else {
                v.bottom = win.bottom
            }
            
            if movesBottom {
                movePoint(CGPoint (x: win.center.x - w/2, y: win.bottom - h - snapOffset))
            } else {
                moveY(v.top - h - snapOffset)
            }
            
            closeButton.isHidden = false
            NarikoTool.sharedInstance.textView.becomeFirstResponder()
        }
    }
    
    func screenShotMethod() {
        //Create the UIImage
        print("shot")
        self.isHidden = true
        UIGraphicsBeginImageContext(WINDOW!.frame.size)
        WINDOW!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print(image)
        screenShot = image
        //Save it to the camera roll
        //  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isHidden = false
    }
    
    func closeContentView() {
        if let v = contentView {
            
            if let anim = setCloseAnimation {
                anim (v, (WINDOW?.subviews[0])! as UIView)
            } else {
                v.removeFromSuperview()
            }
            
            if (bubbleState == .snap) {
                setupSnapInsideTimer()
                if positionBeforeToggle != nil {
                    movePoint(positionBeforeToggle!)
                }
            }
        }
        
        closeButton.isHidden = true
    }
}
