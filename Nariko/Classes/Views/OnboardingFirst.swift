//
//  OnboardingFirst.swift
//  Pods
//
//  Created by Zsolt Papp on 2016. 10. 17..
//
//

import UIKit

@IBDesignable class OnboardingFirst: DynamicSizeView {
    
    @IBOutlet weak var bgView: UIView!

    override class var nibName: String {
        get {
            return "OnboardingFirst"
        }
    }
    
    var on = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.frame
        gradientLayer.colors = [UIColor.gradTop.cgColor, UIColor.gradBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        bgView.layer.addSublayer(gradientLayer)
        
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
