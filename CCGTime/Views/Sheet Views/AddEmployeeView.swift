//
//  AddEmployeeView.swift
//  CCGTime
//
//  Created by ben on 5/25/22.
//

import SwiftUI

struct AddEmployeeView: View {
    
    @EnvironmentObject var user: SessionStore
    @EnvironmentObject var departmentModel : DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @Binding var showAddNewEmployeeSheet: Bool
    
    @State private var creationSuccessAlert = false
    @State private var creationFailureAlert = false
    
    @State private var selectedDepartment = "Select A Department"

    @State private var employeeFirstname = ""
    @State private var employeeLastname = ""
    @State private var employeeDepartment = ""
    
    @ObservedObject fileprivate var employeeNumber = NumbersOnly()
    @ObservedObject fileprivate var employeeWage = FloatsOnly()
    
    func clearForm() {
        self.employeeFirstname = ""
        self.employeeLastname = ""
        self.employeeDepartment = ""
        self.employeeNumber.value = ""
        self.employeeWage.value = ""
    }
    
    func formIsValid() -> Bool {
        
        if self.employeeFirstname == "" { return false }
        else if self.employeeLastname == "" { return false }
        else if self.employeeDepartment == "" { return false }
        else if self.employeeNumber.value == "" { return false }
        else if self.employeeWage.value == "" { return false }
        else { return true }
        
    }
    
    var body: some View {
        NavigationView{
            VStack{
                
                Form(){
                    Section(header: Text("Details")){
                        TextField("Enter First Name", text: $employeeFirstname)
                        
                        TextField("Enter Last Name", text: $employeeLastname)
                        
                        TextField("Enter Employee ID Number", text: $employeeNumber.value)
                            .keyboardType(.numberPad)
                        
                        TextField("Input Hourly Wage", text: $employeeWage.value)
                            .keyboardType(.decimalPad)
                        
                        Menu(selectedDepartment) {
                            ForEach(departmentModel.deptStrings, id: \.self) { item in
                                Button(item) {
                                    self.selectedDepartment = item
                                    self.employeeDepartment = item
                                }
                            }
                        }
                    }
                }
                .alert("Success!", isPresented: $creationSuccessAlert) {
                    // buttons
                } message: {
                    Text("Employee was added.")
                }
            }
            .navigationTitle("Add New Employee")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showAddNewEmployeeSheet = false
                },
                trailing: Button("Create") {
                    if formIsValid() {
                        let newEmp = employeeModel.createNewEmployee(firstName: employeeFirstname, lastName: employeeLastname, id: employeeNumber, wage: employeeWage, department: employeeDepartment)
                        
                        departmentModel.allEmployees[employeeNumber.value] = newEmp
                        
                        creationSuccessAlert = true
                        
                        clearForm()
                    }
                    else {
                        // TODO: (?) Display exactly which entries are invalid using a for loop
                        creationFailureAlert = true
                    }
                }
            )
            
        }
    }
}

/*
struct AddEmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEmployeeView()
    }
}
*/
