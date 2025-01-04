//
//  AccountView.swift
//  CCGTime
//
//  Created by ben on 10/21/24.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject var user: SessionStore
    
    @Binding var showAccountSettingsSheet: Bool
    
    @State private var signoutAlert = false
    @State private var signoutConfirmation: Bool? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Name")
                    .bold()
                    .font(.system(size:24))
                Text(user.user?.displayName ?? "No Name Found")
                
                Text("Email")
                    .bold()
                    .font(.system(size:24))
                Text((user.user?.email ?? "No Email Found"))
            }
            .navigationTitle("Account Settings")
            .navigationBarItems(
                leading: Button("Back") {
                    showAccountSettingsSheet = false
                },
                trailing: Button("Sign Out") {
                    
                    signoutAlert = true
                }
            )
            .alert(Text("Are You Sure?"), isPresented: $signoutAlert) {
                Button("Cancel", role: .cancel) {
                    signoutConfirmation = false
                }
                Button("Sign Out", role: .destructive) {
                    signoutConfirmation = true
                }
            } message: {
                Text("You will be asked to reenter your email and password.")
            }
            .onChange(of: signoutConfirmation) {
                
                if let _ = signoutConfirmation {
                    if signoutConfirmation ?? false {
                        if user.signOut() {
                            Alert.message("Success!", "You are now signed out.")
                        }
                        else {
                            Alert.message("Error", "Something went wrong signing out.")
                        }
                        signoutAlert = false
                        // Reset the result
                        signoutConfirmation = nil
                    }
                    else {
                        signoutAlert = false
                        // Reset the result
                        signoutConfirmation = nil
                    }
                }
            }
        }
    }
}
