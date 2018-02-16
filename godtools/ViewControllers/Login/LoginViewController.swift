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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        
    }
    
    @objc func viewWasTapped() {
        self.view.endEditing(true)
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
