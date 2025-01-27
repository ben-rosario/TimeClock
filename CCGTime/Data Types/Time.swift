//
//  Time.swift
//  CCGTime
//
//  Created by Ben on 10/17/24.
//
//  Time class to be used for displaying time in different formats

import Foundation


class Time {
    
    class func fancyTime() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        let formattedTime = dateFormatter.string(from: date)
        
        return formattedTime
    }
    
    class func dateView(_ originalDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a',' zzz"
        let modifiedDate = dateFormatter.string(from: originalDate)
        
        return modifiedDate
    }
    
    /**
     Given two date objects, find the length of time that passed between the two times.
     First parameter should be the earliest date, and the second parameter should be the later one
     */
    class func distanceBetween(first: Date, last: Date) -> String {
        let delta = first.distance(to: last)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.hour, .minute]
        
        return formatter.string(from: delta)!
    }
    
}
