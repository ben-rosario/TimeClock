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
        
        do {
            let employees = try await db.collection("users").document(uid).collection("employees").getDocuments()
            
            for employee in employees.documents {
                let id = employee.documentID
                let firstName = employee.get("firstName") as! String
                let lastName = employee.get("lastName") as! String
                let wage = employee.get("wage") as! Double
                let department = employee.get("department") as! String
                
                let fullName = "\(firstName) \(lastName)"
                self.employeeNameStrings.append(fullName)
                
                self.employeeIdStrings.append(id)
                
                self.employees[id] = Employee(firstName: firstName, lastName: lastName,  wage: wage, department: department, employeeId: id)
            }
            
        } catch (let error) {
            print("Error adding EmployeeModel snapshot listener: \(error.localizedDescription)")
        }
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
    func createNewEmployee(firstName: String, lastName: String, id: NumbersOnly, wage: FloatsOnly, department: String) -> Employee {
        
        let docRef = db.collection("users")
            .document(uid)
            .collection("employees")
            .document(id.value)
        
        do {
            let employee = Employee(
                firstName: firstName,
                lastName: lastName,
                wage: Double(wage.value) ?? 0.0,
                department: department,
                employeeId: id.value
            )
            
            try docRef.setData(from: employee)
            return employee
        }
        catch {
            print("Error when trying to encode Employee: \(error)")
            return Employee(firstName: "", lastName: "", wage: 0, department: "", employeeId: "")
        }
    }
}
