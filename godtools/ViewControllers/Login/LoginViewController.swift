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
    
    @IBOutlet weak var loginButton: BlueButton!
    @IBOutlet weak var logoutButton: BlueButton!
    
    private let serverURL = URL(string: "https://thekey.me/cas/")!
    private let clientId = " "
    
    
    @IBAction func loginButtonWasPressed(_ sender: Any) {
    }
    
    @IBAction func logoutButtonWasPressed(_ sender: Any) {

    }
    
    @objc func viewWasTapped() {
    }
    
}

extension LoginViewController: UITextFieldDelegate {

}
