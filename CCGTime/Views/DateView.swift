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
    @State private var showTimecardManagementSheet: Bool = false
    @State private var currentTimecard: EmployeeTimecard?
    
    init(dept: String, date: String) {
        self.dept = dept
        self.date = date
    }
    
    var body: some View {
        
        VStack {
            List {
                ForEach(timecardArray, id: \.self) { timecard in
                    Button(action: {
                        employeeModel.selectTimecard(timecard)
                        self.showTimecardManagementSheet = true
                    }) {
                        Text("\(timecard.employee.name) (\(timecard.employee.employeeId))")
                            .fontWeight(.bold)
                            .font(.headline) // Adjust font size, e.g., .title, .largeTitle, or .system(size: 24)
                            .padding(.all)
                        
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("\(departmentModel.simpleDate(date)) Timecards")
        .sheet(isPresented: $showTimecardManagementSheet) {
            TimecardManagementView(showSheet: $showTimecardManagementSheet, employeeModel.getSelectedTimecard()!)
                .presentationDetents(.init([.large]))
                .presentationDragIndicator(.visible)
        }
        .onAppear(perform: {
            Task {
                await self.timecardArray = departmentModel.getTimecards(dept: dept, date: date)
            }
        })
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(dept: "Alphabet", date: "03052024")
    }
}
