//
//  User.swift
//  CCGTime
//
//  Created by ben on 11/10/24.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI
import Combine



@MainActor class SessionStore: ObservableObject {
    
    @Published var departmentModel: DepartmentModel?
    @Published var employeeModel: EmployeeModel?
    @Published var user: User?
    @Published var activeSession: Bool?
    
    var uid: String?
    var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.listen()
    }
    
    func listen() {
        // monitor auth changes using firebase
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user.uid)")
                self.user = user
                self.uid = user.uid
                self.activeSession = true
                
                Task {
                    await self.createDeptModel(with: user.uid)
                    await self.createEmpModel(with: user.uid)
                }
                
            } else {
                self.activeSession = false
                print("User has no active session")
            }
        }
    }
    
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String
        ) {
            Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                if let error = error {
                    print("Error creating user: \(error)")
                    Alert.message("Error Creating Account", error.localizedDescription)
                    return
                }
                self.user = authResult?.user
                self.uid = authResult?.user.uid
                let changeRequest = self.user?.createProfileChangeRequest()
                changeRequest?.displayName = "\(firstName) \(lastName)"
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("Error Commiting Account Changes: \(error)")
                    } else {
                        print("Succesfully Signed Up")
                    }
                }
                
            })
        }
    
    func signIn(
        email: String,
        password: String
        ) {
            Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
                if let error = error {
                    print("Error Signing In: \(error)")
                    Alert.message("Error Signing In", error.localizedDescription)
                    return
                }
                self.user = authResult?.user
                self.uid = authResult?.user.uid
                print("Succesfully Signed In")
            })
        }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            self.user = nil
            print("Succesfully Signed Out")
            return true
        } catch {
            print("Error Signing Out: \(error)")
            Alert.message("Error Signing Out", error.localizedDescription)
            return false
        }
    }
    
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func createDeptModel(with uid: String) async {
        self.departmentModel = await DepartmentModel(with: uid)
    }
    
    func createEmpModel(with uid: String) async {
        self.employeeModel = await EmployeeModel(with: uid)
    }
}
