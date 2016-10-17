
extension NSLayoutConstraint {
    
    @IBInspectable var preciseConstant: Int {
        get {
            return Int(constant * UIScreen.mainScreen().scale)
        }
        set {
            constant = CGFloat(newValue) / UIScreen.mainScreen().scale
        }
    }
}