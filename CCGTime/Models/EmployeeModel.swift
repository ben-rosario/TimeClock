//
//  EmployeeModel.swift
//  CCGTime
//
//  Created by ben on 10/16/24.
//

import Foundation
import FirebaseFirestore
import SwiftUICore

@MainActor class EmployeeModel: ObservableObject {
    
    
    // MARK: allEmployees dict is really ALL employees, archived and unarchived.
    @Published var allEmployees = [String:Employee]()
    
    @Published var employeeNameStrings = [String]()
    @Published var employeeIdStrings = [String]()
    
    @Published var archivedEmployeeStrings = [String]()
    
    public var uid: String
    private var db: Firestore
    
    private let staticDate: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    private var lastTimeClocked: Date = Date.init(timeIntervalSince1970: TimeInterval(0))
    private var lastIdClocked: String = ""
    
    init(with givenUid: String) async {
        db = Firestore.firestore()
        self.uid = givenUid
        await self.loadData()
    }
    
    private func loadData() async {
        
        /*                                          */
        /*   Add listener for employee collection   */
        /*                                          */
        db.collection("users").document(uid).collection("employees").addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            
            var newEmployees: [String:Employee] = [:]
            var newEmployeeNameStrings: [String] = []
            var newEmployeeIdStrings: [String] = []
            
            do {
                for document in querySnapshot!.documents {
                    let newEmp = try document.data(as: Employee.self)
                    
                    newEmployees[newEmp.employeeId] = newEmp
                    newEmployeeNameStrings.append(newEmp.name)
                    newEmployeeIdStrings.append(newEmp.employeeId)
                }
                
                self.allEmployees = newEmployees
                self.employeeNameStrings = newEmployeeNameStrings
                self.employeeIdStrings = newEmployeeIdStrings
                
            } catch (let error) {
                print("Error decoding Employee document: \(error)")
            }
        }
        
        
        
        /*                                                   */
        /*   Add listener for archived employee collection   */
        /*                                                   */
        db.collection("users").document(uid).collection("employees").whereField("archived", isEqualTo: true).addSnapshotListener() { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding the snapshot listener: \(error!.localizedDescription)")
                return
            }
            
            var newArchivedEmployeeStrings: [String] = []
            
            do {
                for document in querySnapshot!.documents {
                    let newEmp = try document.data(as: Employee.self)
                    
                    newArchivedEmployeeStrings.append(newEmp.employeeId)
                }
                
                self.archivedEmployeeStrings = newArchivedEmployeeStrings
                
            } catch (let error) {
                print("Error decoding Employee document: \(error)")
            }
        }
    }
    
    private var selectedTimecard: EmployeeTimecard?
    
    public func selectTimecard(_ timecard: EmployeeTimecard) {
        self.selectedTimecard = timecard
    }
    
    public func getSelectedTimecard() -> EmployeeTimecard? {
        return self.selectedTimecard
    }
    
    public func stringFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    func getDept(id: NumbersOnly) -> String {
        let empId = id.value
        let employee = allEmployees[empId]
        let empDept: String = employee!.department
        
        return empDept
    }
    
    func getName(id: String, withId: Bool) -> String {
        var fullName: String = ""
        
        if let employee = allEmployees[id] {
            let firstName: String = employee.firstName
            let lastName: String = employee.lastName
            
            if (withId) { fullName = "\(firstName) \(lastName) (\(id))" }
            else { fullName = "\(firstName) \(lastName)" }
            
        }
        else { fullName = "Employee \(id)" }
        
        return fullName
    }
    
    // TODO: fix error handling in this and AddEmployeeView()
    func createNewEmployee(firstName: String, lastName: String, id: NumbersOnly, wage: FloatsOnly, department: String) {
        
        let empsRef = db.collection("users")
            .document(uid)
            .collection("employees")
        
        do {
            let employee = Employee(
                firstName: firstName,
                lastName: lastName,
                wage: Double(wage.value) ?? 0.0,
                department: department,
                employeeId: id.value
            )
            try empsRef.document(id.value).setData(from: employee)
        }
        catch {
            print("Error when trying to encode Employee: \(error)")
        }
    }
    
    public func archiveEmployee(_ name: String) {
        let dept = db.collection("users")
                     .document(uid)
                     .collection("employees")
                     .document(name)
        
        dept.updateData(["archived": true])
    }
    
    public func unarchiveEmployee(_ name: String) {
        let dept = db.collection("users")
                     .document(uid)
                     .collection("employees")
                     .document(name)
        
        dept.updateData(["archived": false])
    }
}
