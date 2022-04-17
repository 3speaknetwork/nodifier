import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
	weak var app: UIApplication? = nil
	override func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		app = application
		let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
		GeneratedPluginRegistrant.register(with: self)
		FirebaseApp.configure()
		Messaging.messaging().delegate = self
		FCMBridge.shared.setup(with: controller)
		AuthBridge.shared.setup(with: controller)
		UserBridge.shared.setup(with: controller)
		return super.application(application, didFinishLaunchingWithOptions: launchOptions)
	}

	func registerForNotification(_ handler: @escaping (Bool, Error?) -> Void) {
		UNUserNotificationCenter.current().delegate = self
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions, completionHandler: handler)
		app?.registerForRemoteNotifications()
	}
}


extension AppDelegate: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		print("FCM token: \(String(describing: fcmToken))")
	}
}
