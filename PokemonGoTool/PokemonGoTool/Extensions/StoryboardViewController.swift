
import UIKit

#if os(iOS)

/**
 A view controller that is instaniated from a Storyboard file.
 */
public protocol StoryboardViewController: class {
    static var storyboardName: String {get}
    static var storyboardIdentifier: String {get}
    static var bundle: Bundle {get}

    static func instantiateFromStoryboard() -> Self
}

public extension StoryboardViewController {
    static var storyboardName: String {
        return String(describing: self)
    }

    static var storyboardIdentifier: String {
        return String(describing: self)
    }

    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
}

/**
 Use this protocol to mark a view controller that is the initial view controller of a storyboard.
 Then use .instantiateFromStoryboard() to conveniently create an instance
 */
public protocol StoryboardInitialViewController: StoryboardViewController {}

public extension StoryboardInitialViewController {
    static func instantiateFromStoryboard() -> Self {
        return UIStoryboard(name: self.storyboardName, bundle: bundle).instantiateInitialViewController() as! Self
    }
    
    static func instantiateFromStoryboardInNavigationController() -> UINavigationController {
        return UIStoryboard(name: self.storyboardName, bundle: bundle).instantiateInitialViewController() as! UINavigationController
    }
}

/**
 Use this protocol to mark a view controller that is embedded in the initial view controller of a storyboard.
 */
public protocol StoryboardEmbeddedViewController: StoryboardViewController {
    associatedtype StoryboardEmbeddingViewController: UIViewController
    var embeddingViewController: StoryboardEmbeddingViewController {get}
}

public extension StoryboardEmbeddedViewController where Self: UIViewController, StoryboardEmbeddingViewController: UINavigationController {
    var embeddingViewController: StoryboardEmbeddingViewController {
        return self.navigationController as! StoryboardEmbeddingViewController
    }

    static func instantiateFromStoryboard() -> Self {
        let embeddingViewController = UIStoryboard(name: self.storyboardName, bundle: bundle).instantiateInitialViewController() as! UINavigationController
        return embeddingViewController.topViewController as! Self
    }
}

#endif
