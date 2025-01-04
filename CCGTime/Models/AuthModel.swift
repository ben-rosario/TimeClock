//
//  AuthModel.swift
//  CCGTime
//
//  Created by ben on 10/21/24.
//

import Foundation
import LocalAuthentication
import Firebase
import FirebaseAuth

class AuthModel: ObservableObject {
    
    @Published var isUnlocked : Bool = false
    
    func lock() {
        self.isUnlocked = false
    }
    
    func authenticate() {
        if isUnlocked == false {
            let context = LAContext()
            var error: NSError?
            
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // it's possible, so go ahead and use it
                let reason = "To protect the manager section of the app."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            self.isUnlocked = true
                        } else {
                            // Runs if user HAS biometrics but hits cancel
                            self.isUnlocked = false
                            //Alert.message("Authentication Error", authenticationError.debugDescription)
                            self.passwordAuth()
                        }
                    }
                }
            } else {
                print("no biometrics, proceeding with manual password authentication")
                self.passwordAuth()
            }
        // runs isUnlocked is true
        } else {
            print("View is already unlocked")
        }
    }
    
    private func passwordAuth() {
        
        Alert.promptForString(header: "Enter Password", message: "Enter your account password to unlock.", placeholderText: "Password", isSecureText: true) { result in
            
            if result != "" {
                let password = result
                
                guard let user = Auth.auth().currentUser, let email = user.email else {
                    print("User is not logged in")
                    return
                }
                
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                
                user.reauthenticate(with: credential) { authResult, error in
                        if let error = error {
                            self.isUnlocked = false
                            Alert.error(error.localizedDescription)
                        } else {
                            self.isUnlocked = true
                        }
                }
            } else {
                return
            }
            
        }
        
    }
}
