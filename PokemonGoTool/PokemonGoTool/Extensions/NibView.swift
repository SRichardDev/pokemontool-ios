
import UIKit

#if os(iOS)

public protocol NibView: AnyObject {
    /// By default loads the nib with the same name as the class name
    static func fromNib() -> Self
    /// The default value is the same as the class name
    static var nibName: String { get }
    /// By default returns the `UINib` instance with the same name as the class name
    static var nib: UINib { get }
}

public extension NibView {

    static func fromNib() -> Self {
        let views = Bundle(for: Self.self).loadNibNamed(nibName, owner: nil, options: nil)
        return views![0] as! Self
    }

    static var nibName: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

#endif
