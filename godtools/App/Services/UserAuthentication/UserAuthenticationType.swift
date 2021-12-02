//
//  UserAuthenticationType.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol UserAuthenticationType {
    
    var authenticatedUser: ObservableValue<UserAuthModel?> { get }
    var didAuthenticateSignal: SignalValue<Result<UserAuthModel, Error>> { get }
    var didSignOutSignal: Signal { get }
    var isAuthenticated: Bool { get }
    
    func createAccount(fromViewController: UIViewController)
    func signIn(fromViewController: UIViewController)
    func signOut(fromViewController: UIViewController)
    func signOut()
}
