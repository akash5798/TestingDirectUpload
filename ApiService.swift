//
//  ApiService.swift
//  Prayer Pulse
//
//  Created by mac on 14/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import SystemConfiguration

var kCommanErrorMessage = "error occured try again later"
var kNoInternetConnectionMessage = "No internet connection try again later"


class ApiService {
    
//    static let sharedInstance = ApiService()
    
    // MARK: - Check for internet connection
    
    /**
     This method is used to check internet connectivity.
     - Returns: Return boolean value to indicate device is connected with internet or not
     */
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    class func makeRequest(with url: String, method: HTTPMethod, parameter: [String:Any]?, success: @escaping (_ response: Any) -> Void, failure: @escaping (_ error: String) -> Void, connectionFailed: @escaping (_ error: String) -> Void) {
        
        if(isConnectedToNetwork()) {
            print(method.rawValue, url)
            if let param = parameter, let data = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) {
                print(String(data: data, encoding: .utf8) ?? "Nil Param")
            }
//            let headers = [kAuthorization : Tuava.sharedInstance.currentUser?.authorizationToken ?? ""]
            Alamofire.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default/*, headers: headers*/).responseJSON { (response) in
                switch (response.result) {
                case .success(let value):
                    if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                        print("Response: \n",String(data: jsonData, encoding: String.Encoding.utf8) ?? "nil")
                    }
                    success(value)
                case .failure(let error):
                    print(error.localizedDescription)
                    failure(/*Constant.ServerAPI.ErrorMessages.*/kCommanErrorMessage)
                }
            }
        }
        else {
            connectionFailed(/*Constant.ServerAPI.ErrorMessages.*/kNoInternetConnectionMessage)
        }
    }
    
    // MARK: Call API to upload Single image with request data
    class func callAPIMultipartFormData(_ URLString: String, _ image : UIImage?, withRequest requestDictionary: [String: Any]?, withSuccess success: @escaping (_ responseDictionary: Any) -> Void, failure: @escaping (_ error: String) -> Void, connectionFailed: @escaping (_ error: String) -> Void){
        
        if(isConnectedToNetwork())
        {
            let url = URL(string:URLString)!
            print(url)
            
            var jsonString = ""
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestDictionary ?? [:], options: JSONSerialization.WritingOptions.prettyPrinted)
                jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                print(jsonString)
            } catch let error as NSError {
                print(error)
            }
//            let headers = [kAuthorization : Tuava.sharedInstance.currentUser?.authorizationToken ?? ""]
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let img = image, let imageData = UIImageJPEGRepresentation(img, 0.6) {
                    multipartFormData.append(imageData, withName: kProfileImage, fileName: "temp.jpg", mimeType: "image/jpg")
                }
                for (key, value) in requestDictionary ?? [:] {
                    guard let value = value as? String, let data = value.data(using: String.Encoding.utf8) else {
                        continue
                    }
                    multipartFormData.append(data, withName: key)
                }
                
            },
                             to: url,
                             //headers: headers,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _ , _ ):
                                    upload.responseJSON { response in
                                        debugPrint(response)
                                        if response.response?.statusCode == 200
                                        {
                                            if let jsonData = try? JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted) {
                                                print("Response: \n",String(data: jsonData, encoding: String.Encoding.utf8) ?? "nil")
                                            }
                                            success(response.result.value! as AnyObject)
                                        }else
                                        {
                                            let res = response.result.value! as AnyObject
                                            let msg = res["Message"] as? String
                                            if msg != nil
                                            {
                                                failure(msg!)
                                            }else
                                            {
                                                failure("")
                                            }
                                        }
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                    failure(encodingError.localizedDescription)
                                }
            })
        }
        else
        {
            connectionFailed(/*Constant.ServerAPI.ErrorMessages.*/kNoInternetConnectionMessage)
        }
    }
    
    
    
    
    
    
    
    
    
//    static func testing() {
//
//        let paramet: Parameters = [
//            "search": "church"
//        ]
//        Alamofire.request(baseURL.searchOrganizationURL, method: HTTPMethod.post, parameters: paramet, encoding: URLEncoding.httpBody).responseJSON { response in
////            if let data = response.data {
////                let json = String(data: data, encoding: String.Encoding.utf8)
////                print(json!)
////            }
//
////            if let value = response.result.value {
////                let json = JSON(value)
////                print(json)
////            }
//
//            switch(response.result) {
//            case .success(let value):
//                let json = JSON(value)
//                print(json)
//            case .failure(let error):
//                let error = error
//                print(error)
//            }
//
//        }
//    }
    
    
    
    deinit {
        print("API SERVICE CLASS DEINITIALIZED..........................")
    }
}
