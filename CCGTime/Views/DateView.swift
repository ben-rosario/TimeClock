//
//  DateView.swift
//  CCGTime
//
//  Created by ben on 10/30/24.
//

import SwiftUI
import OrderedCollections

struct DateView: View {
    
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var departmentModel: DepartmentModel
    @EnvironmentObject var employeeModel: EmployeeModel
    
    private var dept: String
    private var date: String
    
    @State private var timecardArray: [EmployeeTimecard] = []
    @State private var empName: String = ""
    
    init(dept: String, date: String) {
        self.dept = dept
        self.date = date
    }
    
    var body: some View {
        
        departmentModel.getTimes(dept: dept, date: date) { tcArray in
            self.timecardArray = tcArray
            print("\(tcArray)")
        }
        
        return VStack {
            List {
                ForEach(timecardArray, id: \.self) { timecard in
                    Section("\(timecard.employee.name) - \(timecard.employee.employeeId)") {
                        
                        ForEach(0..<timecard.numOfEvents(), id: \.self) { index in
                            // For both of the scenarios I use the Time.dateView function
                            // to present the dates in the most readable format for users
                            if (index % 2 == 0) {
                                Text("**Clocked In |** \(Time.dateView(timecard.timecardEvents[index]))")
                            } else {
                                Text("**Clocked Out |** \(Time.dateView(timecard.timecardEvents[index]))")
                                Text("**Total Shift Length: \(Time.distanceBetween(first: timecard.timecardEvents[index - 1], last: timecard.timecardEvents[index]))**")
                                    .padding(.bottom)
                            }
                            
                        }
                    }
                    .headerProminence(.increased)
                }
            }
        }
        .navigationTitle("\(departmentModel.simpleDate(date))")
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(dept: "Alphabet", date: "03052024")
    }
}
