//
//  Utilities.swift
//  ChaChat
//
//  Created by Ryan Lim on 8/31/16.
//  Copyright © 2016 Ryan Lim. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    func showAlert(title: String, message:String, vc: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func getDate() -> String{
        let today: Date = Date()
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM--dd-yyyy HH:mm"
        return formatter.string(from:today)
    }
}
