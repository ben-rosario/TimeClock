//
//  ViewController.swift
//  CCGTime
//
//  Created by Ben Rosario on 10/14/24.
//

import SwiftUI
import Combine

struct ViewController: View {
    
    @EnvironmentObject var user: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    var body: some View {

        TabView {
            EmployeeView()
                .environmentObject(departmentModel)
                .environmentObject(employeeModel)
                .tabItem {
                    Image(systemName: "clock")
                        Text("Timecards")
                }
            
            ManagerView()
                .environmentObject(departmentModel)
                .environmentObject(employeeModel)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                        Text("Manager")
                }
        }
    }
}

#Preview {
    //ViewController()
}


// NumbersOnly
// Used to restrict text input to only filtered keywords
// Used in creating new employees to ensure employeeIDs are only composed of digits
// Maybe move to seperate file?

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { "0123456789".contains($0) }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

// FloatsOnly
// Used to restrict text input to only filtered keywords
// Rework needed, as I believe you can insert multiple periods (.) in one field
// Maybe move to seperate file?

class FloatsOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { "0123456789.".contains($0) }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
