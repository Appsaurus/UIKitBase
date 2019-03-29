//
//  ConfigurableViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 4/12/18.
//

import Swiftest
import UIKitTheme
import UIKitExtensions
import Layman

public class FormViewControllerConfiguration: ViewControllerConfiguration{
    public let promptText: String? = "Please enter a phone number."
    public let autoSubmitsFormWhenValid: Bool = false
}

public class FormViewControllerStyle: ViewControllerStyle{
    open lazy var promptLabelStyle: TextStyle = .light(color: .primaryContrast)
    open lazy var textFieldStyles: TextFieldStyleMap = .materialStyleMap(color: .primaryContrast)
    open lazy var submitButtonStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast), viewStyle: ViewStyle(backgroundColor: .success))
    open lazy var submitButtonDisabledStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))
    open lazy var secondaryButtonStyle: ButtonStyle = ButtonStyle(textStyle: .regular(color: .primaryContrast))
}


open class ConfigurableViewController<Configuration: ViewControllerConfiguration, Style: ViewControllerStyle>: BaseViewController{
    
    open lazy var config: Configuration = Configuration()
    open lazy var vcStyle: Style = Style()

    
    public required init(config: Configuration? = nil, style: Style? = nil, callDidInit: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        if let config = config{
            self.config = config
        }
        if let style = style{
            self.vcStyle = style
        }
        
        if callDidInit{
            didInit()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        didInit()
    }

}