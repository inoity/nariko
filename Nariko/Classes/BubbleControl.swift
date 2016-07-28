//
//  BubbleControl.swift
//  BubbleControl-Swift
//
//  Created by Cem Olcay on 11/12/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit

// MARK: - Animation Constants

private let BubbleControlMoveAnimationDuration: NSTimeInterval = 0.5
private let BubbleControlSpringDamping: CGFloat = 0.6
private let BubbleControlSpringVelocity: CGFloat = 0.6


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
    
    
    
    func leftWithOffset (offset: CGFloat) -> CGFloat {
        return self.left - offset
    }
    
    func rightWithOffset (offset: CGFloat) -> CGFloat {
        return self.right + offset
    }
    
    func topWithOffset (offset: CGFloat) -> CGFloat {
        return self.top - offset
    }
    
    func botttomWithOffset (offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }
    
    
    
    func spring (animations: ()->Void, completion:((Bool)->Void)?) {
        UIView.animateWithDuration(BubbleControlMoveAnimationDuration,
                                   delay: 0,
                                   usingSpringWithDamping: BubbleControlSpringDamping,
                                   initialSpringVelocity: BubbleControlSpringVelocity,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: animations,
                                   completion: completion)
    }
    
    
    func moveY (y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.y = y
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func moveX (x: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (x: CGFloat, y: CGFloat) {
        var moveRect = self.frame
        moveRect.origin.x = x
        moveRect.origin.y = y
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    func movePoint (point: CGPoint) {
        var moveRect = self.frame
        moveRect.origin = point
        
        spring({ () -> Void in
            self.frame = moveRect
            }, completion: nil)
    }
    
    
    func setScale (s: CGFloat) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DScale(transform, s, s, s)
        
        self.layer.transform = transform
    }
    
    func alphaTo (to: CGFloat) {
        UIView.animateWithDuration(BubbleControlMoveAnimationDuration,
                                   animations: {
                                    self.alpha = to
        })
    }
    
    func bubble () {
        
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
    
    var setOpenAnimation: ((contentView: UIView, backgroundView: UIView?)->())?
    var setCloseAnimation: ((contentView: UIView, backgroundView: UIView?) -> ())?
    
    // MARK: Bubble State
    
    enum BubbleControlState {
        case Snap       // snapped to edge
        case Drag       // dragging around
    }
    
    var bubbleState: BubbleControlState = .Snap {
        didSet {
            if bubbleState == .Snap {
                setupSnapInsideTimer()
            } else {
                snapOffset = snapOffsetMin
            }
        }
    }
    
    // MARK: Snap
    
    private var snapOffset: CGFloat!
    private var snapInTimer: NSTimer?
    private var snapInInterval: NSTimeInterval = 2
    
    // MARK: Toggle
    
    private var positionBeforeToggle: CGPoint?
    
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
        super.init(frame: CGRect (origin: CGPointZero, size: size))
        defaultInit(win)
    }
    
    init (win: UIWindow, image: UIImage) {
        let size = image.size
        super.init(frame: CGRect (origin: CGPointZero, size: size))
        self.image = image
        
        defaultInit(win)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    func defaultInit (win: UIWindow) {
        
        self.WINDOW = win
        
        // self
        snapOffset = snapOffsetMin
        layer.cornerRadius = w/2
        
        // image view
        imageView = UIImageView (frame: CGRectInset(frame, 0, 0))
        imageView?.clipsToBounds = true
        
        // circle border
        let borderView = UIView (frame: frame)
        borderView.layer.borderColor = UIColor.blackColor().CGColor
        borderView.layer.borderWidth = 2
        borderView.layer.cornerRadius = w/2
        borderView.layer.masksToBounds = true
        borderView.userInteractionEnabled = false
        borderView.clipsToBounds = true
        
        borderView.addSubview(imageView!)
        
        addSubview(borderView)
        
        // events
        addTarget(self, action: #selector(BubbleControl.touchDown), forControlEvents: UIControlEvents.TouchDown)
        addTarget(self, action: #selector(BubbleControl.touchUp), forControlEvents: UIControlEvents.TouchUpInside)
        addTarget(self, action: #selector(BubbleControl.touchDrag(_:event:)), forControlEvents: UIControlEvents.TouchDragInside)
        
        // place
        center.x = WINDOW!.w - w/2 + snapOffset
        center.y = 84 + h/2
        snap()
    }
    
    
    
    // MARK: Snap To Edge
    
    func snap () {
        
        var targetX = WINDOW!.leftWithOffset(snapOffset)
        
        if center.x > WINDOW!.w/2 {
            targetX = WINDOW!.rightWithOffset(snapOffset) - w
        }
        
        // move to snap position
        moveX(targetX)
    }
    
    func snapInside () {
        print("snap inside !")
        if !toggle && bubbleState == .Snap {
            snapOffset = snapOffsetMax
            snap()
        }
    }
    
    func setupSnapInsideTimer () {
        if !snapsInside {
            return
        }
        
        if let timer = snapInTimer {
            if timer.valid {
                timer.invalidate()
            }
        }
        
        snapInTimer = NSTimer.scheduledTimerWithTimeInterval(snapInInterval,
                                                             target: self,
                                                             selector: #selector(BubbleControl.snapInside),
                                                             userInfo: nil,
                                                             repeats: false)
    }
    
    
    func lockInWindowBounds () {
        
        if top < 64 {
            var rect = frame
            rect.origin.y = 64
            frame = rect
        }
        
        if left < 0 {
            var rect = frame
            rect.origin.x = 0
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
    
    func touchDown () {
        bubble()
    }
    
    func touchUp () {
        if bubbleState == .Snap {
            toggle = !toggle
        } else {
            bubbleState = .Snap
            snap()
        }
    }
    
    func touchDrag (sender: BubbleControl, event: UIEvent) {
        bubbleState = .Drag
        
        if toggle {
            toggle = false
        }
        
        let touch = event.allTouches()!.first!
        let location = touch.locationInView(WINDOW!)
        
        center = location
        lockInWindowBounds()
    }
    
    
    func navButtonPressed (sender: AnyObject) {
        didNavigationBarButtonPressed? ()
    }
    
    func degreesToRadians (angle: CGFloat) -> CGFloat {
        return (CGFloat (M_PI) * angle) / 180.0
    }
    
    
    // MARK: Toggle
    
    func openContentView () {
        if let v = contentView {
            screenShotMethod()
            let win = WINDOW!
            win.addSubview(v)
            win.bringSubviewToFront(self)
            
            snapOffset = snapOffsetMin
            snap()
            positionBeforeToggle = frame.origin
            
            if let anim = setOpenAnimation {
                anim (contentView: v, backgroundView: win.subviews[0])
            } else {
                v.bottom = win.bottom
            }
            
            if movesBottom {
                movePoint(CGPoint (x: win.center.x - w/2, y: win.bottom - h - snapOffset))
            } else {
                moveY(v.top - h - snapOffset)
            }
        }
    }
    
    func screenShotMethod() {
        //Create the UIImage
        print("shot")
        self.hidden = true
        UIGraphicsBeginImageContext(WINDOW!.frame.size)
        WINDOW!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print(image)
        screenShot = image
        //Save it to the camera roll
        //  UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.hidden = false
    }
    
    func closeContentView () {
        if let v = contentView {
            
            if let anim = setCloseAnimation {
                anim (contentView: v, backgroundView: (WINDOW?.subviews[0])! as UIView)
            } else {
                v.removeFromSuperview()
            }
            
            if (bubbleState == .Snap) {
                setupSnapInsideTimer()
                if positionBeforeToggle != nil {
                    movePoint(positionBeforeToggle!)
                }
                
            }
        }
    }
}


