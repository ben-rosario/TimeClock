//
//  NotificationView.swift
//  CCGTime
//
//  Created by ben on 1/26/25.
//

import SwiftUI
import FirebaseFirestore

struct NotificationView: View {
    
    @EnvironmentObject private var departmentModel: DepartmentModel
    @EnvironmentObject private var employeeModel: EmployeeModel
    
    @State private var showTimecardManagementSheet: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section() {
                    ForEach(departmentModel.clockOutNotifications, id: \.self) { notif in
                        Button(action: {
                            var timecard: EmployeeTimecard?
                            Task {
                                timecard = await departmentModel.notifToTimecard(notif)
                                
                                if timecard != nil {
                                    employeeModel.selectTimecard(timecard!)
                                    self.showTimecardManagementSheet = true
                                } else {
                                    Alert.error("Error decoding timecard!")
                                }
                            }
                        }) {
                            Text("\(notif.employee.name) was automatically clocked out on  \(timestampToDateString(notif.date))")
                                .fontWeight(.bold)
                                .font(.headline) // Adjust font size, e.g., .title, .largeTitle, or .system(size: 24)
                                .padding(.all)
                            
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .sheet(isPresented: $showTimecardManagementSheet) {
            TimecardManagementView(showSheet: $showTimecardManagementSheet, employeeModel.getSelectedTimecard()!, isNotification: true)
                .presentationDetents(.init([.large]))
                .presentationDragIndicator(.visible)
        }
    }
}

func timestampToDateString(_ date: FirebaseFirestore.Timestamp) -> String {
    // Convert Firestore Timestamp to Date
    let date = date.dateValue()
        
        // Initialize DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        // Format Date and print it
        return dateFormatter.string(from: date)
}

#Preview {
    NotificationView()
}
