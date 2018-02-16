//
//  LoginViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 2/16/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            // proces login
            return true
        }
        return false
    }
}
