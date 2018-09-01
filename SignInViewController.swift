//
//  SignInViewController.swift
//  Prayer Pulse
//
//  Created by mac on 03/08/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import QuartzCore
import ActiveLabel

class SignInViewController: UIViewController {
    
    // MARK:  IBOutlets
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var logInBtn: UIButton!
    @IBOutlet weak var containerDontHaveAccount: UIView!
    
    // MARK:  Variables
    var lblRegister = ActiveLabel()
    let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
    
    
    // MARK:  View Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        logInBtn.isEnabled = true
        logInBtn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
        initialConfig()
    }
    
    // MARK:  Initial Config
    fileprivate func initialConfig() {
        
        setCustomNavbar()
        configureRegistrationLabel()
        statusbarBackgroundColor()
    }
    
    fileprivate func statusbarBackgroundColor() {
        
        statusBarView.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.262745098, blue: 0.2274509804, alpha: 1)
        view.addSubview(statusBarView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            statusBarView.isHidden = true
        }else{
            print("Portrait")
            statusBarView.isHidden = false
        }
    }
    
    // MARK:  Configure Sign Up label
    func configureRegistrationLabel() {
        
        lblRegister = ActiveLabel(frame: containerDontHaveAccount.bounds)
        lblRegister.autoresizingMask = [.flexibleWidth]
        containerDontHaveAccount.addSubview(lblRegister)
        let register = ActiveType.custom(pattern: String(format: "\\s%@\\b","Sign Up")) //Looks for "Sign Up"
        lblRegister.enabledTypes.append(register)
        
        lblRegister.customize { label in
            label.font = UIFont(name: PrayerPulseFont.normalFont, size: 17)!
            label.text = "Don't have an account? Sign Up"
            label.textAlignment = .center
            label.textColor = .white
            //Custom types
            label.customColor[register] = .white
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var attribs = attributes
                switch type {
                case register:
                    attribs[NSAttributedStringKey.font] = UIFont(name: PrayerPulseFont.boldFont, size: 19)!
                default: ()
                }
                return attribs
            }
        }
        
        //Handle Sign Up click
        lblRegister.handleCustomTap(for: register) { _ in
            
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: ViewControllerIdentifiers.createAccountVC)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK:  Login API call
    fileprivate func tryLooggingInUser() {
        
        Loader.showLoader()
        User.logInUserWith(Email: tfEmail.text!, Password: tfPassword.text!, success: { (user) in
            self.navigateToHomeScreen()
        }) { (errorr) in
            Loader.hideLoader()
            print("login error: \(errorr)")
            self.showAlertExtWith(Message: errorr)
        }
    }
    
    // MARK:  Navigate to Home screen
    fileprivate func navigateToHomeScreen() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: ViewControllerIdentifiers.rootVC)
        self.view.window?.rootViewController = mainViewController
        Loader.hideLoader()
    }
    
    
    //MARK: - IBActions
    @IBAction func loginAction(_ sender: PrayerPulseRoundedButton) {
        
        if tfEmail.text! != "" {
            if self.isEmailValid() {
                if tfPassword.text! != "" {
                    tryLooggingInUser()
                }else{
                    showAlertExtWith(Message: "Please enter your Password.")
                }
            }else{
                showAlertExtWith(Message: "Please enter valid email address.")
            }
        }else{
            showAlertExtWith(Message: "Please enter your Email.")
        }
    }
}


// MARK: - TextFields validation
extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SignInViewController {
    
    fileprivate func isEmailValid() -> Bool {
        return EmailValidator.isValidEmail(tfEmail.text!)
    }
    
    fileprivate func isPasswordValid() -> Bool {
        return PasswordValidator.isAllowedPasswordLength(tfPassword.text!) &&
            PasswordValidator.isPasswordNotEmpty(tfPassword.text!)
    }
    
    fileprivate func isEnteredDataValid() -> Bool {
        return isEmailValid() && isPasswordValid()
    }
}
