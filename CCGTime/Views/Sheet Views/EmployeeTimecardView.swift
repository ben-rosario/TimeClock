//
//  EmployeeTimecardView.swift
//  CCGTime
//
//  Created by ben on 1/3/25.
//

import SwiftUI

struct EmployeeTimecardView: View {
    
    @EnvironmentObject var session : SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    @State private var showClockInError = false
    @State private var showClockOutError = false
    
    @State var timecard: EmployeeTimecard
    var employee: Employee
    @Binding var showSheet: Bool
    var titleText: Text
    
    // View will always default to user's current date
    init(showSheet: Binding<Bool>, _ tc: EmployeeTimecard) {
        self.timecard = tc
        self.employee = tc.employee
        self._showSheet = showSheet
        
        // Set colors for gradient
        let color1 = Color(hex: 0x12C2E9)
        let color2 = Color(hex: 0xC471ED)
        let color3 = Color(hex: 0xF64F59)
        
        self.titleText = Text("Hi \(employee.firstName),")
            .font(.system(.largeTitle, design: .rounded))
            .fontWeight(.bold)
            .foregroundStyle(LinearGradient(
                colors: [color1, color2, color3],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            )
    }
    
    var displayHours: some View {
        if timecard.timecardEvents.isEmpty == true {
            Text("You have not clocked in today.")
                .font(.title2)
                .fontWeight(.semibold)
        } else if timecard.isClockedIn() != true {
            Text("You worked \(timecard.getShiftLength()) today. \n\nYou have been clocked out for \(timecard.getTimeClockedOut()).")
                .font(.title2)
                .fontWeight(.semibold)
        } else {
            Text("You have been working for \(timecard.getShiftLength()).")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
    
    var displayClockInOutButtons: some View {
        if timecard.isClockedIn() == true {
            Button(action: {
                if timecard.clockOut(deptModel: departmentModel) {
                    
                } else {
                    showClockOutError = true
                }
                
            }) {
                Text("Clock Out")
                    .fontWeight(.bold)
                    .font(.title) // Adjust font size, e.g., .title, .largeTitle, or .system(size: 24)
                    .foregroundColor(.white)
                
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red)
                    .scaleEffect(1.7)
            )
        } else {
            Button(action: {
                if timecard.clockIn(deptModel: departmentModel) {
                    
                } else {
                    showClockInError = true
                }
            }) {
                Text("Clock In")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.white)
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue)
                    .scaleEffect(1.7)
            )
        }
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 5)
                displayHours
                    .padding(.all)
                Spacer(minLength: 20)
                displayClockInOutButtons
                    
                    //.padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        self.showSheet = false
                    }
                    .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    titleText
                }
                
            }
            .alert(Text("Error"), isPresented: $showClockInError) {} message: {
                Text("There was an error clocking in. Please try again.")
            }
            .alert(Text("Error"), isPresented: $showClockOutError) {} message: {
                Text("There was an error clocking out. Please try again.")
            }
        }
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: opacity
        )
    }
}

#Preview {
    //EmployeeTimecardView()
}
