import UIKit
import CloudFonMobileSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        setupCloudFonSDK()
        setupPushNotifications(application)
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }

    // MARK: - CloudFon SDK Setup

    private func setupCloudFonSDK() {
        let config = CloudFonConfig(
            baseUrl: "https://cloudcx.cloudfon.net",
            planId: "95fb1eff-6453-4fce-a392-74fb3a5b9c0d",
            apiKey: "",
            debug: true,
            allowedDomains: ["cloudcx.cloudfon.net", "cloudfon.net", "cloudfon.com"],
            pushServiceType: "apns",
            webViewConfig: WebViewConfig()
        )
        
        CloudFonSDK.shared.initialize(config: config)
        
        print("CloudFon SDK initialized successfully")
    }

    // MARK: - Push Notifications Setup

    private func setupPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("CloudFon Push authorization error: \(error)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("CloudFon Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("CloudFon Failed to register for remote notifications: \(error)")
    }
}
