//
//  UserBridge.swift
//  Runner
//
//  Created by Sagar on 14/04/22.
//

import Foundation
import Flutter
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

struct FireStoreUserJsonResponse: Codable {
	let spkcc: [String]
	let dlux: [String]
	let duat: [String]
	let token: String
}

class UserBridge {
	static let shared = UserBridge()
	var channel: FlutterMethodChannel?

	func setup(with controller: FlutterViewController) {
		self.channel = FlutterMethodChannel(
			name: "com.sagar.nodifier/user",
			binaryMessenger: controller.binaryMessenger)
		self.channel?.setMethodCallHandler { [weak self] (call, result) in
			if call.method == "data" {
				self?.fetchData(result)
			} else if call.method == "update",
								let arguments = call.arguments as? NSDictionary {
				let spkcc = arguments ["spkcc"] as? [String] ?? []
				let dlux = arguments ["dlux"] as? [String] ?? []
				let duat = arguments ["duat"] as? [String] ?? []
				self?.updateDocument(spkcc, dlux: dlux, duat: duat, result: result)
			} else {
				let flutterError = FlutterError(
					code: "Failure",
					message: "Method not implemented",
					details: nil)
				result(flutterError)
			}
		}
	}

	@objc func fetchData(_ result: @escaping FlutterResult) {
		guard
			let user = Auth.auth().currentUser,
			user.isAnonymous,
			!user.uid.isEmpty
		else {
			let flutterError = FlutterError(
				code: "AuthFailed",
				message: "Firebase anonymous Auth failed.",
				details: nil)
			result(flutterError)
			return
		}
		let db = Firestore.firestore()
		let documentRef = db.collection("users").document(user.uid)
		documentRef.getDocument { (document, error) in
			guard
				let document = document,
				document.exists,
				let dataDescription = document.data(),
				let token = dataDescription["token"] as? String
			else {
				self.newOrInvalidDocumentCase(user, result: result)
				return
			}
			let spkcc = dataDescription["spkcc"] as? [String] ?? []
			let dlux = dataDescription["dlux"] as? [String] ?? []
			let duat = dataDescription["duat"] as? [String] ?? []
			Messaging.messaging().token { fcmToken, error in
				debugPrint("FCM Token is \(fcmToken ?? "")")
				if (error != nil || fcmToken == nil) {
					// couldn't find fcm token
					let flutterError = FlutterError(
						code: "FCMFailed",
						message: "Couldn't found FCM Token. \(error?.localizedDescription ?? "")",
						details: nil)
					result(flutterError)
				} else if let fcmToken = fcmToken, fcmToken != token {
					debugPrint("New FCM token is \(fcmToken)")
					// different fcm token found.
					documentRef.setData([
						"dlux": dlux,
						"spkcc": spkcc,
						"duat": duat,
						"token": fcmToken
					]) { error in
						if let err = error {
							let flutterError = FlutterError(
								code: "FireStoreFailed",
								message: "Couldn't write to firestore. \(err.localizedDescription)",
								details: nil)
							result(flutterError)
						} else {
							// return json here.
							let response = FireStoreUserJsonResponse(spkcc: spkcc, dlux: dlux, duat: duat, token: fcmToken)
							let string = self.dataToString(try! JSONEncoder().encode(response))
							result(string)
						}
					}
				} else {
					// no need to update FCM token, so return success response
					let response = FireStoreUserJsonResponse(spkcc: spkcc, dlux: dlux, duat: duat, token: token)
					let string = self.dataToString(try! JSONEncoder().encode(response))
					result(string)
				}
			}
		}
	}

	func newOrInvalidDocumentCase(_ user: User, result: @escaping FlutterResult) {
		let db = Firestore.firestore()
		let documentRef = db.collection("users").document(user.uid)
		Messaging.messaging().token { fcmToken, error in
			debugPrint("FCM Token is \(fcmToken ?? "")")
			if (error != nil || fcmToken == nil) {
				// couldn't find fcm token
				let flutterError = FlutterError(
					code: "FCMFailed",
					message: "Couldn't found FCM Token. \(error?.localizedDescription ?? "")",
					details: nil)
				result(flutterError)
			} else {
				documentRef.setData([
					"dlux": [],
					"spkcc": [],
					"duat": [],
					"token": fcmToken!
				]) { error in
					if let err = error {
						let flutterError = FlutterError(
							code: "FireStoreFailed",
							message: "Couldn't write to firestore. \(err.localizedDescription)",
							details: nil)
						result(flutterError)
					} else {
						let response = FireStoreUserJsonResponse(spkcc: [], dlux: [], token: fcmToken!)
						let string = self.dataToString(try! JSONEncoder().encode(response))
						result(string)
					}
				}
			}
		}
	}

	func updateDocument(_ spkcc: [String], dlux: [String], duat: [String], result: @escaping FlutterResult) {
		guard
			let user = Auth.auth().currentUser,
			user.isAnonymous,
			!user.uid.isEmpty
		else {
			let flutterError = FlutterError(
				code: "AuthFailed",
				message: "Firebase anonymous Auth failed.",
				details: nil)
			result(flutterError)
			return
		}
		let db = Firestore.firestore()
		let documentRef = db.collection("users").document(user.uid)
		Messaging.messaging().token { fcmToken, error in
			if (error != nil || fcmToken == nil) {
				// couldn't find fcm token
				let flutterError = FlutterError(
					code: "FCMFailed",
					message: "Couldn't found FCM Token. \(error?.localizedDescription ?? "")",
					details: nil)
				result(flutterError)
			} else {
				documentRef.setData([
					"dlux": dlux,
					"spkcc": spkcc,
					"duat": duat,
					"token": fcmToken!
				]) { error in
					if let err = error {
						let flutterError = FlutterError(
							code: "FireStoreFailed",
							message: "Couldn't write to firestore. \(err.localizedDescription)",
							details: nil)
						result(flutterError)
					} else {
						let response = FireStoreUserJsonResponse(spkcc: spkcc, dlux: dlux, duat: duat, token: fcmToken!)
						let string = self.dataToString(try! JSONEncoder().encode(response))
						result(string)
					}
				}
			}
		}
	}

	func dataToString(_ data: Data) -> String {
		String(data: data, encoding: .utf8)!
	}
}
