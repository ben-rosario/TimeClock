//
//  DepartmentModel.swift
//  CCGTime
//
//  Created by Ben Rosario on 10/14/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import OrderedCollections

@MainActor class DepartmentModel: ObservableObject {
    
    private var uid: String
    private var db: Firestore
    
    var departments = [Department]()
    var departmentArray = [Department]()
    var allEmployees = [String:Employee]()
    var earliestDate: Date?
    
    @Published var deptStrings = [String]()
    @Published var archiveStrings = [String]()
    @Published var reportLoading: Bool = false
    @Published var report: Report?
    
    init(with givenUid: String) async {
        db = Firestore.firestore()
        self.uid = givenUid
        await self.loadData()
    }
    
    private func loadData() async {
        // Add listener for departments collection
        db.collection("users").document(uid).collection("departments").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            self.departments = []
            self.deptStrings = []
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let dept = Department(name: document.documentID)
                self.departments.append(dept)
                self.deptStrings.append(dept.name)
            }
        }
        
        // Add listener for archive collection
        db.collection("users").document(uid).collection("archive").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            self.departmentArray = []
            self.archiveStrings = []
            
            // there are querySnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let dept = Department(name: document.documentID)
                self.departmentArray.append(dept)
                self.archiveStrings.append(dept.name)
            }
        }
        
        
        do {
            let employees = try await db.collection("users").document(uid).collection("employees").getDocuments()
            
            
            for employee in employees.documents {
                let firstName = employee.get("firstName") as! String
                let lastName = employee.get("lastName") as! String
                let wage = employee.get("wage") as! Double
                let department = employee.get("department") as! String
                let id = employee.documentID
                
                let newEmployee = Employee(firstName: firstName, lastName: lastName, wage: wage, department: department, employeeId: id)
                
                self.allEmployees[id] = newEmployee
            }
            
        } catch (let error){
            print("Error Creating DepartmentModel allEmployees Array: \(error)")
        }
    }
    
    public func getReportProgress() ->  Double {
        if let r = self.report {
            return r.progress
        } else {
            return 0.0
        }
    }
    
    public func simpleDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        let simpleDateString: String = dateFormatter.string(from: newDate)
        
        return simpleDateString
    }
    
    public func fancyDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let newDate: Date = dateFormatter.date(from: date) ?? Date.distantPast
        
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let fancyDateString: String = dateFormatter.string(from: newDate)
        
        return fancyDateString
    }
    
    public func archiveDepartment(_ name: String) {
        
        print("Archiving Department: \(name)")
        
        // Add 'deleted' field for sorting purposes
        self.db.collection("users")
            .document(uid)
               .collection("departments")
               .document(name)
               .updateData(["deleted" : FirebaseFirestore.Timestamp.init()])
        
        let deptRef = self.db.collection("users").document(uid).collection("departments").document(name)
        let archiveRef = self.db.collection("users").document(uid).collection("archive").document(name)

        deptRef.getDocument() { document, err in
            if err != nil { return }
            
            archiveRef.setData(document?.data() ?? ["Document was nil" : ""])
            
        }
        
        let datesRef = deptRef.collection("dates")
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach({ (document) in
                let data = document.data()
                let docID = document.documentID
                archiveRef.collection("users").document(self.uid).collection("dates").document(docID).setData(data)
            })
        }
        deptRef.delete()
    }
    
    public func unarchiveDepartment(_ name: String) {
        //TODO: Create function
        print("Unarchiving department: \(name)")
    }
    
    public func deleteDepartment(_ name: String) {
        
        let archiveRef = self.db.collection("users").document(uid).collection("archive")
        let docRef = archiveRef.document(name)
        
        /*
            TODO: Delete subcollections from Firestore via
            server or cloud function - doing so from a mobile
            client has negative security and performance implications
         */
        
        docRef.delete()
        //     ^ DOES NOT delete subcollections
        
    }
    
    public func createDepartment(_ departmentName: String) {
        // Get reference to the database
        let db = Firestore.firestore()
        
        // Add document to collection
        db.collection("users").document(uid).collection("departments")
            .document(departmentName)
        
        // Add 'created' field for sorting purposes
        db.collection("users").document(uid).collection("departments")
            .document(departmentName)
            .setData(["created" : FirebaseFirestore.Timestamp.init()])
    }
    
    public func getDates(dept department: String, completion: @escaping (_ dates: [String]) -> Void) {
        
        var dates:[String] = []
        let datesRef = db.collection("users").document(uid).collection("departments")
                         .document(department)
                         .collection("dates")
        
        datesRef.getDocuments() { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err.localizedDescription)")
                return
            }

            guard let snapshot = snapshot else { return }

            snapshot.documents.forEach({ (document) in
                let docID = document.documentID
                dates.append(docID)
            })
            completion(dates)
        }
    }
    
    public func getTimes(dept department: String, date: String, completion: @escaping (_ timecard: [EmployeeTimecard]) -> Void) {

        var timecards: [EmployeeTimecard] = []
        let docRef = db.collection("users").document(uid).collection("departments")
                       .document(department)
                       .collection("dates")
                       .document(date)
                       .collection("times")

        docRef.getDocuments() { snapshot, error in
            guard error == nil else {
                print("Error adding the snapshot listener:  \(error!.localizedDescription)")
                return
            }
            
            snapshot!.documents.forEach({ document in
                do {
                    let decodedTimecard = try document.data(as: EmployeeTimecard.self)
                    timecards.append(decodedTimecard)
                }
                catch {
                  print("Error trying to decode Timecard: \(error)")
                }
            })
            completion(timecards)
        }
    }
    
    // Gets the earliest recorded clock-in date in YYYYMMDD and returns a Date object with the same timestamp.
    // Used in the GenerateReportView sheet
    public func getEarliestDate() {
        
        var earliestInt: Int32 = Int32.max
        var deptsChecked = 0
        
        let departments = db.collection("users").document(uid).collection("departments")
        
        for dept in self.deptStrings {
            
            
            
            let selectedDept = departments.document(dept).collection("dates")
            
            selectedDept.getDocuments { snapshot, error in
                guard error == nil else {
                    print("Error adding the snapshot listener \(error!.localizedDescription)")
                    return
                }
                
                snapshot!.documents.forEach { item in
                    let newInt = Int32(item.documentID)!
                    
                    if newInt < earliestInt {
                        earliestInt = newInt
                        print("Earliest found date: \(earliestInt)")
                    }
                }
                
                deptsChecked += 1
                
                if deptsChecked == self.deptStrings.count {
                    let earliestDate = self.dateFromInt32(earliestInt)!
                    self.earliestDate = earliestDate
                }
            }
                
            }
    }
    
    // Overloads the getEarliestDate function to find the earliest date of a specific department
    // Also returns a date object set to that specific date
    public func getEarliestDate(for dept: String) -> Date {
        
        var earliestInt: Int32 = Int32.max
        
        let deptDates = db.collection("users")
                          .document(uid)
                          .collection("departments")
                          .document(dept)
                          .collection("dates")
            
        deptDates.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error adding the snapshot listener \(error!.localizedDescription)")
                return
            }
            
            snapshot!.documents.forEach { item in
                let newInt = Int32(item.documentID)!
                
                if newInt < earliestInt {
                    earliestInt = newInt
                }
            }
        }
        return self.dateFromInt32(earliestInt)!
    }
    
    // Converts Int32 in "YYYYMMDD" format to a Date object with the same timestamp
    public func dateFromInt32(_ dateInt: Int32) -> Date? {
        let intString = String(dateInt) // Convert Int32 to String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // Match the format
        return dateFormatter.date(from: intString)
    }

    // Converts Date Object to an Int32 in the "YYYYMMDD" format
    public func int32FromDate(_ date: Date) -> Int32 {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        
        return Int32(year * 10000 + month * 100 + day)
    }
    
    public func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" 
        return dateFormatter.string(from: date)
    }
    
    // Returns an array of type Employee for any employee that has worked from the date given
    // until the next sunday (range is only 1 day if the date provided is sunday)
    public func getEmployeesWorkedForWeek(week startingDate: Date, for dept: String) async -> [Employee] {
        
        // dayOfWeek returns 1 for a monday and 7 for a sunday
        var dayOfWeek: Int = startingDate.dayNumberOfWeek()!
        let range = dayOfWeek...7
        
        var employeesWorkedThisWeek: [[Employee]] = []
        var date = startingDate
        
        for _ in range {
            
            let employeesWorked = await self.getEmployeesWorkedForDay(day: date, for: dept)
            employeesWorkedThisWeek.append(employeesWorked)
            
            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                date = newDate
                dayOfWeek += 1
            }
        }
        
        if employeesWorkedThisWeek.isEmpty { return []}
        
        // Remove duplicates
        var employeesWorked: [Employee] = []
        
        for employeeList in employeesWorkedThisWeek {
            for employee in employeeList {
                if !employeesWorked.contains(employee) {
                    employeesWorked.append(employee)
                }
            }
        }
        return employeesWorked
    }
    
    // Returns an array with the Employee IDs who worked on the given date
    public func getEmployeesWorkedForDay(day startingDate: Date, for dept: String) async -> [Employee] {
        let employeesRef = db.collection("users")
                         .document(uid)
                         .collection("departments")
                         .document(dept)
                         .collection("dates")
                         .document(self.stringFromDate(startingDate))
                         .collection("times")
        
        var empStrings: [String] = []
        var employees: [Employee] = []
        
        do {
            let querySnapshot = try await employeesRef.getDocuments()
            for tc in querySnapshot.documents {
                let timecard = tc.data()
                let empData: [String:Any] = timecard["employee"] as! [String : Any]
                
                let newEmployee = Employee(firstName: empData["firstName"] as! String,
                                           lastName: empData["lastName"] as! String,
                                           wage: empData["wage"] as! Double,
                                           department: empData["department"] as! String,
                                           employeeId: empData["employeeId"] as! String
                                          )
                
                if !empStrings.contains(newEmployee.employeeId) {
                    employees.append(newEmployee)
                    empStrings.append(newEmployee.employeeId)
                }
            }
        } catch {
          print("Error getting documents: \(error)")
        }
        
        return employees
    }
    
    public func createReport(start startDate: Date, end endDate: Date, for dept: String, name: String) async -> Void {
        self.report = await Report(start: startDate, end: endDate, for: dept, name: name, deptModel: self)
    }
    
    public func reportIsCompleted() -> Bool {
        if let r = report {
            return r.completed
        } else {
            return false
        }
    }
    
    public func reportIsInitialized() -> Bool {
        if let _ = report {
            return true
        } else {
            return false
        }
    }
    
    public func getName(_ id: String) -> String {
        let employee = allEmployees[id]
        if employee == nil {
            return "No Name Assigned to #\(id)"
        }
        
        let firstName: String = employee!.firstName
        let lastName: String = employee!.lastName
        
        return "\(firstName) \(lastName)"
    }
    
    public func getEmployee(_ id: String) -> Employee? {
        return allEmployees[id]
    }
    
    // Returns the hours worked on the current day in hours, as a Double
    public func hoursWorked(for emp: Employee, on date: Date) async -> Double {
        let dateString = String(self.int32FromDate(date))
        
        do {
            let dateRef = db.collection("users")
                            .document(uid)
                            .collection("departments")
                            .document(emp.department)
                            .collection("dates")
                            .document(dateString)
                            .collection("times")
            
            let dateDocument = try await dateRef.document(emp.employeeId).getDocument()
            let timecard = try dateDocument.data(as: EmployeeTimecard.self)
            
            return timecard.getShiftLength()
        } catch {
            return 0.0
        }
    }
    
    public func hasCorrectInfo(empId id: String, dept givenDept: String) -> Bool {
        // First check if any employee has this ID
        if let e = self.allEmployees[id] {
            // If so, check that the Employee is also assigned to the given department
            if e.department == givenDept {
                return true
            }
        }
        return false
    }
    
    @Published var currentTimecard: EmployeeTimecard?
    public func getTimecard(emp: Employee, dateStr: String) async {
        let timecardsRef = db.collection("users")
                        .document(uid)
                        .collection("departments")
                        .document(emp.department)
                        .collection("dates")
                        .document(dateStr)
                        .collection("times")
                        
        let timecardRef = timecardsRef.document(emp.employeeId)
        
        do {
            let timecard = try await timecardRef.getDocument(as: EmployeeTimecard.self)
            self.currentTimecard = timecard
        } catch {
            // Timecard doesn't exist, creating one now
            let newTimecard = EmployeeTimecard(id: emp.employeeId, emp: emp)
            
            // Writing new timecard to Firestore
            let _ = self.addTimecard(timecard: newTimecard, date: Date())
        }
    }
    
    // Returns true if timecard was added, and false if there was an error.
    // Creates/Overwrites the timecard on Firestore
    func addTimecard(timecard tc: EmployeeTimecard, date: Date) -> Bool{
        let dateStr = self.stringFromDate(date)
        
        let datesRef = db.collection("users")
                        .document(uid)
                        .collection("departments")
                        .document(tc.employee.department)
                        .collection("dates")
                        .document(dateStr)
                        
        datesRef.setData(["visible":true])
        
        let timecardsRef = datesRef.collection("times")
        
        do {
            try timecardsRef.document(tc.employee.employeeId).setData(from: tc)
            self.currentTimecard = tc
            return true
        } catch (let error){
            print("Error adding new timecard to Firestore: \(error)")
            return false
        }
    }
}
