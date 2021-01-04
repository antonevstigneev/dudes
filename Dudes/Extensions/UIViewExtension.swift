
import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
}

extension UIView {
    
    func animateBounceIn() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
          }, completion: nil)
    }
    func animateBounceOut() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
          }, completion: nil)
    }
}

extension UIView {
    
    func highlight() {
        UIView.animate(withDuration: 0.5) {
            self.tintColor = UIColor.systemBlue
        }
    }
    
    func unhighlight() {
        UIView.animate(withDuration: 0.5) {
            self.tintColor = UIColor.gray
        }
    }
}


extension UIView {
    
    func randomBackground() {
        self.layer.backgroundColor = UIColor.random.cgColor
    }
}
