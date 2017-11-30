import UIKit

/**
 Image utilities
 */
public extension UIImage {
    /**
     This method return image with a tint's color
     - Parameter tintColor: color that has to apply
     */
    public func tinted(_ tintColor:UIColor) -> UIImage {
        let rect:CGRect = CGRect(origin: CGPoint(x:0.0,y:0.0), size: CGSize(width: self.size.width, height: self.size.height))
        UIGraphicsBeginImageContextWithOptions(self.size,false,self.scale)
        self.draw(in: rect)
        let context = UIGraphicsGetCurrentContext()
        context!.setBlendMode(CGBlendMode.sourceIn);
        tintColor.setFill()
        UIColor.green.setStroke();
        let shape = UIBezierPath.init(rect: rect)
        shape.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image ?? UIImage.init();
    }
}
