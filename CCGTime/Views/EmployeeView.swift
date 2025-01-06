//
//  Employee.swift
//  CCGTime
//
//  Created by ben on 10/25/24.
//

import SwiftUI

struct EmployeeView: View {
    
    @EnvironmentObject var session : SessionStore
    @EnvironmentObject var departmentModel : DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @ObservedObject private var employeeNumber = NumbersOnly()
    
    // Input Field Variables
    @State private var employeeDepartment = ""
    @State private var selectedDepartment = "Select A Department"
    
    // Sheet Presentation Bindings
    @State private var showTimecardSheet = false
    
    // Derived Data Optionals
    @State private var foundEmployee: Employee?
    @State private var foundTimecard: EmployeeTimecard?
    
    // SwiftUI Binding
    @FocusState private var kbFocused: Bool
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .center, spacing: 35) {
                    Spacer().frame(height: 150)
                    
                    departmentsList
                    employeeIdField
                    
                    Spacer().frame(height: 10)
                            
                    viewTimecardButton
                    
                    Spacer().frame(height: 150)
                }
                .sheet(isPresented: $showTimecardSheet) {
                    if let _ = departmentModel.currentTimecard {
                        EmployeeTimecardView(showSheet: $showTimecardSheet, departmentModel.currentTimecard!)
                            .presentationDetents([.fraction(0.45)])
                            .presentationDragIndicator(.hidden)
                        
                    } else {
                        Text("Error Creating Timecard!")
                    }
                    
                }
            }
            .navigationTitle("Timecards")
        }
    }
    
    var departmentsList: some View {
        Menu(selectedDepartment) {
            ForEach(departmentModel.deptStrings, id: \.self) { item in
                Button(item) {
                    self.selectedDepartment = item
                    self.employeeDepartment = item
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 7.5)
                .strokeBorder(.blue, lineWidth: 2)
                .scaleEffect(1.75)
        )
        .fixedSize()
    }
    
    var employeeIdField: some View {
        TextField("Employee ID", text: $employeeNumber.value)
            .fixedSize()
            .focused($kbFocused)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 120)
            .overlay {
                RoundedRectangle(cornerRadius: 7.5)
                    .strokeBorder(.blue, lineWidth: 2)
                    .scaleEffect(1.75)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Close") {
                        kbFocused = false
                    }
                }
            }
    }
    
    var viewTimecardButton: some View {
        AsyncButton( action: {
            
            let empNum = employeeNumber.value
            let selectedDept = employeeDepartment
            
            // Check if user selected a department
            if (employeeDepartment == "") {
                Alert.error("Please select a department.")
            }
            else if (empNum == "") {
                Alert.error("Please enter an ID number.")
            } else {
                
                if departmentModel.hasCorrectInfo(empId: empNum, dept: selectedDept) {
                    let dateString = departmentModel.stringFromDate(Date())
                    self.foundEmployee = departmentModel.employees[empNum]
                    // Set the departmentModel.currentTimecard variable
                    await departmentModel.getTimecard(emp: foundEmployee!, dateStr: dateString)
                    self.showTimecardSheet = true
                    self.kbFocused = false
                }
                // Display error alert when hasCorrectInfo is false
                else {
                    if let _ = departmentModel.employees[empNum] {
                        Alert.error("Employee \(empNum) is not assigned to \(selectedDept)")
                    } else {
                        Alert.error("Employee \(empNum) does not exist")
                    }
                }
                
            }
            
        }, label: {
            Text("View Timecard")
                .fontWeight(.bold)
        })
        .fixedSize()
        .foregroundColor(Color.white)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue)
                .scaleEffect(1.6)
        )
    }
}

struct EmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeView()
    }
}
