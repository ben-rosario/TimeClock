//
//  UserDocument.swift
//  CCGTime
//
//  Created by ben on 1/24/25.
//

import Foundation
import FirebaseFirestore

struct UserDocument: Codable, Hashable {
    var timezone: String
    var registered: FirebaseFirestore.Timestamp
    
    private enum CodingKeys: String, CodingKey {
        case timezone
        case registered
    }
}
