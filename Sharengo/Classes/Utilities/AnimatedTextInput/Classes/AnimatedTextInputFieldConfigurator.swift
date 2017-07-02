import UIKit

public struct AnimatedTextInputFieldConfigurator {

    public enum AnimatedTextInputType {
        case standard
        case email
        case password
        case numeric
        case selection
        case multiline
        case generic(textInput: TextInput)
    }

    static func configure(with type: AnimatedTextInputType) -> TextInput {
        switch type {
        case .standard:
            return AnimatedTextInputTextConfigurator.generate()
        case .email:
            return AnimatedTextInputEmailConfigurator.generate()
        case .password:
            return AnimatedTextInputPasswordConfigurator.generate()
        case .numeric:
            return AnimatedTextInputNumericConfigurator.generate()
        case .selection:
            return AnimatedTextInputSelectionConfigurator.generate()
        case .multiline:
            return AnimatedTextInputMultilineConfigurator.generate()
        case .generic(let textInput):
            return textInput
        }
    }
}

fileprivate struct AnimatedTextInputTextConfigurator {

    static func generate() -> TextInput {
        let textField = AnimatedTextField()
//        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
//        textField.clearButtonMode = .whileEditing
        return textField
    }
}

fileprivate struct AnimatedTextInputEmailConfigurator {

    static func generate() -> TextInput {
        let textField = AnimatedTextField()
//        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        return textField
    }
}

fileprivate struct AnimatedTextInputPasswordConfigurator {

    static func generate() -> TextInput {
        let textField = AnimatedTextField()
//        textField.rightViewMode = .whileEditing
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        let disclosureButton = UIButton(type: .custom)
        disclosureButton.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20))
//        let normalImage = UIImage(named: "cm_icon_input_eye_normal")
//        let selectedImage = UIImage(named: "cm_icon_input_eye_selected")
//        disclosureButton.setImage(normalImage, for: .normal)
//        disclosureButton.setImage(selectedImage, for: .selected)
        textField.add(disclosureButton: disclosureButton) {
            disclosureButton.isSelected = !disclosureButton.isSelected
            textField.resignFirstResponder()
            textField.isSecureTextEntry = !textField.isSecureTextEntry
            textField.becomeFirstResponder()
        }
        return textField
    }
}

fileprivate struct AnimatedTextInputNumericConfigurator {

    static func generate() -> TextInput {
        let textField = AnimatedTextField()
//        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .decimalPad
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        return textField
    }
}

fileprivate struct AnimatedTextInputSelectionConfigurator {

    static func generate() -> TextInput {
        let textField = AnimatedTextField()
//        let arrowImageView = UIImageView(image: UIImage(named: "disclosure"))
//        textField.rightView = arrowImageView
//        textField.rightViewMode = .always
        textField.isUserInteractionEnabled = false
        textField.returnKeyType = .done
        return textField
    }
}

fileprivate struct AnimatedTextInputMultilineConfigurator {

    static func generate() -> TextInput {
        let textView = AnimatedTextView()
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        return textView
    }
}
