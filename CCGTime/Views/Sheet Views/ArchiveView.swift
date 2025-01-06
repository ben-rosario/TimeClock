//
//  ArchiveView.swift
//  CCGTime
//
//  Created by ben on 1/6/25.
//

import SwiftUI

struct ArchiveView: View {
    
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @Binding var showArchiveSheet: Bool
    
    @State private var currentDept = ""
    @State private var currentEmp: Employee?
    @State private var showingUnarchiveDeptAlert = false
    @State private var showingUnarchiveEmpAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                List {
                    archivedDepartmentsSection
                    archivedEmployeesSection
                }
                /* employee unarchive button */
                .confirmationDialog(
                    "Are you sure you want to unarchive Employee \'\(currentEmp?.name ?? "undefined")\'?",
                    isPresented: $showingUnarchiveEmpAlert,
                    titleVisibility: .visible
                ) {
                    Button("Unarchive") {
                        withAnimation {
                            employeeModel.unarchiveEmployee(currentEmp!.employeeId)
                        }
                    }
                }
                /* department unarchive button */
                .confirmationDialog(
                    "Are you sure you want to unarchive \'\(currentDept)\'?",
                    isPresented: $showingUnarchiveDeptAlert,
                    titleVisibility: .visible
                ) {
                    Button("Unarchive") {
                        withAnimation {
                            departmentModel.unarchiveDepartment(currentDept)
                        }
                    }
                }
            }
            .navigationTitle("Archive")
            .navigationBarItems(
                leading: Button("Close") {
                    showArchiveSheet = false
                }
            )
        }
    }
    
    var archivedDepartmentsSection: some View {
        Section("Archived Departments") {
            if !departmentModel.archivedDeptStrings.isEmpty {
                ForEach(departmentModel.archivedDeptStrings, id: \.self) { item in
                    NavigationLink(destination: DepartmentView(dept: item)) {
                        Text(item)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button("Unarchive") {
                                    currentDept = item
                                    showingUnarchiveDeptAlert = true
                                }
                                .tint(.blue)
                            }
                    }
                }
            } else {
                Text("No Archived Departments")
            }
        }
    }
    
    var archivedEmployeesSection: some View {
        Section("Archived Employees") {
            if !employeeModel.archivedEmployeeStrings.isEmpty {
                ForEach(employeeModel.archivedEmployeeStrings, id: \.self) { empId in
                    NavigationLink(destination: EmployeeManagementView(employeeId: empId)) {
                        Text(employeeModel.employees[empId]!.name)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button("Unarchive") {
                                    currentEmp = employeeModel.employees[empId]!
                                    showingUnarchiveEmpAlert = true
                                }
                                .tint(.blue)
                            }
                    }
                }
            } else {
                Text("No Archived Employees")
            }
        }
    }
}

#Preview {
    //ArchiveView()
}
