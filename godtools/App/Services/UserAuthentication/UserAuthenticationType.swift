//
//  UserAuthenticationType.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol UserAuthenticationType {
    
    var authenticatedUser: ObservableValue<UserAuthModelType?> { get }
    var didAuthenticateSignal: SignalValue<Result<UserAuthModelType, Error>> { get }
    var didSignOutSignal: Signal { get }
    var isAuthenticated: Bool { get }
    
    func refreshAuthenticationIfAvailable()
    func createAccount(fromViewController: UIViewController)
    func signIn(fromViewController: UIViewController)
    func signOut(fromViewController: UIViewController)
}
