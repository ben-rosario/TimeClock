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
            VStack(alignment: .center, spacing: 25) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.cyan)
                        .frame(width: 999, height: 350)
                    
                    VStack {
                        
                        Text("Log In to TimeClock")
                            .font(.system(size: 36))
                            .bold()
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                            .frame(height: 50)
                        
                        TextField("Email", text: $email)
                            .frame(width: 200, height: 30)
                            .keyboardType(.emailAddress)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(.blue, lineWidth: 2.25)
                                    .scaleEffect(1.25)
                            )
                        
                        Spacer()
                            .frame(height: 18)
                        
                        SecureField("Password", text: $password)
                            .frame(width: 200, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(.blue, lineWidth: 2.25)
                                    //.fill(Color.blue)
                                    .scaleEffect(1.25)
                            )
                    }
                    // end VStack 2
                    
                }
                
                Spacer()
                    .frame(height: 1)
                
                Button("Log In") {
                    user.signIn(email: email, password: password)
                }
                .foregroundColor(Color.white)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black)
                        .scaleEffect(2.6)
                )
                
                
                Spacer()
                    .frame(height: 5)
                
                HStack {
                    
                    Text("Don't have an account?")
                    
                    NavigationLink(destination: SignupView()) {
                            Text("Sign up")
                                .underline()
                                .foregroundColor(Color.blue)
                    }
                }
                
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
        }
    }
    
}

#Preview {
    LoginView()
}
