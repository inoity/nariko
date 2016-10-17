//
//  AlertView.swift
//  Pods
//
//  Created by Zsolt Papp on 2016. 10. 17..
//
//

import UIKit

@IBDesignable class AlertView: DynamicSizeView {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var firstTextBlock: UILabel!
    @IBOutlet weak var secondTextBlock: UILabel!

    override class var nibName: String {
        get {
            return "AlertView"
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
    
    func updateUI(text1: String, text2: String){
        
        firstTextBlock.text = text1
        secondTextBlock.text = text2
    }
    /*
     
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
