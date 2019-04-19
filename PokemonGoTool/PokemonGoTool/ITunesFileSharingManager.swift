
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
}
