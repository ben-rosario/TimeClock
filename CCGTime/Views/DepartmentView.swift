//
//  DepartmentView.swift
//  CCGTime
//
//  Created by ben on 7/16/22.
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
                ForEach(dateArray, id: \.self) { item in
                    NavigationLink(destination: DateView(dept: dept, date: item)) {
                        Text(departmentModel.fancyDate(item))
                    }
                }
            }
        }
        .navigationTitle(dept)
    }
}



/*
 
 struct DepartmentView_Previews: PreviewProvider {
     static var previews: some View {
         DepartmentView(session: SessionStore(), dept: "MargaritaVille")
     }
 }
 
 */
