//
//  KeychainService.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Security

class KeychainService {

    enum Service: String {
        case moileContentAuthToken
    }

    func saveMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.moileContentAuthToken.rawValue,
            kSecAttrAccount as String: "\(authTokenDataModel.userId)",
            kSecValueData as String: Data(authTokenDataModel.token.utf8)
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("save success!")
            
        } else if status == errSecDuplicateItem {
            
            // TODO: - is this an ok error to have?  will we still get this error if the data is different?  should we remove the item and store it again?
            print("duplicate item")
            
        } else {
            
            print(status)
        }
    }
}
