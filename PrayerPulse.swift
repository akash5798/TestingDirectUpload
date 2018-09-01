//
//  PrayerPulse.swift
//  Prayer Pulse
//
//  Created by mac on 18/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class PrayerPulse: NSObject {
    
    static let sharedInstance = PrayerPulse()
    var currentUser: User?
    
    
    func getFullUserName() -> String {
        let namesArray = [currentUser?.firstName, currentUser?.lastName]
        return namesArray.isEmpty ? "empty" : namesArray.compactMap({ $0 }).joined(separator: " ")
        /*if let fname = currentUser?.firstName, let lname = currentUser?.lastName {
            return fname + " " + lname
        }else {
            return "empty"
        }*/
    }
}
