//
//  FCMBridge.swift
//  Runner
//
//  Created by Sagar on 14/04/22.
//

import Flutter
import Foundation
import UIKit

class FCMBridge {
	static let shared = FCMBridge()
	var channel: FlutterMethodChannel?

	func setup(with controller: FlutterViewController) {
		self.channel = FlutterMethodChannel(
			name: "com.sagar.nodifier/fcm",
			binaryMessenger: controller.binaryMessenger)
		self.channel?.setMethodCallHandler { [weak self] (call, result) in
			if (call.method == "register") {
				self?.registerForPushNotification(result)
			} else {
				result(FlutterMethodNotImplemented)
			}
		}
	}

	private func registerForPushNotification(_ result: @escaping FlutterResult) {
		let appDel = UIApplication.shared.delegate as! AppDelegate
		appDel.registerForNotification { isSuccess, error in
			OperationQueue.main.addOperation {
				if (isSuccess) {
					result("true")
				} else {
					let error = FlutterError(
						code: "DENIED",
						message: "User did not enable push notification.",
						details: nil)
					result(error)
				}
			}
		}
	}
}
