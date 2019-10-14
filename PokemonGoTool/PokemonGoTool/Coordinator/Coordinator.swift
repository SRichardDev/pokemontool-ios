
import UIKit

protocol Coordinator  {
    var children: [Coordinator] { get set }
    var tabBarController: UITabBarController { get set }
}
