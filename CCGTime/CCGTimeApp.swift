//
//  CCGTimeApp.swift
//  CCG Time
//
//  Created by ben on 10/14/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,

                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()

        return true

      }
}

@main
struct CCGTimeApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var user = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            // If user object has not fully initialized, show a loading screen
            if user.activeSession == nil || (user.user == nil || user.departmentModel == nil || user.employeeModel == nil) {
                ProgressView("Loading user data...")
            // If user object is initialized but there is no active session, show log in screen
            } else if user.activeSession == false {
                LoginView()
                    .environmentObject(user)
            // If user object is initialized and has an active session, show main screen
            } else {
                ViewController()
                    .environmentObject(user)
                    .environmentObject(user.departmentModel!)
                    .environmentObject(user.employeeModel!)
            }
        }
    }
}
