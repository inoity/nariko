import UIKit

class CustomTextView: UITextView {
    var isEmpty = true
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if isEmpty {
            selectedTextRange = textRange(from: beginningOfDocument, to: beginningOfDocument)
        }
        
        return super.caretRect(for: position)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isEmpty && (action == #selector(copy(_:)) || action == #selector(select(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:))) {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
