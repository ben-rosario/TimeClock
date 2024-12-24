//
//  SignupView.swift
//  CCGTime
//
//  Created by ben on 4/8/24.
//

import SwiftUI

struct SignupView: View {
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmpassword: String = ""
    
    @EnvironmentObject var session : SessionStore
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 25, content: {
                    
                VStack {
                    Text("Sign up for TimeClock")
                        .font(.system(size: 36))
                        .bold()
                    
                    TextField("First Name", text: $firstName)
                        .frame(width: 200, height: 30)
                        .keyboardType(.default)
                    
                    TextField("Last Name", text: $lastName)
                        .frame(width: 200, height: 30)
                        .keyboardType(.default)
                    
                    TextField("Email", text: $email)
                        .frame(width: 200, height: 30)
                        .keyboardType(.emailAddress)
                    
                    Spacer()
                        .frame(height: 18)
                    
                    SecureField("Password", text: $password)
                        .frame(width: 200, height: 30)
                    
                    Spacer()
                        .frame(height: 18)
                    
                    SecureField("Confirm Password", text: $confirmpassword)
                        .frame(width: 200, height: 30)
                }
                
                
                Button("Create Account") {
                    // TO-DO: Check ALL fields before calling signUp function
                    if (confirmpassword == password) {
                        session.signUp(email: email, password: password, firstName: firstName, lastName: lastName)
                    } else {
                        Alert.error("Passwords do not match!")
                    }
                }
                
                NavigationLink(destination: LoginView()) {
                        Text("Already Have an Account?")
                            .underline()
                            .foregroundColor(Color.blue)
                }
            })
        }
    }
}

#Preview {
    SignupView()
}
