//
//  DepartmentView.swift
//  CCGTime
//
//  Created by ben on 10/16/22.
//

import SwiftUI

struct DepartmentView: View {
    
    @EnvironmentObject private var departmentModel: DepartmentModel
    @EnvironmentObject private var session: SessionStore
    
    @State private var dateArray: [String] = []
    private let dept: String
    
    init(dept: String) {
        self.dept = dept
    }
    
    var body: some View {
        
        let _ = departmentModel.getDates(dept: dept) { dates in
            self.dateArray = dates
        }
        
        return VStack(alignment: .center) {
            
            List {
                timecardDates
            }
        }
        .navigationTitle(dept)
    }
    
    var timecardDates: some View {
        Section("Timecard Dates") {
            if !dateArray.isEmpty {
                ForEach(dateArray, id: \.self) { item in
                    NavigationLink(destination: DateView(dept: dept, date: item)) {
                        Text(departmentModel.fancyDate(item))
                    }
                }
            } else {
                Text("No timecards found")
            }
        }
    }
}
