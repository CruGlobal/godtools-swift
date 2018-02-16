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
        processLogin()
    }
    
    @objc func viewWasTapped() {
        self.view.endEditing(true)
    }
    
    private func validateInputs() -> Bool {
        guard let username = usernameTextField.text, username.count > 0 else {
            showAlert(withTitle: "Username is required", message: "Please enter your username.")
            return false
        }
        
        guard let password = passwordTextField.text, password.count > 0 else {
            showAlert(withTitle: "Password is required", message: "Please enter your password.")
            return false
        }
        
        return true
    }
    
    fileprivate func processLogin() {
        if !validateInputs() {
            return
        }
    }
    
    private func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "ok".localized, style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
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
            processLogin()
            return true
        }
        return false
    }
}
