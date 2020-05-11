//
//  UIViewController+Extensions.swift
//  UIKit Toolbox
//
//  Created by Stevo on 3/23/20.
//  Copyright © 2020 Stevo Brock. All rights reserved.
//

import UIKit

//----------------------------------------------------------------------------------------------------------------------
// MARK: UIViewController extension
extension UIViewController {

	// MARK: Types
	typealias ErrorInfoProc = (_ error :Error) -> (title :String, message :String)

	// MARK: Properties
	var	topViewController :UIViewController {
				// Follow the tree up the stack to the top
				var	topViewController = self
				while true {
					// Check for another top view controller
					if let presentedViewController = topViewController.presentedViewController {
						// Have presented view controller
						topViewController = presentedViewController
					} else if let navigationController = topViewController as? UINavigationController {
						// Are navigation controller
						topViewController = navigationController.visibleViewController!
					} else if let tabBarController = topViewController as? UITabBarController {
						// Are tab bar controller
						topViewController = tabBarController.selectedViewController!
					} else {
						// Are the top view controller
						return topViewController
					}
				}
			}

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	func presentAnimated(_ viewController :UIViewController) { present(viewController, animated: true) }

	//------------------------------------------------------------------------------------------------------------------
	func embed(_ viewController :UIViewController, in view :UIView? = nil) {
		// Add child
		viewController.view.frame = (view ?? self.view).bounds
		addChild(viewController)
		(view ?? self.view).addSubview(viewController.view)
		viewController.didMove(toParent: self)
	}

	//------------------------------------------------------------------------------------------------------------------
	func unembed(_ viewController :UIViewController) {
		// Remove
		viewController.willMove(toParent: nil)
		viewController.view.removeFromSuperview()
		viewController.removeFromParent()
	}

	//------------------------------------------------------------------------------------------------------------------
	func presentAlert(title :String? = nil, message :String, actionButtonTitle :String = "OK",
			actionProc :@escaping () -> Void = {}) {
		// Present alert
		presentAlert(title: title, message: message, defaultActionButtonTitle: actionButtonTitle,
				defaultActionProc: actionProc)
	}

	//------------------------------------------------------------------------------------------------------------------
	func presentAlert(title :String? = nil, message :String,
			defaultActionButtonTitle :String = "OK", defaultActionProc :@escaping () -> Void = {},
			cancelActionButtonTitle :String? = nil, cancelActionProc :@escaping () -> Void = {},
			destructiveActionButtonTitle :String? = nil, destructiveActionProc :@escaping () -> Void = {}) {
		// Compose alert controller
		let	alertController =
					UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: defaultActionButtonTitle, style: .default) { _ in
			// Call proc
			defaultActionProc()
		})
		if cancelActionButtonTitle != nil {
			// Add cancel action
			alertController.addAction(UIAlertAction(title: cancelActionButtonTitle!, style: .cancel) { _ in
				// Call proc
				cancelActionProc()
			})
		}
		if destructiveActionButtonTitle != nil {
			// Add other action
			alertController.addAction(UIAlertAction(title: destructiveActionButtonTitle!, style: .destructive) { _ in
				// Call proc
				destructiveActionProc()
			})
		}

		// Present
		presentAnimated(alertController)
	}

	//------------------------------------------------------------------------------------------------------------------
	func presentAlert(_ error :Error, actionButtonTitle: String = "OK", infoProc :ErrorInfoProc? = nil,
			actionProc :@escaping () -> Void = {}) {
		// Get info for error
		let	title :String
		let	message :String
		switch error {
			case let error as NSError where error.code == NSURLErrorNotConnectedToInternet:
				// No internet connection
				title = "No Internet Connection"
				message = "The internet connection appears to be offline. Please reconnect and try again."

			default:
				// Something else
				if infoProc != nil {
					// Have infoProc
					(title, message) = infoProc!(error)
				} else if let localizedError = error as? LocalizedError {
					// Have Localized Error
					(title, message) = ("Error", localizedError.errorDescription!)
				} else {
					// Catch-all
					(title, message) = ("Error", "\(error)")
				}
		}

		// Present
		presentAlert(title: title, message: message, actionButtonTitle: actionButtonTitle, actionProc: actionProc)
	}

	//------------------------------------------------------------------------------------------------------------------
	func present(_ alertController :UIAlertController, from view :UIView? = nil) {
		// Check preferred style
		if (alertController.preferredStyle == .actionSheet) && (UIDevice.current.userInterfaceIdiom == .pad) &&
				(view != nil) {
			// Present as popover from view
			alertController.modalPresentationStyle = .popover
			alertController.popoverPresentationController?.sourceView = view
			alertController.popoverPresentationController?.sourceRect = view!.bounds
		}

		// Present
		presentAnimated(alertController)
	}

	//------------------------------------------------------------------------------------------------------------------
	func present(_ viewController :UIViewController, from view :UIView? = nil, cancelTitle :String = "Cancel") {
		// Check preferred style
		if view != nil {
			// Present as popover from view
			viewController.modalPresentationStyle = .popover
			viewController.popoverPresentationController?.sourceView = view
			viewController.popoverPresentationController?.sourceRect = view!.bounds

			// Present
			presentAnimated(viewController)
		} else if self.traitCollection.horizontalSizeClass == .compact {
			// Embed in navigation controller
			let	navigationController = UINavigationController(rootViewController: viewController)

			// Add close bar button item
			viewController.navigationItem.leftBarButtonItem =
					UIBarButtonItem(title: cancelTitle, style: .plain, target: self,
							action: #selector(uiViewControllerExtensionsCancel(_:)))

			// Present
			presentAnimated(navigationController)
		} else {
			// Present
			presentAnimated(viewController)
		}
	}

	// MARK: Internal methods
	//------------------------------------------------------------------------------------------------------------------
	@objc func uiViewControllerExtensionsCancel(_ :UIButton) {
		// End editing
		self.view.endEditing(true)

		// Close
		self.dismiss(animated: true)
	}
}
