//
//  SignupView.swift
//  CCGTime
//
//  Created by ben on 10/17/24.
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
            VStack(alignment: .center, content: {
                    
                Text("Sign up for TimeClock")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .frame(alignment: .top)
                
                Form { userInfoForm }
                
                createAccountButton
                    .padding(.bottom)
            })
        }
    }
    
    var createAccountButton: some View {
        Button(action: {
            // TODO: Check ALL fields before calling signUp function
            if confirmpassword != password { Alert.error("Passwords do not match!") }
            // TODO: add validData(), or any other method of checking validity
            // else if validData() == false {}
            else {
                session.signUp(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )}
        }) {
            Text("Create Account")
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(.white)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue)
                .scaleEffect(1.5)
                .frame(width: 220)
        )
    }
    
    var userInfoForm: some View {
        VStack {
            TextField("First Name", text: $firstName)
                .keyboardType(.default)
                .padding(.all)
            
            TextField("Last Name", text: $lastName)
                .keyboardType(.default)
                .padding(.all)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .padding(.all)
            
            SecureField("Password", text: $password)
                .padding(.all)
            
            SecureField("Confirm Password", text: $confirmpassword)
                .padding(.all)
        }
    }
}

#Preview {
    SignupView()
}
