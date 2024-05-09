import SwiftUI
import ParseSwift
import UserNotifications

// Defines the main structure for the SwiftUI application.
@main
struct pushnotificationApp: App {
    // Attaches the AppDelegate class to handle app delegate responsibilities.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // The main content view that will be displayed when the app launches.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Conforms to UIApplicationDelegate to handle application lifecycle and push notification events.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // Called when the app finishes launching.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Triggers the push notification registration process.
        registerForPushNotifications()
        return true
    }

    // Receives the device token from APNs after successful registration.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Converts the binary device token into a string of hexadecimal characters.
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    
        // Stores the device token in UserDefaults for later use across the app.
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }

    // Called if there is an error during the registration for remote notifications.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    // Called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Allows the notification to be presented while the app is in the foreground.
        completionHandler([.banner, .badge, .sound])
    }

    // Called to let your app handle the user's interaction with the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Extracts and logs the user information from the notification.
        let userInfo = response.notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")
        // Calls the completion handler when the action has been handled.
        completionHandler()
    }

    // Requests authorization for displaying alerts, badge icons, and sounds to the user.
    private func registerForPushNotifications() {
        // Sets the delegate to self to handle foreground notification presentation and response.
        UNUserNotificationCenter.current().delegate = self
        // Requests authorization for alert, sound, and badge notifications.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            // Proceeds to register for remote notifications only if permission is granted.
            guard granted else { return }
            DispatchQueue.main.async {
                // Registers the application with APNs to receive remote notifications.
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // Updates the Parse server Installation object with the new device token.
    private func updateInstallation(withToken deviceToken: String) {
        // Fetches the current installation object from Parse.
        guard var currentInstallation = Installation.current else {
            print("Failed to get current installation")
            return
        }
        // Sets the device token to the current installation.
        currentInstallation.deviceToken = deviceToken
        // Saves the updated installation object back to the Parse server.
        currentInstallation.save { result in
            switch result {
            case .success(let updatedInstallation):
                print("Successfully updated Installation with deviceToken to ParseServer: \(updatedInstallation)")
            case .failure(let error):
                print("Failed to update installation: \(error)")
            }
        }
    }
}
