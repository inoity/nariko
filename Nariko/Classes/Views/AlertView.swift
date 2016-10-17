//
//  AlertView.swift
//  Pods
//
//  Created by Zsolt Papp on 2016. 10. 17..
//
//

import UIKit

@IBDesignable class AlertView: InspectableView {

    @IBOutlet weak var firstTextBlock: UILabel!
    @IBOutlet weak var secondTextBlock: UILabel!
    
    @IBInspectable let color1: UIColor = UIColor.blue
    @IBInspectable let color2: UIColor = UIColor.green
    
    override var nibName: String {
        get {
            return "AlertView"
        }
    }
    
    var on = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        self.layer.addSublayer(gradientLayer)
    //    foreground.layer.cornerRadius = 12
        
    }
    
    /*
     
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
