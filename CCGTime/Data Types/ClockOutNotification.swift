//
//  ClockOutNotification.swift
//  CCGTime
//
//  Created by ben on 1/24/25.
//

import Foundation
import FirebaseFirestore

struct ClockOutNotification: Codable, Hashable {
    
    /*
     date: employeeTimecard.date,
         employee: employee,
         created: admin.firestore.Timestamp.now(),
         timecardRef: employeeTimecardDoc.ref.path,
         timecardIndex: employeeTimecard.timecardEvents.length - 1,
         isRead: false,
     */
    
    // Timestamp of creation, for sorting
    var created: FirebaseFirestore.Timestamp
    
    // Timestamp from the EmployeeTimecard Type
    var date: FirebaseFirestore.Timestamp
    
    var employee: Employee
    
    // String pointing to the timecard's location in the database, from root
    var timecardRef: String
    
    // Int pointing to the array index that the notification was generated for
    var timecardIndex: Int
    
    var isRead: Bool
    
    enum CodingKeys: CodingKey {
        case created
        case date
        case employee
        case timecardRef
        case timecardIndex
        case isRead
    }
}
