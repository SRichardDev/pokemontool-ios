
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
            if let image = UIImage(contentsOfFile: imageURL.path) {
                return image
            } else {
                return UIImage(named: "0")
            }
        }
        return UIImage(named: imageName)
    }
}
