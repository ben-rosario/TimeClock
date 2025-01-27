//
//  Employee.swift
//  CCGTime
//
//  Created by ben on 10/17/24.
//

import Foundation
import FirebaseFirestoreSwift

struct Employee: Codable, Hashable {
    
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var name: String
    var wage: Double
    var department: String
    var employeeId: String
    var archived: Bool
    
    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case name
        case wage
        case department
        case employeeId
        case archived
    }
    
    init(firstName: String, lastName: String, wage: Double, department: String, employeeId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.wage = wage
        self.department = department
        self.name = "\(firstName) \(lastName)"
        self.employeeId = employeeId
        self.archived = false
    }
}
