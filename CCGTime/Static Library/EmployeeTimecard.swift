//  EmployeeTimecard.swift
//  CCGTime
//
//  Created by ben on 10/17/24.
//
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EmployeeTimecard: Codable, Hashable {
    
    
    @DocumentID var id: String?
    var employee: Employee
    var timecardEvents: [Date]
    var shiftLength: Double = 0.0
    
    init(id: String, emp: Employee) {
        self.id = id
        self.employee = emp
        self.timecardEvents = []
    }
    
    /* Required code to make the EmployeeTimecard struct Codable and Hashable */
    
    private enum CodingKeys: String, CodingKey {
        case employee
        case timecardEvents
        case shiftLength
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
    
    @MainActor public mutating func clockIn(deptModel: DepartmentModel) -> Bool {
        self.timecardEvents.append(Date())
        
        if deptModel.addTimecard(timecard: self, date: Date()) { return true }
        
        else {
            print("Error: Failed to upload updated timecard to Firestore")
            return false
        }
        
    }
    
    @MainActor public mutating func clockOut(deptModel: DepartmentModel) -> Bool {
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
    
    // Returns Double (as hours)
    public func getShiftLength() -> Double {
        // Check if the employee is current clocked out
        if self.timecardEvents.count % 2 == 0 {
            // If the employee is clocked out, just return the shiftLength variable
            // shiftLength should always be update to date if the employee is clocked out
            let time = self.shiftLength
            return time
        }
        
        let currentShiftLength = Date() - self.timecardEvents.last!
        
        let oldShiftLengthInHours = TimeInterval(self.shiftLength)
        let oldShiftLengthInMinutes = oldShiftLengthInHours * 60
        let oldShiftLengthInSeconds = oldShiftLengthInMinutes * 60
        
        let updatedShiftLength = currentShiftLength + oldShiftLengthInSeconds
        
        return updatedShiftLength
    }
    
    // Returns Formatted String
    public func getShiftLengthString() -> String {
        let dcf = DateComponentsFormatter()
        dcf.allowedUnits = [.hour, .minute]
        dcf.unitsStyle = .full
        
        // Check if the employee is currently clocked out
        if self.timecardEvents.count % 2 == 0 {
            // If the employee is clocked out, just return the shiftLength variable
            // shiftLength should always be update to date if the employee is clocked out
            let shiftLengthInHours = TimeInterval(self.shiftLength)
            let shiftLengthInMinutes = shiftLengthInHours * 60
            let shiftLengthInSeconds = shiftLengthInMinutes * 60
            
            // TimeIntervals are measured in seconds, so we need to convert our
            // shiftLength var from hours to seconds
            return dcf.string(from: shiftLengthInSeconds)!
        }
        
        let currentShiftLength = Date() - self.timecardEvents.last!
        
        let oldShiftLengthInHours = TimeInterval(self.shiftLength)
        let oldShiftLengthInMinutes = oldShiftLengthInHours * 60
        let oldShiftLengthInSeconds = oldShiftLengthInMinutes * 60
        
        let updatedShiftLength = currentShiftLength + oldShiftLengthInSeconds
        
        return dcf.string(from: updatedShiftLength)!
    }
}
