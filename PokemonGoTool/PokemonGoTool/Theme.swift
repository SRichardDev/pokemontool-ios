
import UIKit
import NSTAppKit

protocol Theme {
    var tint: UIColor { get }
    
    var backgroundColor: UIColor { get }
    var separatorColor: UIColor { get }
    var selectionColor: UIColor { get }
    
    var labelColor: UIColor { get }
    var secondaryLabelColor: UIColor { get }
    var subtleLabelColor: UIColor { get }
    
    var barStyle: UIBarStyle { get }
    
    func apply(for application: UIApplication)
}

struct AngenehmesGruenTheme: Theme {
    let tint: UIColor = Appearance.angenehmesGruen
    
    let backgroundColor: UIColor = .systemBackground
    let separatorColor: UIColor = Appearance.angenehmesGruen
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = .label
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct OrangeTheme: Theme {
    let tint: UIColor = Appearance.orange
    
    let backgroundColor: UIColor = .systemBackground
    let separatorColor: UIColor = Appearance.orange
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = .label
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct MegaEpischesBlau: Theme {
    let tint: UIColor = Appearance.megaEpischesBlau
    
    let backgroundColor: UIColor = .systemBackground
    let separatorColor: UIColor = Appearance.megaEpischesBlau
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = .label
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct PinkTheme: Theme {
    let tint: UIColor = Appearance.pink
    
    let backgroundColor: UIColor = .systemBackground
    let separatorColor: UIColor = Appearance.pink
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = .label
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

struct YellowTheme: Theme {
    let tint: UIColor = Appearance.yellow
    
    let backgroundColor: UIColor = .systemBackground
    let separatorColor: UIColor = Appearance.yellow
    let selectionColor: UIColor = .init(red: 38/255, green: 38/255, blue: 40/255, alpha: 1)
    
    let labelColor: UIColor = .label
    let secondaryLabelColor: UIColor = .lightGray
    let subtleLabelColor: UIColor = .darkGray
    
    let barStyle: UIBarStyle = .black
}

class Theming {
    static func applySelectedPersistedTheme() {
        let theme = PinkTheme()
        theme.apply(for: UIApplication.shared)
    }
}


extension Theme {
    
    func apply(for application: UIApplication) {
        application.keyWindow?.tintColor = tint
        
        let titilliumWebRegular = "Helvetica"
        let font15 = UIFont(name: titilliumWebRegular, size: 15)!
        let font12 =  UIFont(name: titilliumWebRegular, size: 12)!
        let font24 =  UIFont(name: titilliumWebRegular, size: 24)!

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font15],
                                                            for: .highlighted)
        
        UITabBarItem.appearance().setTitleTextAttributes([.font: font12],
                                                         for: .normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([.font: font12], for: .normal)
        
        
        UITextView.appearance().with {
            $0.font = font15
        }
        
        UITextField.appearance().with {
            $0.font = font15
        }
        
        UITabBar.appearance().with {
            $0.tintColor = tint
        }
        
        UINavigationBar.appearance().with {
            $0.tintColor = tint
//            $0.shadowImage = tint.as1ptImage()
            $0.titleTextAttributes = [.foregroundColor: labelColor,
                                      .font: font24]
        }
        
//        UICollectionView.appearance().backgroundColor = backgroundColor
        
        UITableView.appearance().with {
            $0.backgroundColor = backgroundColor
            $0.separatorColor = separatorColor
        }
        
        UITableViewCell.appearance().with {
            $0.backgroundColor = .clear
        }
        
        UIView.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
            .backgroundColor = .secondarySystemBackground
            
        
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
            .textColor = secondaryLabelColor
        
        Button.appearance().with {
            $0.backgroundColor = tint
            $0.setTitleColor(tint, for: .normal)
        }
        
        UIImageView.appearance().with {
            $0.tintColor = tint
        }
        
        UISegmentedControl.appearance().with {
            $0.backgroundColor = tint
        }
        
        let colorView = UIView()
        colorView.backgroundColor = tint.withAlphaComponent(0.3)
        UITableViewCell.appearance().selectedBackgroundView = colorView
        
        application.windows.reload()
    }
}
