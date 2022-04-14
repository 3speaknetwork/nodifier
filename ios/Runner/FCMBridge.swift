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
				//			} else if (call.method == "unlock") {
				//				guard let arguments = call.arguments as? NSDictionary,
				//							let key = arguments ["key"] as? String,
				//							let username = arguments ["username"] as? String,
				//							let token = arguments ["token"] as? String,
				//							let password = arguments["password"] as? String
				//				else {
				//					result(FlutterMethodNotImplemented)
				//					return
				//				}
				//				self?.unlock(username: username, password: password, key: key, token: token, result: result)
				//			} else if (call.method == "clientApp") {
				//				guard
				//					let clientApp = ABDClientApp.clientApplication() as? [String: String],
				//					let data = try? JSONEncoder().encode(clientApp),
				//					let string = String(data: data, encoding: .utf8)
				//				else {
				//					result(FlutterError(code: "UNAVAILABLE",
				//															message: "Credentials were not encrypted.",
				//															details: nil))
				//					return
				//				}
				//				result(string)
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


	//	private func getCredentials(username: String, password: String, result: FlutterResult) {
	//		guard
	//			let encryptedData = cryptography!.loginParams(forEmail: username, password: password) as? [String: String],
	//			let data = try? JSONEncoder().encode(encryptedData),
	//			let string = String(data: data, encoding: .utf8)
	//		else {
	//			result(FlutterError(code: "UNAVAILABLE",
	//													message: "Credentials were not encrypted.",
	//													details: nil))
	//			return
	//		}
	//		result(string)
	//	}
	//
	//	private func unlock(
	//		username: String,
	//		password: String,
	//		key: String,
	//		token: String,
	//		result: FlutterResult
	//	) {
	//		guard
	//			!password.isEmpty, !key.isEmpty, !username.isEmpty, !token.isEmpty,
	//			cryptography != nil,
	//			let data = cryptography!.decryptLoginKey(key, withPassword: password),
	//			!data.isEmpty,
	//			let string = String(data: data, encoding: .utf8),
	//			!string.isEmpty
	//		else {
	//			result(FlutterError(code: "UNAVAILABLE",
	//													message: "Couldn't decrypte key",
	//													details: nil))
	//			return
	//		}
	//		result("")
	//	}

}
