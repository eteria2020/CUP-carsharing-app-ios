import Foundation
import RxSwift
import Boomerang

struct CustomTextInputStyle1: AnimatedTextInputStyle {
    let activeColor = ColorBrand.black.value
    let inactiveColor = ColorBrand.gray.value
    let lineInactiveColor = ColorBrand.gray.value
    let errorColor = ColorBrand.black.value
    let textInputFont = Font.loginTextField.value
    let textInputFontColor = ColorBrand.black.value
    let placeholderMinFontSize: CGFloat = 9
    let counterLabelFont: UIFont? = Font.loginTextFieldPlaceholder.value
    let leftMargin: CGFloat = 20
    let topMargin: CGFloat = 25
    let rightMargin: CGFloat = 20
    let bottomMargin: CGFloat = 10
    let yHintPositionOffset: CGFloat = 7
    let yPlaceholderPositionOffset: CGFloat = 0
}

struct CustomTextInputStyle2: AnimatedTextInputStyle {
    let activeColor = ColorBrand.white.value
    let inactiveColor = ColorBrand.white.value
    let lineInactiveColor = ColorBrand.white.value
    let errorColor = ColorBrand.white.value
    let textInputFont = Font.loginTextField.value
    let textInputFontColor = ColorBrand.white.value
    let placeholderMinFontSize: CGFloat = 9
    let counterLabelFont: UIFont? = Font.loginTextFieldPlaceholder.value
    let leftMargin: CGFloat = 20
    let topMargin: CGFloat = 25
    let rightMargin: CGFloat = 20
    let bottomMargin: CGFloat = 10
    let yHintPositionOffset: CGFloat = 7
    let yPlaceholderPositionOffset: CGFloat = 0
}

public protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}

extension Observable where Element: OptionalType {
    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value in
            value.optional.map { Observable<Element.Wrapped>.just($0) } ?? Observable<Element.Wrapped>.empty()
        }
    }
}

private struct AssociatedKeys {
    static var disposeBag = "disposeBag"
}

extension UIView {
    public var disposeBag: DisposeBag {
        get {
            var disposeBag: DisposeBag
            
            if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
                disposeBag = lookup
            } else {
                disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
