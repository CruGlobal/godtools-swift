//
//  LoginViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 2/16/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuth2

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: BlueButton!
    @IBOutlet weak var logoutButton: BlueButton!
    
    private let serverURL = URL(string: "https://thekey.me/cas/")!
    private let clientId = " "
    
    let loginClient = TheKeyOAuth2Client()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loginClient = loginClient, !loginClient.isConfigured() {
            loginClient.setServerURL(serverURL, clientId: clientId)
        }
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.setTitle("login".localized, for: .normal)
        logoutButton.setTitle("logout".localized, for: .normal)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        view.addGestureRecognizer(tapRecognizer)
        
        setViewState()
    }
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
        processLogin()
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: Any) {
        loginClient?.logout()
        setViewState()
    }
    
    @objc func viewWasTapped() {
        self.view.endEditing(true)
    }
    
    private func setViewState() {
        guard let loginClient = loginClient else {
            return
        }
        
        let isAuthenticated = loginClient.isAuthenticated()
        
        logoutButton.isHidden = !isAuthenticated
        loginButton.isHidden = isAuthenticated
        passwordTextField.isEnabled = !isAuthenticated
        usernameTextField.isEnabled = !isAuthenticated
    }
    
    private func validateInputs(_ username: String?, _ password: String?) -> Bool {
        guard let username = username, username.count > 0 else {
            showAlert(withTitle: "error".localized, message: "username_required".localized)
            return false
        }
        
        guard let password = password, password.count > 0 else {
            showAlert(withTitle: "error".localized, message: "password_required".localized)
            return false
        }
        
        return true
    }
    
    fileprivate func processLogin() {
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if !validateInputs(username, password) {
            return
        }
        
        guard let loginClient = loginClient else {
            return
        }
        
        loginClient.passwordGrantLogin(for: username!, password: password!) { [unowned self] (result, error) in
            switch result {
            case .success:
                self.showAlert(withTitle: "success".localized, message: "")
                self.setViewState()
                debugPrint(loginClient.guid())
                debugPrint(loginClient.isAuthenticated())
            case .badPassword:
                self.showAlert(withTitle: "error".localized, message: "bad_password".localized)
            default:
                debugPrint(loginClient.isAuthenticated())
            }
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
