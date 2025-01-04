//
//  GenerateReportView.swift
//  CCGTime
//
//  Created by ben on 12/17/24.
//

import SwiftUI

struct GenerateReportView: View {
    
    @EnvironmentObject var departmentModel: DepartmentModel
    
    @State private var reportUrl: URL?
    @State private var showDepartmentAlert = false
    @State private var showDateRangeAlert = false
    @State private var showShareSheet = false
    @State private var showIllegalCharAlert = false
    @State private var selectedReportTitle = ""
    @State private var waitingForReport = false
    @State private var report: Report?
    
    @Binding var showGenerateReportAlert: Bool
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    @Binding var selectedDepartment: String
    
    public var earliestDate: Date
    
    var body: some View {
        NavigationView {
            if waitingForReport == true && departmentModel.reportIsCompleted() == false {
                //if departmentModel.reportIsInitialized() == true {}
                ProgressView("Generating Report...", value: departmentModel.report?.progress, total: 1.0)
            } else {
                Form {
                    DatePicker(
                        "Start Date",
                        selection: $selectedStartDate,
                        in: earliestDate...Date(),
                        displayedComponents: [.date]
                    )
                    
                    DatePicker(
                        "End Date",
                        selection: $selectedEndDate,
                        in: selectedStartDate...Date(),
                        displayedComponents: [.date]
                    )
                    
                    Picker("Select Department", selection: $selectedDepartment) {
                        Text("Select a Department").tag("")
                        ForEach(departmentModel.deptStrings, id: \.self) { dept in
                            Text(dept)
                        }
                    }
                    
                    TextField(
                        "Name of file",
                        text: $selectedReportTitle
                    )
                }
                .navigationTitle("Generate Report")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showGenerateReportAlert = false
                    },
                    trailing: AsyncButton( action: {
                        // Check if date range is logical
                        if selectedStartDate > selectedEndDate {
                            showDateRangeAlert = true
                        } else {
                            // Check if a department was selected
                            if selectedDepartment.isEmpty {
                                showDepartmentAlert = true
                            } else {
                                // Make sure the given name doesn't have illegal characters using regex
                                if selectedReportTitle.contains(/[\/:*?\"<>|]/) {
                                    self.showIllegalCharAlert = true
                                } else {
                                    await departmentModel.createReport(
                                                   start: selectedStartDate,
                                                   end: selectedEndDate,
                                                   for: selectedDepartment,
                                                   name: selectedReportTitle
                                                 )
                                    self.waitingForReport = true
                                }
                            }
                        }
                    }, label: { Text("Generate") })
                    .alert(Text("Error"), isPresented: $showIllegalCharAlert) {} message: {
                        Text("Invalid Report Title: Title cannot contain any of the following characters:  /  :  *  ?  \"  >  <  |")
                    }
                    .alert(Text("Error"), isPresented: $showDepartmentAlert) {} message: {
                        Text("Please select a department")
                    }
                    .alert(Text("Error"), isPresented: $showDateRangeAlert) {} message: {
                        Text("Starting date must be before end date")
                    }
                )
            }
        }
    }
}

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label

    @State private var isPerformingTask = false

    var body: some View {
        Button(
            action: {
                isPerformingTask = true
            
                Task {
                    await action()
                    isPerformingTask = false
                }
            },
            label: {
                ZStack {
                    // We hide the label by setting its opacity
                    // to zero, since we don't want the button's
                    // size to change while its task is performed:
                    label().opacity(isPerformingTask ? 0 : 1)

                    if isPerformingTask {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isPerformingTask)
    }
}

#Preview {
    //GenerateReportView()
}
