import UIKit

/**
 Image Theme
 */
public extension UIImage {
    /// Main navbar
    public static func navbar() -> UIImage {
        return UIImage(named:"bkg_topBar")?.resizableImage(withCapInsets: UIEdgeInsetsMake(1, 1, 1, 1), resizingMode: .stretch) ?? UIImage()
    }
    
    /**
     This method return image with rectangle's mask
     - Parameter size: rectangle's size
     - Parameter color: fill color
     - Parameter borderColor: border color
     */
    static func rectangle(ofSize size:CGSize, color:UIColor, borderColor:UIColor? = nil , borderWidth:CGFloat = 0, cornerRadius:CGFloat = 0) -> UIImage{
        let bigRect =  CGRect(x:0, y:0, width:size.width, height: size.height);
        UIGraphicsBeginImageContextWithOptions(bigRect.size, false, 0.0);
        let context = UIGraphicsGetCurrentContext()
        context!.setAllowsAntialiasing(true);
        context!.setShouldAntialias(true);
        let path = UIBezierPath(roundedRect: bigRect.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius:cornerRadius)
        context!.setFillColor(color.cgColor);
        path.fill()
        if (borderColor != nil) {
            context!.setLineWidth(borderWidth);
            context!.setStrokeColor(borderColor!.cgColor);
            path.stroke()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image ?? UIImage.init();
    }
    
    /**
     This method return image with oval's mask
     - Parameter size: rectangle's size
     - Parameter color: fill color
     - Parameter borderColor: border color
     - Parameter borderWidth: border width
     - Parameter cornerRadius: corner radius
     */
    public static func oval(ofSize size:CGSize, color:UIColor, borderColor:UIColor? = nil , borderWidth:CGFloat = 0, cornerRadius:CGFloat = 0) -> UIImage{
        let bigRect =  CGRect(x:0, y:0, width:size.width, height:size.height);
        UIGraphicsBeginImageContextWithOptions(bigRect.size, false, 0.0);
        let context = UIGraphicsGetCurrentContext()
        context!.setAllowsAntialiasing(true);
        context!.setShouldAntialias(true);
        let path = UIBezierPath(ovalIn: bigRect.insetBy(dx: borderWidth, dy: borderWidth))
        context!.setFillColor(color.cgColor);
        path.fill()
        if (borderColor != nil) {
            context!.setLineWidth(borderWidth);
            context!.setStrokeColor(borderColor!.cgColor);
            path.stroke()
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image ?? UIImage.init();
    }
    
    /**
     This method return image with a tint's color
     - Parameter tintColor: tint color
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
