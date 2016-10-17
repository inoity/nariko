import UIKit

class DynamicSizeView: UIView {
    class var nibName: String {
        get {
            return ""
        }
    }
    
    class func instanceFromNib() -> UIView {
        
        let podBundle = Bundle(for: DynamicSizeView.self)
        
        let bundle = Bundle(url: podBundle.url(forResource: "Nariko", withExtension: "bundle")!)
        
    /*    let bundle = Bundle(for: type(of: self) as! AnyClass)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view*/
        
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
