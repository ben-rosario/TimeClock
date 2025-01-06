//
//  LoginView.swift
//  CCGTime
//
//  Created by ben on 10/17/24.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var user: SessionStore
    
    @State private var email = ""
    @State private var password = ""
    
    
    var body: some View {
        NavigationView {
           VStack {
                Text("Log In to TimeClock")
                   .frame(alignment: .top)
                   .font(.system(.title,
                                 design: .rounded,
                                 weight: .bold))
                
               VStack {
                   userDetailsForm
                   loginButton
               }
               .frame(height: 400)
               
               HStack {
                   Text("Don't have an account?")
                       //.padding(.horizontal)
                   NavigationLink(destination: SignupView()) {
                           Text("Sign up")
                               .underline()
                               .foregroundColor(Color.blue)
                   }
                   .padding(.horizontal)
               }
               .padding(.top)
               .frame(alignment: .bottom)
            }
        }
    }
    
    var loginButton: some View {
        Button(action: {
            user.signIn(email: email, password: password)
        }) {
            Text("Login")
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(.white)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue)
                .scaleEffect(1.5)
        )
        
    }
    
    var userDetailsForm: some View {
        Form {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .padding(.all)
            
            SecureField("Password", text: $password)
                .padding(.all)
        }
        .frame(height: 250)
    }
    
}

#Preview {
    LoginView()
}
