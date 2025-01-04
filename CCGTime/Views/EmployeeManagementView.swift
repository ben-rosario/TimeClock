//
//  EmployeeManagementView.swift
//  CCGTime
//
//  Created by Ben on 11/2/24.
//

import Foundation
import SwiftUI

struct EmployeeManagementView: View {
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var employeeModel: EmployeeModel
    var employeeId: String
    
    init(employeeId: String) {
        self.employeeId = employeeId
    }
    
    var body: some View {
        
        let employee = employeeModel.employees[employeeId]
        let employeeName: String = employee?.name ?? "ERROR | Name was nil"
        let employeeDept: String = employee?.department ?? "ERROR | Department was nil"
        
        let employeeWage: Double = employee?.wage ?? 0.0
        let employeeWageString: String = String(format: "%.2f", employeeWage)
        
        return VStack(alignment: .center) {
            List {
                Section("Full Name") {
                    Text(employeeName)
                }
                
                Section("ID Number") {
                    Text(employeeId)
                }
                
                Section("Assigned Department") {
                    Text(employeeDept)
                }
                
                Section("Wage") {
                    Text("$\(employeeWageString) / hour")
                }

            }
        }
        .navigationTitle("Employee Details")
        
    }
}



struct EmployeeManagementView_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeManagementView(employeeId: "0155")
    }
}
