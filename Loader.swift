//
//  Loader.swift
//  Prayer Pulse
//
//  Created by mac on 14/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import SVProgressHUD

class Loader {
    static func showLoader() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //changes hud's bg color
//        SVProgressHUD.setBackgroundColor(UIColor.blue)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.show()
    }
    
    static func hideLoader() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
    }
}
