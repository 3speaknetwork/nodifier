//
//  AuthBridge.swift
//  Runner
//
//  Created by Sagar on 14/04/22.
//

import Foundation
import Flutter
import Firebase
import FirebaseAuth

class AuthBridge {
	static let shared = AuthBridge()
	var channel: FlutterMethodChannel?

	func setup(with controller: FlutterViewController) {
		self.channel = FlutterMethodChannel(
			name: "com.sagar.nodifier/auth",
			binaryMessenger: controller.binaryMessenger)
		self.channel?.setMethodCallHandler { [weak self] (call, result) in
			if (call.method == "login") {
				self?.login(result)
			}
		}
	}

	private func login(_ result: @escaping FlutterResult) {
		guard
			let user = Auth.auth().currentUser,
			user.isAnonymous,
			!user.uid.isEmpty
		else {
			Auth.auth().signInAnonymously { authResult, error in
				guard
					authResult?.user != nil
				else {
					let error = FlutterError(
						code: "AuthFailed",
						message: "Firebase anonymous Auth failed. \(error?.localizedDescription ?? "")",
						details: nil)
					result(error)
					return
				}
				result("true")
			}
			return
		}
		result("true")
	}
}
