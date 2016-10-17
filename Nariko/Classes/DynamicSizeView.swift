import UIKit

class DynamicSizeView: UIView {
    class var nibName: String {
        get {
            return ""
        }
    }
    
    class func instanceFromNib() -> UIView {
        let podBundle = Bundle(for: self.classForCoder())
        let bundle = Bundle(url: podBundle.url(forResource: "Nariko", withExtension: "bundle")!)
        
        return UINib(nibName: nibName, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeDidChange), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func updateFonts() {
    }
    
    func contentSizeDidChange() {
        updateFonts()
    }
}
