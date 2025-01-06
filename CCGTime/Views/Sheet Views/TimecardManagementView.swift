//
//  TimecardManagementView.swift
//  CCGTime
//
//  Created by ben on 1/5/25.
//

import SwiftUI

struct TimecardManagementView: View {
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @Binding var showSheet: Bool
    
    @State private var showFailureAlert = false
    @State private var showSuccessAlert = false
    @State private var isEditing = false
    @State private var previousEvents: [Date] = []
    @State var timecard: EmployeeTimecard
    
    private var name: String
    private var id: String
    private var wageStr: String
    private var date: Date
    
    let df = DateFormatter()
    let tf = DateFormatter()
    let dateStr: String
    
    init(showSheet: Binding<Bool> ,_ timecard: EmployeeTimecard) {
        df.dateStyle = .medium
        df.timeStyle = .none
        df.timeZone = .current
        
        tf.dateStyle = .none
        tf.timeStyle = .long
        tf.timeZone = .current
        
        self._showSheet = showSheet
        self.timecard = timecard
        self.name = timecard.employee.name
        self.id = timecard.employee.employeeId
        
        self.wageStr = String(format: "%.2f", timecard.employee.wage)
        
        self.date = timecard.timecardEvents.first!
        self.dateStr = df.string(from: date)
        
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                employeeStatus
                    .padding(.vertical)
                
                Text("Total Shift Length: \(timecard.getShiftLengthString())")
                    .padding(.vertical)
                
                showTimecardEvents
            }
            .navigationTitle("\(dateStr) Timecard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    editButton
                }
                ToolbarItem(placement: .topBarLeading) {
                    closeButton
                }
            }
            .alert(Text("Error Saving Timecard"), isPresented: $showFailureAlert) {} message: {
                Text("Make sure that the times are chronological and that there are no dates in the future.")
            }
            .alert(Text("Success!"), isPresented: $showSuccessAlert) {} message: {
                Text("Timecard was updated.")
            }
        }
    }
    
    var closeButton: some View {
        if self.isEditing == false {
            Button("Close") {
                self.showSheet = false
            }
        } else {
            Button("Cancel") {
                self.timecard.timecardEvents = previousEvents
                self.isEditing = false
            }
        }
    }
    
    var editButton: some View {
        if isEditing == false {
            Button(action: {
                self.previousEvents = timecard.timecardEvents
                self.isEditing = true
            }) {
                Text("Edit")
                    .fontWeight(.bold)
            }
        } else {
            Button(action: {
                
                if self.previousEvents != self.timecard.timecardEvents {
                    do {
                        try timecard.editTimecard(events: timecard.timecardEvents, deptModel: departmentModel)
                        showSuccessAlert = true
                        isEditing = false
                    } catch {
                        showFailureAlert = true
                    }
                } else {
                    isEditing = false
                }
                
            }) {
                Text("Save")
                    .fontWeight(.bold)
            }
        }
    }
    
    var employeeStatus: some View {
        if timecard.timecardEvents.count % 2 == 0 {
            Text("\(name) is currently clocked out.")
                .fontWeight(.bold)
                .font(.title)
        } else {
            Text("\(name) has been clocked in for \(timecard.getShiftLengthString()).")
                .fontWeight(.bold)
                .font(.title)
        }
    }
    
    var showTimecardEvents: some View {
        List {
            ForEach(0..<timecard.timecardEvents.count, id: \.self) { index in
                if index % 2 == 0 {
                    DatePicker(
                        "Clocked In: ",
                        selection: $timecard.timecardEvents[index],
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .disabled(!isEditing)
                    
                    
                    /*
                    HStack {
                        Text("Clocked In: ")
                        Text(tf.string(from: timecard.timecardEvents[index]))
                    }
                     */
                } else {
                    DatePicker(
                        "Clocked Out: ",
                        selection: $timecard.timecardEvents[index],
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .disabled(!isEditing)
                    
                    
                    
                    /*
                    HStack {
                        //Text("Clocked Out: ")
                        //Text(tf.string(from: timecard.timecardEvents[index]))
                    }
                     */
                }
            }
        }
    }
}

struct ActiveTimecardManagementView: View {
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @State private var showFailureAlert = false
    @State private var showSuccessAlert = false
    @State private var isEditing = false
    @State private var previousEvents: [Date] = []
    @State var timecard: EmployeeTimecard
    
    private var name: String
    private var id: String
    private var wageStr: String
    private var date: Date
    
    let df = DateFormatter()
    let tf = DateFormatter()
    let dateStr: String
    
    init(_ timecard: EmployeeTimecard) {
        df.dateStyle = .medium
        df.timeStyle = .none
        df.timeZone = .current
        
        tf.dateStyle = .none
        tf.timeStyle = .long
        tf.timeZone = .current
        
        self.timecard = timecard
        self.name = timecard.employee.name
        self.id = timecard.employee.employeeId
        
        self.wageStr = String(format: "%.2f", timecard.employee.wage)
        
        self.date = timecard.timecardEvents.first!
        self.dateStr = df.string(from: date)
        
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("Total Shift Length: \(timecard.getShiftLengthString())")
                    .padding(.vertical)
                
                showTimecardEvents
            }
            .navigationTitle("\(dateStr) Timecard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    editButton
                }
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing == true {
                        cancelButton
                    }
                }
            }
            .alert(Text("Error Saving Timecard"), isPresented: $showFailureAlert) {} message: {
                Text("Make sure that the times are chronological and that there are no dates in the future.")
            }
            .alert(Text("Success!"), isPresented: $showSuccessAlert) {} message: {
                Text("Timecard was updated.")
            }
        }
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            self.timecard.timecardEvents = previousEvents
            self.isEditing = false
        }
    }
    
    var editButton: some View {
        if isEditing == false {
            Button(action: {
                self.previousEvents = timecard.timecardEvents
                self.isEditing = true
            }) {
                Text("Edit")
                    .fontWeight(.bold)
            }
        } else {
            Button(action: {
                
                if self.previousEvents != self.timecard.timecardEvents {
                    do {
                        try timecard.editTimecard(events: timecard.timecardEvents, deptModel: departmentModel)
                        showSuccessAlert = true
                        isEditing = false
                    } catch {
                        showFailureAlert = true
                    }
                } else {
                    isEditing = false
                }
                
            }) {
                Text("Save")
                    .fontWeight(.bold)
            }
        }
    }
    
    var showTimecardEvents: some View {
        List {
            ForEach(0..<timecard.timecardEvents.count, id: \.self) { index in
                if index % 2 == 0 {
                    DatePicker(
                        "Clocked In: ",
                        selection: $timecard.timecardEvents[index],
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .disabled(!isEditing)
                    
                    
                    /*
                    HStack {
                        Text("Clocked In: ")
                        Text(tf.string(from: timecard.timecardEvents[index]))
                    }
                     */
                } else {
                    DatePicker(
                        "Clocked Out: ",
                        selection: $timecard.timecardEvents[index],
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .disabled(!isEditing)
                    
                    
                    
                    /*
                    HStack {
                        //Text("Clocked Out: ")
                        //Text(tf.string(from: timecard.timecardEvents[index]))
                    }
                     */
                }
            }
        }
    }
}


#Preview {
    //TimecardManagementView()
}
