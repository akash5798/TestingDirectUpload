//
//  User.swift
//  Prayer Pulse
//
//  Created by mac on 16/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyUserDefaults

let kUserId = "userId"
let kFirstName = "firstName"
let kLastName = "lastName"
let kEmail = "email"
let kPassword = "password"
//let kChurch = "church"
let kProfileImage = "profileImage"
let kDeviceToken = "deviceToken"
let kDeviceType = "deviceType"
let kQuickBloxId = "quickBloxId"

class User {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let profileImage: String
    
    let latitude: Double
    let longitude: Double
    
//    init?(id: Int, firstName: String, lastName: String, email: String, profileImage: String) {
//        self.id = id
//        self.firstName = firstName
//        self.lastName = lastName
//        self.email = email
//        self.profileImage = profileImage
//    }
    
    init?(dictionary: [String:Any]) {
        guard let id = dictionary[kUserId] as? Int else {
            return nil
        }
        
//        Defaults[.userDictionary] = dictionary
        //"userDictionary"
//        UserDefaults.setUserDictionary(dictionary)
        
        
        self.id = id
        self.firstName = dictionary[kFirstName] as? String ?? ""
        self.lastName = dictionary[kLastName] as? String ?? ""
        self.email = dictionary[kEmail] as? String ?? ""
        self.profileImage = dictionary[kProfileImage] as? String ?? ""
        
        self.latitude = dictionary[kLatitude] as? Double ?? 0.00
        self.longitude = dictionary[kLongitude] as? Double ?? 0.00
    }
    
    
    // MARK:  Check if user exist
    class func checkIfUserExist(withEmail email: String, success withResponse: @escaping (Bool) -> (), failure: @escaping (_ error: String) -> Void) {
        let param: [String: Any] = [
            kEmail: email
        ]
        
        ApiService.makeRequest(with: baseURL.checkExistingUser, method: .post, parameter: param, success: { (response) in
            
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[kResult] as? Bool ?? false
            
            // if success true -> Email does not exist -> return false -> user can register successfully
            // if success false -> Email already registered -> return true -> registration failed
            if isSuccess {
                withResponse(false)
            }else {
                withResponse(true)
            }
            
        }, failure: { (error) in
            failure(error)
        }) { (connectionError) in
            failure(connectionError)
        }
    }
    
    
    // MARK:  register user
    class func registerUserWith(FirstName fn: String, LastName ln: String, Email email: String, Password pass: String, success withResponse: @escaping (_ boolResult: Bool,_ message: String) -> (), failure: @escaping (_ error: String) -> Void) {
        let param: [String: Any] = [
            kFirstName: fn,
            kLastName: ln,
            kEmail: email,
            kPassword: pass,
            kProfileImage: "",
            kDeviceToken: "",
            kDeviceType: "1"
        ]
        
        ApiService.makeRequest(with: baseURL.registrationURL, method: .post, parameter: param, success: { (response) in
            print("registraion result \(response)")
            
            
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[kResult] as? Bool ?? false
            let message = dict[kMessage] as? String ?? ""

            if isSuccess {
                let data = dict[kData] as? [String:Any] ?? [:]
//                print("print registraion Data \(data)")
                let array = User(dictionary: data)
                
                //                set userdefaults and assign to class
                UserDefaults.setUserDictionary(data)
                UserDefaults.setUserLoggedIn()
                if let asdf = UserDefaults.getUserDictionary(), let user = User(dictionary: asdf) {
//                    print("asdfasdf: \(asdf)")
//                    print("user \(user.id)")
                    PrayerPulse.sharedInstance.currentUser = user
                }
                
                withResponse(isSuccess, message)
            }else{
                withResponse(isSuccess, message)
            }
            
            
        }, failure: { (error) in
            failure(error)
        }) { (connectionError) in
            failure(connectionError)
        }
    }
    
    
    
    // MARK:  Sign In Func
    class func logInUserWith(Email email: String, Password pass: String, success withResponse: @escaping (User?) -> (), failure: @escaping (_ error: String) -> Void) {
        let param: [String: Any] = [
            kEmail: email,
            kPassword: pass,
            kDeviceToken: "21231",
            kDeviceType: 1
        ]
        
        ApiService.makeRequest(with: baseURL.logIn, method: .post, parameter: param, success: { (response) in
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[kResult] as? Bool ?? false
            let message = dict[kMessage] as? String ?? ""
            
            if isSuccess {
                let data = dict[kData] as? [String:Any] ?? [:]
                print("print registraion Data \(data)")
                let array = User(dictionary: data)
                
//                set userdefaults and assign to class
                UserDefaults.setUserDictionary(data)
                if let asdf = UserDefaults.getUserDictionary(), let user = User(dictionary: asdf) {
                    print("asdfasdf: \(asdf)")
                    print("user \(user.id)")
                    PrayerPulse.sharedInstance.currentUser = user
                }
                UserDefaults.setUserLoggedIn()
                withResponse(array)
                
            }else{
                failure(message)
            }
            
        }, failure: { (error) in
            failure(error)
        }) { (connectionError) in
            failure(connectionError)
        }
    }
    
    
    // MARK:  Update Profile Func
    class func updateProfile(FirstName fname: String, LastName lname: String, ProfileImage imgProfile: UIImage?, success withResponse: @escaping (User?, _ message: String) -> (), failure: @escaping (_ error: String) -> Void) {
        let param: [String: Any] = [
            kUserId: String(PrayerPulse.sharedInstance.currentUser?.id ?? 0),
            kFirstName: fname,
            kLastName: lname
        ]
        
        ApiService.callAPIMultipartFormData(baseURL.updateProfile, imgProfile, withRequest: param, withSuccess: { (testt) in
            let dict = testt as? [String:Any] ?? [:]
            let isSuccess = dict[kResult] as? Bool ?? false
            let message = dict[kMessage] as? String ?? ""
            
            if isSuccess {
                let data = dict[kData] as? [String:Any] ?? [:]
                print("print update user Data \(data)")
                let array = User(dictionary: data)
                
                //                set userdefaults and assign to class
                UserDefaults.setUserDictionary(data)
                if let asdf = UserDefaults.getUserDictionary(), let user = User(dictionary: asdf) {
                    PrayerPulse.sharedInstance.currentUser = user
                }
                UserDefaults.setUserLoggedIn()
                withResponse(array, message)
                
            }else{
                failure(message)
            }
            
            
        }, failure: { (failureString) in
            
            failure(failureString)
        }) { (connError) in
            failure(connError)
        }
    }
    
    // MARK:  Sign OUT Func
    class func logOutUserWith(UserID uId: Int, success withResponse: @escaping (_ boolResult: Bool, _ msg: String) -> (), failure: @escaping (_ error: String) -> Void) {
//        let param: [String: Any] = [
//            kEmail: email,
//            kPassword: pass,
//            kDeviceToken: "21231",
//            kDeviceType: 1
//        ]
        
        ApiService.makeRequest(with: baseURL.logOut, method: .post, parameter: [:], success: { (response) in
            let dict = response as? [String:Any] ?? [:]
            let isSuccess = dict[kResult] as? Bool ?? false
            let message = dict[kMessage] as? String ?? ""
            
            if isSuccess {
                let data = dict[kData] as? [String:Any] ?? [:]
                let message = dict[kMessage] as? String ?? ""
//                let result = dict[kResult] as? Bool ?? false
                print("logout response Data \(data)")
                
                UserDefaults.setUserLoggedOut()
                withResponse(isSuccess, message)
                
            }else{
                failure(message)
            }
            
        }, failure: { (error) in
            failure(error)
        }) { (connectionError) in
            failure(connectionError)
        }
    }
    
    
    
}
