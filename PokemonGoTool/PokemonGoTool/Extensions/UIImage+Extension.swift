
import UIKit

extension UIImage {
     class func drawOutlie(image: UIImage, color: UIColor) -> UIImage {
        let newImageKoef:CGFloat = 1.2
        let outlinedImageRect = CGRect(x: 0.0,
                                       y: 0.0,
                                       width: image.size.width * newImageKoef,
                                       height: image.size.height * newImageKoef)
        
        let imageRect = CGRect(x: image.size.width * (newImageKoef - 1) * 0.5,
                               y: image.size.height * (newImageKoef - 1) * 0.5,
                               width: image.size.width,
                               height: image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(outlinedImageRect.size, false, newImageKoef)
        
        image.draw(in: outlinedImageRect)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setBlendMode(.sourceIn)
        context.setFillColor(color.cgColor)
        context.fill(outlinedImageRect)
        image.draw(in: imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


class ColorFilter: CIFilter {
    var inputImage: CIImage?
    var inputColor: CIColor?
    private let kernel: CIColorKernel = {
        let kernelString =
        """
        kernel vec4 colorize(__sample pixel, vec4 color) {
            pixel.rgb = pixel.a * color.rgb;
            pixel.a *= color.a;
            return pixel;
        }
        """
        return CIColorKernel(source: kernelString)!
    }()
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage, let inputColor = inputColor else { return nil }
        let inputs = [inputImage, inputColor] as [Any]
        return kernel.apply(extent: inputImage.extent, arguments: inputs)
    }
}

extension UIImage {
    func colorized(with color: UIColor) -> UIImage {
        guard let cgInput = self.cgImage else {
            return self
        }
        let colorFilter = ColorFilter()
        colorFilter.inputImage = CIImage(cgImage: cgInput)
        colorFilter.inputColor = CIColor(color: color)
        
        if let ciOutputImage = colorFilter.outputImage {
            let context = CIContext(options: nil)
            let cgImg = context.createCGImage(ciOutputImage, from: ciOutputImage.extent)
            return UIImage(cgImage: cgImg!,
                           scale: self.scale,
                           orientation: self.imageOrientation).withRenderingMode(self.renderingMode)
        } else {
            return self
        }
    }
}

extension UIImage {
    func stroked(with color: UIColor, size: CGFloat) -> UIImage {
        let strokeImage = self.colorized(with: color)
        let oldRect = CGRect(x: size, y: size, width: self.size.width, height: self.size.height).integral
        let newSize = CGSize(width: self.size.width + (2*size), height: self.size.height + (2*size))
        let translationVector = CGPoint(x: size, y: 0)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            
            let step = 10 // reduce the step to increase quality
            for angle in stride(from: 0, to: 360, by: step) {
                let vector = translationVector.rotated(around: .zero, byDegrees: CGFloat(angle))
                let transform = CGAffineTransform(translationX: vector.x, y: vector.y)
                context.concatenate(transform)
                context.draw(strokeImage.cgImage!, in: oldRect)
                let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
                context.concatenate(resetTransform)
            }
            context.draw(self.cgImage!, in: oldRect)
            
            let newImage = UIImage(cgImage: context.makeImage()!, scale: self.scale, orientation: self.imageOrientation)
            UIGraphicsEndImageContext()
            
            return newImage.withRenderingMode(self.renderingMode)
        }
        UIGraphicsEndImageContext()
        return self
    }
}

extension CGPoint {
    func rotated(around origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = self.x - origin.x
        let dy = self.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + (byDegrees * CGFloat.pi / 180.0) // convert it to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}
