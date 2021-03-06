import UIKit

public extension UIImage {

    /// Creates a QR code from a string.
    /// Resizing rate defaults to 15.0 here because the CIFilter result is 31x31 pixels in size.
    ///
    /// - Parameter string: Text to be the QR Code content
    /// - Parameter resizeRate: The resizing rate. Positive for enlarging and negative for shrinking. Defaults to 15.0.
    /// - Returns: image QR Code image
    static func imageQRCode(for string: String, resizeRate: CGFloat = 15.0) -> UIImage {
        let data = string.data(using: .isoLatin1, allowLossyConversion: false)

        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        let cImage = filter.outputImage!

        let qrCode = UIImage(ciImage: cImage)
        let qrCodeResized = qrCode.resized(by: resizeRate, quality: .none)

        return qrCodeResized
    }

    /**
     Returns the perfect frame to center a UIImage in the screen.
     */
    func centeredFrame() -> CGRect {
        let screenBounds = UIScreen.main.bounds
        let widthScaleFactor = size.width / screenBounds.size.width
        let heightScaleFactor = size.height / screenBounds.size.height
        var centeredFrame = CGRect.zero

        let shouldFitHorizontally = widthScaleFactor > heightScaleFactor
        if shouldFitHorizontally && widthScaleFactor > 0 {
            let y = (screenBounds.size.height / 2) - ((size.height / widthScaleFactor) / 2)
            centeredFrame = CGRect(x: 0, y: y, width: screenBounds.size.width, height: size.height / widthScaleFactor)
        } else if heightScaleFactor > 0 {
            let x = (screenBounds.size.width / 2) - ((size.width / heightScaleFactor) / 2)
            centeredFrame = CGRect(x: x, y: 0, width: screenBounds.size.width - (2 * x), height: screenBounds.size.height)
        }

        return centeredFrame
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    /// Resizes the image by a given rate for a given interpolation quality.
    ///
    /// - Parameters:
    ///   - rate: The resize rate. Positive to enlarge, negative to shrink. Defaults to medium.
    ///   - quality: The interpolation quality.
    /// - Returns: The resized image.
    func resized(by rate: CGFloat, quality: CGInterpolationQuality = .medium) -> UIImage {
        let width = self.size.width * rate
        let height = self.size.height * rate
        let size = CGSize(width: width, height: height)

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality
        draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return resized
    }

    /// Returns a new version of the image to a given max width preserving aspect ratio
    ///
    /// - Parameter width: The new scaled width
    /// - Returns: A scaled image
    func resized(toWidth width: CGFloat, quality: CGInterpolationQuality = .medium) -> UIImage {
        let scale = width / size.width
        let height = size.height * scale

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality

        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return scaledImage!
    }

    /// Returns a new version of the image to a given max height preserving aspect ratio
    ///
    /// - Parameter height: The new scaled height
    /// - Returns: A scaled image
    func resized(toHeight height: CGFloat, quality: CGInterpolationQuality = .medium) -> UIImage {
        let scale = height / size.height
        let width = size.width * scale

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = quality

        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return scaledImage!
    }

    /// Normalizes image orientation by rotating an image so that it's orientation is UIImageOrientation.up
    ///
    /// - Returns: The normalized image.
    func imageByNormalizingOrientation() -> UIImage? {
        if imageOrientation == .up {
            return self
        }

        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
