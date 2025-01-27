//
//  AccountView.swift
//  CCGTime
//
//  Created by ben on 10/21/24.
//

import SwiftUI

struct AccountView: View {
    
    
    
    @EnvironmentObject var user: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    
    @Binding var showAccountSettingsSheet: Bool
    @State private var showTimezoneChangeError = false
    
    @State private var signoutAlert = false
    @State private var signoutConfirmation: Bool? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                List {
                    nameInfo
                    emailInfo
                    timezoneSetting
                }
            }
            .navigationTitle("Account Info")
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
            .alert(Text("Error"), isPresented: $showTimezoneChangeError) {} message: {
                Text("Employees are currently clocked in. Please try again when all employees are clocked out.")
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
    
    var nameInfo: some View {
        Section("Name") {
            Text(user.user?.displayName ?? "No Name Found")
        }
    }
    
    var emailInfo: some View {
        Section("Email") {
            Text((user.user?.email ?? "No Email Found"))
        }
    }
    
    var timezoneSetting: some View {
        Section("Selected Timezone") {
            Menu(departmentModel.timezone) {
                ForEach(departmentModel.timezones, id: \.self) { timezone in
                    Button(timezone) {
                        if departmentModel.hasActiveTimecards() == false {
                            departmentModel.updateTimezone(timezone)
                        } else {
                            showTimezoneChangeError = true
                        }
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}
