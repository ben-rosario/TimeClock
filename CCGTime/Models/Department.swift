//
//  Department.swift
//  CCGTime
//
//  Created by ben on 11/26/24.
//

import Foundation

class Department: Identifiable {
    
    let id: UUID
    @Published var name: String
    
    init(name: String) {
        self.name = name
        self.id = UUID()
    }
}
