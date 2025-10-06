import UIKit

extension UIColor {
    /// Initialize UIColor with a hex string (e.g. "#FF0000" or "FF0000")
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove leading #
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // Must be 6 or 8 characters
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        if hexString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha
            )
        } else {
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }
    }
}

