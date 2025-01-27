//
//  Alert.swift
//  CCGTime
//
//  Created by ben on 10/17/24.
//

import Foundation
import SwiftUI

class Alert {
    
    class func error(_ message: String) {
        let alertVC = UIAlertController(title: "Error!",
                                        message: message,
                                        preferredStyle: .alert)
        
        let acknowledgeAction = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(acknowledgeAction)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
    
    class func message(_ header: String, _ message: String) {
        let alertVC = UIAlertController(title: header,
                                        message: message,
                                        preferredStyle: .alert)
        
        let acknowledgeAction = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(acknowledgeAction)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
    
    class func newDept(departmentModel: DepartmentModel) {
        var newDept : String = ""
        
        let alertVC = UIAlertController(title: "Create New Department",
                                        message: "Enter new department name",
                                        preferredStyle: .alert)
        
        alertVC.addTextField { newDept in newDept.placeholder = "New Department" }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let submitAction = UIAlertAction(title: "Create", style: .default) { (action: UIAlertAction) in
            newDept = alertVC.textFields![0].text!
            
            departmentModel.createDepartment(newDept)
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
            
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
    
    class func promptForString(header: String, message: String, placeholderText: String, isSecureText: Bool, completion: @escaping (String) -> Void) {
        
        let alertVC = UIAlertController(title: header,
                                        message: message,
                                        preferredStyle: .alert)
        
        alertVC.addTextField { result in
            result.placeholder = placeholderText
            result.isSecureTextEntry = isSecureText
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            completion ("")
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default){ (action: UIAlertAction) in
            if let text = alertVC.textFields?[0].text {
                completion(text)
            } else {
                completion("")
            }
            
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(submitAction)
            
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first?.rootViewController
        window?.present(alertVC, animated: true)
    }
}
