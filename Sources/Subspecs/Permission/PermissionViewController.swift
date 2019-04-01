//
//  PermissionViewController.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 1/24/18.
//

import Permission
import Swiftest
import UIKitExtensions
import UIKitTheme

public typealias PermissionSetChange = (_ permissionViewController: PermissionViewController, _ permissionSet: PermissionSet, _ permission: Permission) -> Void

public class PermissionViewModel: AlertViewModel {}

open class PermissionViewController: StackedAlertViewController, PermissionSetDelegate {
    open var permissionSet: PermissionSet
    open var permissionButtons: [PermissionButton] = []
    open var onPermissionChange: PermissionSetChange?
    open var onDismiss: ClosureIn<PermissionSet>?

    public required init(permissions: [Permission],
                         permissionViewModel: PermissionViewModel = PermissionViewModel(),
                         onPermissionChange: PermissionSetChange? = nil,
                         onDismiss: ClosureIn<PermissionSet>? = nil) {
        permissionButtons = permissions.map { PermissionViewController.createButton(for: $0) }
        permissionSet = PermissionSet(permissionButtons)
        self.onPermissionChange = onPermissionChange
        self.onDismiss = onDismiss
        super.init(viewModel: permissionViewModel)
    }

    public required init(permissionButtons: [PermissionButton],
                         alertViewModel: AlertViewModel = AlertViewModel(),
                         onPermissionChange: PermissionSetChange? = nil,
                         onDismiss: ClosureIn<PermissionSet>? = nil) {
        self.permissionButtons = permissionButtons
        permissionSet = PermissionSet(permissionButtons)
        self.onPermissionChange = onPermissionChange
        self.onDismiss = onDismiss
        super.init(viewModel: alertViewModel)
    }

    public required init(viewModel: AlertViewModel) {
        fatalError("init(viewModel:) has not been implemented")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(viewModel:) has not been implemented")
    }

    open override func setupDelegates() {
        super.setupDelegates()
        permissionSet.delegate = self
    }

    open override var bottomStackArrangedSubviews: [UIView] {
        let buttons: [UIView] = permissionButtons
        return buttons + super.bottomStackArrangedSubviews
    }

    open class func alertViewModel() -> AlertViewModel {
        return AlertViewModel(alertTitle: "Just a sec.", message: "We need your permission to do that.")
    }

    open class func createButton(for permission: Permission) -> PermissionButton {
        let btn = PermissionButton(permission)
        let desc = permission.description
        btn.apply(textStyle: .light(size: .button))
        btn.setTitles([
            .notDetermined: "Authorize \(desc)",
            .authorized: "\(desc) 👍",
            .denied: "\(desc) Denied. 😞",
            .disabled: "\(desc) Disabled. ⚙️ "
        ])
        btn.titleLabel?.textAlignment = .left

        btn.setTitleColors([
            .authorized: .primaryContrast,
            .denied: .primaryContrast,
            .disabled: .primaryContrast,
            .notDetermined: .primary
        ])
        btn.contentEdgeInsets = UIEdgeInsets(padding: 20.0)
        setColorsForCurrentState(for: btn)
        return btn
    }

    open override func userDidDismiss() {
        onDismiss?(permissionSet)
    }

    public func permissionSet(_ permissionSet: PermissionSet, didRequestPermission permission: Permission) {
        onPermissionChange?(self, permissionSet, permission)
        guard let button = permissionButtons.first(where: { $0.permission == permission }) else { return }
        type(of: self).setColorsForCurrentState(for: button)
    }

    public class func setColorsForCurrentState(for button: PermissionButton) {
        switch button.permission.status {
        case .authorized:
            button.backgroundColor = .success
        case .denied, .disabled:
            button.backgroundColor = .error
        case .notDetermined:
            button.backgroundColor = .primaryContrast
        }
        button.cornerRadius = App.layout.roundedCornerRadius
        button.borderWidth = 1
        button.borderColor = button.titleColorForStatus(button.permission.status)
    }

    @discardableResult
    public class func authorize(permissions: Permission...,
                                permissionViewModel: PermissionViewModel = PermissionViewModel(),
                                from presenter: UIViewController,
                                success: @escaping VoidClosure,
                                failure: @escaping ClosureIn<PermissionSet>) -> Self? {
        guard PermissionSet(permissions).status != .authorized else {
            success()
            return nil
        }
        let permissionViewController = self.init(permissions: Array(permissions), permissionViewModel: permissionViewModel, onPermissionChange: { vc, permissionSet, _ in
            guard permissionSet.status == .authorized else {
                return
            }
            vc.dismiss(animated: true, completion: success)
        }, onDismiss: failure)
        permissionViewController.present(from: presenter)
        return permissionViewController
    }
}
