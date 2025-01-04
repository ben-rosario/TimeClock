//  EmployeeTimecard.swift
//  CCGTime
//
//  Created by ben on 7/17/22.
//
//  Each employee should have their own EmployeeTimecard struct
//  for each day they work.

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EmployeeTimecard: Codable, Hashable {
    
    
    @DocumentID var id: String?
    var employee: Employee
    var timecardEvents: [Date]
    var exists: Bool
    var shiftLength: Double = 0.0
    // This var will only be false if the employee has not clocked in even once
    var hasClockedIn: Bool
    
    init(id: String, emp: Employee) {
        self.id = id
        self.employee = emp
        self.exists = true
        self.timecardEvents = []
        self.hasClockedIn = false
    }
    
    /* Required code to make the EmployeeTimecard struct Codable and Hashable */
    
    private enum CodingKeys: String, CodingKey {
        case employee
        case timecardEvents
        case exists
        case shiftLength
        case hasClockedIn
    }
    
    public func numOfEvents() -> Int {
        let events: Int = self.timecardEvents.count
        return events
    }
    
    public func isClockedIn() -> Bool {
        if self.timecardEvents.isEmpty {
            return false
        } else {
            return (timecardEvents.count % 2 == 1)
        }
    }
    
    public mutating func clockIn(deptModel: DepartmentModel) -> Bool {
        self.timecardEvents.append(Date())
        if deptModel.addTimecard(timecard: self, date: Date()) {
            if hasClockedIn == false {
                self.hasClockedIn = true
            }
            return true
        } else {
            print("Error: Failed to upload updated timecard to Firestore")
            return false
        }
        
    }
    
    public mutating func clockOut(deptModel: DepartmentModel) -> Bool {
        let timeClockedIn = self.timecardEvents.last!
        
        self.timecardEvents.append(Date())
        let timeClockedOut = self.timecardEvents.last!
        
        let shiftTimeInSeconds: Double = timeClockedOut - timeClockedIn
        let shiftTimeInMinutes: Double = shiftTimeInSeconds / 60
        let shiftTimeInHours: Double = shiftTimeInMinutes / 60
        
        self.shiftLength += shiftTimeInHours
        
        if deptModel.addTimecard(timecard: self, date: Date()) {
            return true
        } else {
            print("Error: Failed to upload updated timecard to Firestore")
            return false
        }
    }
    
    public func getTimeClockedOut() -> String {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.hour, .minute]
        dcf.unitsStyle = .full
        
        let timeDiff = dcf.string(from: self.timecardEvents.last!, to: Date())!
        return timeDiff
    }
    
    public func getShiftLength() -> String {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.hour, .minute]
        dcf.unitsStyle = .full
        
        let currentShiftLength = Date() - self.timecardEvents.last!
        
        let oldShiftLengthInHours = TimeInterval(self.shiftLength)
        let oldShiftLengthInMinutes = oldShiftLengthInHours * 60
        let oldShiftLengthInSeconds = oldShiftLengthInMinutes * 60
        
        let updatedShiftLength = currentShiftLength + oldShiftLengthInSeconds
        
        return dcf.string(from: updatedShiftLength)!
    }
}
