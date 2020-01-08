
import Foundation
import UIKit

class ITunesFileSharingManager {
    
    private func loadFromDisk(fileName: String) -> [String : Any]? {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let sourceFileUrl = documentDirectoryUrl.appendingPathComponent(fileName)
        guard fileExists(for: sourceFileUrl) else { return nil }
        do {
            let data = try Data(contentsOf: sourceFileUrl)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch let error {
            print(error)
        }
        return nil
    }
    
    private func fileExists(for url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path){
            print("\(url.lastPathComponent) already exists")
            return true
        }
        return false
    }
}

class ImageManager {
    
    class func image(named imageName: String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("pokemon/\(imageName).png")
            if let userDefinedImage = UIImage(contentsOfFile: imageURL.path) {
                return resizeImageIfNeeded(userDefinedImage)
            }
        }
        
        if let standardImage = UIImage(named: imageName) {
            return resizeImageIfNeeded(standardImage)
        }
        
        return UIImage(named: imageName)
    }
    
    private class func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        if image.size.width > 72 {
            return image.resize(targetSize: CGSize(width: 72, height: 72))
        }
        return image
    }
    
    class func combinedArenaImage(for arena: Arena) -> UIImage? {
        
        guard let topImage = arena.raid?.image else { return arena.image }
        guard let raid = arena.raid else { return arena.image }
        guard raid.isActive else { return arena.image }
        
        #if targetEnvironment(macCatalyst)
        let baseImage = arena.image.resize(scaleFactor: 1.5)
        let scaleFactor: CGFloat = raid.hasHatched ? ((raid.raidboss != nil) ? 4 : 1) : 1
        #else
        let baseImage = arena.image
        let scaleFactor: CGFloat = raid.hasHatched ? ((raid.raidboss != nil) ? 4 : 1.5) : 1.5
        #endif
        
        let size = CGSize(width: topImage.size.width / scaleFactor, height: topImage.size.height / scaleFactor)
        let resizedTopImage = topImage.resize(targetSize: size)
        
        return UIImage.imageByCombiningImage(firstImage: baseImage, withImage: resizedTopImage)
    }
    
    class func imageViewWithSystemImage(type: SystemImageType) -> UIImageView {
                
        let imageView = UIImageView(image: systemImage(type: type))
        imageView.tintColor = .white
        
        return imageView
    }
    
    class func systemImage(type: SystemImageType, pointSize: CGFloat = 40) -> UIImage? {
        var image: UIImage?
        let config = UIImage.SymbolConfiguration(pointSize: pointSize)

        switch type {
        case .radioWaves:
            image = UIImage(systemName: "antenna.radiowaves.left.and.right", withConfiguration: config)
        case .checkMark:
            image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
        case .xMark:
            image = UIImage(systemName: "xmark.circle", withConfiguration: config)
        case .map:
            image = UIImage(systemName: "map", withConfiguration: config)
        }

        return image
    }
}

enum SystemImageType {
    case radioWaves
    case checkMark
    case xMark
    case map
}
