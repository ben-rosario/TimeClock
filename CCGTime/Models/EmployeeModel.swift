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
    
    @Published var employees: [String:Employee] = [:]
    @Published var employeeNameStrings: [String] = []
    @Published var employeeIdStrings: [String] = []
    
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
        
                
        // Add listener for employees collection
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
                
                self.employees = newEmployees
                self.employeeNameStrings = newEmployeeNameStrings
                self.employeeIdStrings = newEmployeeIdStrings
                
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
        let employee = employees[empId]
        let empDept: String = employee!.department
        
        return empDept
    }
    
    func getName(id: String, withId: Bool) -> String {
        var fullName: String = ""
        
        if let employee = employees[id] {
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
}
