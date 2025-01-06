//
//  ManagerView.swift
//  CCGTime
//
//  Created by Ben Rosario on 10/14/24.
//

import SwiftUI
import Firebase
import LocalAuthentication

struct IdentifiableView: Identifiable {
    let view: AnyView
    let id = UUID()
}

struct ManagerView: View {
    
    @EnvironmentObject var user: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @State private var showingArchiveAlert = false
    @State private var showingUnarchiveAlert = false
    @State private var showingDeleteAlert = false
    @State private var currentDept: String = ""
    @State private var nextView: IdentifiableView? = nil
    
    @State private var showGenerateReportSheet = false
    @State private var showGenerateReportError = false
    
    @State private var showAddNewEmployeeSheet = false
    @State private var showCreateEmployeeError = false
    
    @State private var showAccountSettingsSheet = false
    
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    @State private var selectedDepartment: String = ""
    
    @StateObject var authModel = AuthModel()
    
    // Set Colors for button gradient
    private let color1 = Color(hex: 0x3494E6)
    private let color2 = Color(hex: 0xEC6EAD)
    
    var activeEmployeesSection: some View {
        Section("Active Employees") {
            ForEach(departmentModel.activeTimecards, id: \.self) { activeTc in
                NavigationLink(destination: ActiveTimecardManagementView(activeTc)) {
                    Text("**\(activeTc.employee.name)**  \nWorking for \(activeTc.getShiftLengthString())")
                }
            }
        }
    }
    
    var employeeSection: some View {
        Section("All Employees") {
            
            ForEach(employeeModel.employeeIdStrings, id: \.self) { item in
                
                let empName = employeeModel.getName(id: item, withId: false)
                
                NavigationLink(destination: EmployeeManagementView(employeeId: item)) {
                    Text(empName)
                }
            }
        }
    }
    
    var currentDepartmentsSection: some View {
        Section("Departments") {
            ForEach(departmentModel.deptStrings, id: \.self) { item in
                
                NavigationLink(destination: DepartmentView(dept: item)) {
                    Text(item)
                        .swipeActions(allowsFullSwipe: false) {
                            Button("Archive") {
                                currentDept = item
                                showingArchiveAlert = true
                            }
                        }
                        .tint(.red)
                }
            }
        }
    }
    
    var archivedDepartmentsSection: some View {
        Section("Archived Departments") {
            ForEach(departmentModel.archiveStrings, id: \.self) { item in
                NavigationLink(destination: DepartmentView(dept: item)) {
                    Text(item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete") {
                                currentDept = item
                                showingDeleteAlert = true
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button("Unarchive") {
                                currentDept = item
                                showingUnarchiveAlert = true
                            }
                            .tint(.blue)
                        }
                }
            }
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            // Has to be inside the navigation view, otherwise the entire ViewController refreshes
            
            if authModel.isUnlocked == true {
                
                VStack(alignment: .center) {
                    
                    List {
                        activeEmployeesSection
                        currentDepartmentsSection
                        employeeSection
                        archivedDepartmentsSection
                    }
                    .alert(Text("Error"), isPresented: $showGenerateReportError) {} message: {
                        Text("You have no timesheets created yet, you cannot generate a report")
                    }
                    .alert(Text("Error"), isPresented: $showCreateEmployeeError) {} message: {
                        Text("You must create a department before you can create employees")
                    }
                    // Confirmation dialogue for delete button
                    .confirmationDialog(
                        "Are you sure you want to delete \'\(currentDept)\'? \nYou cannot undo this action.",
                        isPresented: $showingDeleteAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Delete") {
                            withAnimation {
                                departmentModel.deleteDepartment(currentDept)
                            }
                        }
                    }
                    // Confirmation dialogue for archive button
                    .confirmationDialog(
                        "Are you sure you want to archive \'\(currentDept)\'?",
                        isPresented: $showingArchiveAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Archive") {
                            withAnimation {
                                departmentModel.archiveDepartment(currentDept)
                            }
                        }
                    }
                    // Confirmation Dialogue for unarchive button
                    .confirmationDialog(
                        "Are you sure you want to unarchive \'\(currentDept)\'?",
                        isPresented: $showingUnarchiveAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Unarchive") {
                            withAnimation {
                                departmentModel.unarchiveDepartment(currentDept)
                            }
                        }
                    }
                }
                .onAppear {
                    departmentModel.getEarliestDate()
                }
                // Sheet for Generate Report button
                .sheet(isPresented: $showGenerateReportSheet) {
                    GenerateReportView(
                        showGenerateReportAlert: $showGenerateReportSheet,
                        selectedStartDate: $selectedStartDate,
                        selectedEndDate: $selectedEndDate,
                        selectedDepartment: $selectedDepartment,
                        earliestDate: departmentModel.earliestDate!
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showAddNewEmployeeSheet) {
                    AddEmployeeView(showAddNewEmployeeSheet: $showAddNewEmployeeSheet)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showAccountSettingsSheet) {
                    AccountView(showAccountSettingsSheet: $showAccountSettingsSheet)
                        .presentationDetents([.large, .medium])
                        .presentationDragIndicator(.visible)
                }
                .navigationTitle("Management")
                .toolbar {
                    ToolbarItemGroup() {
                        Menu("Tools") {
                            
                            // Create New Department button
                            Button("Create New Department", systemImage: "note.text.badge.plus") {
                                Alert.newDept(departmentModel: departmentModel)
                            }
                                        
                            // Generate Report button
                            Button("Generate Report", systemImage: "tablecells") {
                                if let _ = departmentModel.earliestDate {
                                    showGenerateReportSheet = true
                                } else {
                                    showGenerateReportError = true
                                }
                            }
                            
                            // Add New Employee button
                            Button("Add New Employee", systemImage: "person.badge.plus") {
                                if departmentModel.deptStrings.count > 0 {
                                    showAddNewEmployeeSheet = true
                                } else {
                                    showCreateEmployeeError = true
                                }
                            }
                            
                            // Account Settings button
                            Button("Account Settings", systemImage: "gearshape.fill") {
                                showAccountSettingsSheet = true
                            }
                            
                        }
                    }
                }

                
            } else {
                Button(action: authModel.authenticate, label: {
                    Text("Unlock Manager View")
                        .font(.system(.title2))
                        .fontWeight(.bold)
                })
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    
                    
            }
        }
        .onDisappear(perform: authModel.lock)
    }
}

struct ManagerView_Previews: PreviewProvider {
    static var previews: some View {
        ManagerView()
    }
}
