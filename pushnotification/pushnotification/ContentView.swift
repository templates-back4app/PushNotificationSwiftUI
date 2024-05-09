import SwiftUI
import ParseSwift

// Defines the main view for the app.
struct ContentView: View {
    // Initializes the view and sets up the Parse SDK with the app's configuration.
    init() {
        
        /***********************
         Parse initialization. You can get your App ID and Client key at:
         
         Your app's Dashboard -> App Settings -> Security and Keys
         
         Don't forget to upload your certificate (P8 format) at:
         
         Your app's Dashboard -> App Settings -> Server Settings -> iOS Push Notification
         
        ***********************/
        
        ParseSwift.initialize(
            applicationId: "YourAppIdHere",
            clientKey: "YourClientKeyHere",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
    }
    
    // State variables to store user input and error messages.
    @State private var myUsername: String = ""
    @State private var myPassword: String = ""
    @State private var errorMessage: String?
    
    // The body of the view, defining the user interface.
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, Back4app!")
            TextField("Username", text: $myUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $myPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Sign Up") {
                signUp()
            }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            
            // Displays error messages if any.
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    // Handles user sign up process.
    private func signUp() {
        // Logs out the current user before attempting to sign up a new user.
        User.logout { result in
            switch result {
            case .success:
                print("User was logged out successfully")
            case .failure(let logoutError):
                print("Error during logout: \(logoutError.localizedDescription)")
                // Bypasses logout errors related to session token validity.
                if logoutError.code.rawValue == 209 {
                    print("Proceeding with sign-up despite session error.")
                }
            }
            self.proceedWithSignUp()
        }
    }
    
    // Attempts to sign up a new user.
    private func proceedWithSignUp() {
        User.signup(username: myUsername, password: myPassword) { result in
            switch result {
            case .success:
                self.errorMessage = "User registered successfully!"
                // Attempts to update the installation with a device token if available.
                if let token = UserDefaults.standard.string(forKey: "deviceToken") {
                    updateInstallation(withToken: token)
                } else {
                    print("NO TOKEN FOUND")
                }
            case .failure(let error):
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    // Updates the current Installation object with a new device token.
    private func updateInstallation(withToken deviceToken: String) {
        guard var currentInstallation = Installation.current else {
            print("Failed to get current installation")
            return
        }
        currentInstallation.deviceToken = deviceToken
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

// Defines the User and Installation structs for use with ParseSwift.
struct User: ParseUser {
    var emailVerified: Bool?
    var originalData: Data?
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var username: String?
    var email: String?
    var password: String?
    var authData: [String: [String: String]?]?
}

struct Installation: ParseInstallation {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    var installationId: String?
    var deviceType: String?
    var deviceToken: String?
    var badge: Int?
    var timeZone: String?
    var channels: [String]?
    var appName: String?
    var appIdentifier: String?
    var appVersion: String?
    var parseVersion: String?
    var localeIdentifier: String?
}

// Provides a preview of ContentView in Xcode's canvas.
#Preview {
    ContentView()
}
