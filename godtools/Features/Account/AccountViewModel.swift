//
//  AccountViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

class AccountViewModel: AccountViewModelType {
    
    let globalActivityServices: GlobalActivityServicesType
    let navTitle: String
    let profileName: ObservableValue<(name: String, animated: Bool)> = ObservableValue(value: (name: "", animated: false))
    let isLoadingProfile: ObservableValue<Bool> = ObservableValue(value: false)
    let items: [AccountItem]
    
    required init(loginClient: TheKeyOAuthClient, globalActivityServices: GlobalActivityServicesType) {
        
        self.globalActivityServices = globalActivityServices
        
        navTitle = NSLocalizedString("account.navTitle", comment: "")
        items = [
            AccountItem(
                itemId: .activity,
                title: NSLocalizedString("account.activity.title", comment: "")
            )
        ]
        
        isLoadingProfile.accept(value: true)
        loginClient.fetchAttributes { [weak self] (attributes: [String: String]?, error: Error?) in
            DispatchQueue.main.async {
                
                self?.isLoadingProfile.accept(value: false)
                if let attributes = attributes, let firstName = attributes["firstName"], let lastName = attributes["lastName"] {
                    self?.profileName.accept(value: (name: firstName + " " + lastName, animated: true))
                }
            }
        }
    }
}
