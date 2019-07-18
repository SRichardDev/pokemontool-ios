
import Foundation

@objc protocol SettingsConfigurable {
}

@objc protocol MapFilterSettingsConfigurable {
    static var filterSettingsChanged: Bool { get set }
    static var showPokestops: Bool { get set }
    static var showOnlyPokestopsWithQuest: Bool { get set }

    static var showArenas: Bool { get set }
    static var showOnlyArenasWithRaid: Bool { get set }
    static var showOnlyEXArenas: Bool { get set }
    static var isPushActive: Bool { get set }
}

class AppSettings: NSObject {
    
    fileprivate static func updateDefaults(for key: String, value: Any) {
        // Save value into UserDefaults
        UserDefaults.standard.set(value, forKey: key)
    }
    
    fileprivate static func value<T>(for key: String) -> T? {
        // Get value from UserDefaults
        return UserDefaults.standard.value(forKey: key) as? T
    }
}

extension AppSettings: SettingsConfigurable {

}

extension AppSettings: MapFilterSettingsConfigurable {
    static var filterSettingsChanged: Bool {
        get { return AppSettings.value(for: #keyPath(filterSettingsChanged)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(filterSettingsChanged), value: newValue) }
    }
    
    static var showPokestops: Bool {
        get { return AppSettings.value(for: #keyPath(showPokestops)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(showPokestops), value: newValue) }
    }
    
    static var showOnlyPokestopsWithQuest: Bool {
        get { return AppSettings.value(for: #keyPath(showOnlyPokestopsWithQuest)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(showOnlyPokestopsWithQuest), value: newValue) }
    }
    
    static var showArenas: Bool {
        get { return AppSettings.value(for: #keyPath(showArenas)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(showArenas), value: newValue) }
    }
    
    static var showOnlyArenasWithRaid: Bool {
        get { return AppSettings.value(for: #keyPath(showOnlyArenasWithRaid)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(showOnlyArenasWithRaid), value: newValue) }
    }
    
    static var showOnlyEXArenas: Bool {
        get { return AppSettings.value(for: #keyPath(showOnlyEXArenas)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(showOnlyEXArenas), value: newValue) }
    }
    
    static var isPushActive: Bool {
        get { return AppSettings.value(for: #keyPath(isPushActive)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isPushActive), value: newValue) }
    }
    
    static var isFilterActive: Bool {
        get {
            return showPokestops == false ||
                showOnlyPokestopsWithQuest == true ||
                showArenas == false ||
                showOnlyArenasWithRaid == true ||
                showOnlyEXArenas == true
        }
    }
}
