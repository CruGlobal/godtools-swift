//
//  MobileContentAuthTokenKeychainAccessor.swift
//  godtools
//
//  Created by Rachael Skeath on 11/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Security

class MobileContentAuthTokenKeychainAccessor {
    
    enum Service: String {
        case moileContentAuthToken
    }
    
    func saveMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        
        let saveQuery = buildSaveQueryFromAuthToken(authTokenDataModel)
        let saveStatus = SecItemAdd(saveQuery, nil)
        
        let saveResponse = KeychainServiceResponse(osStatus: saveStatus)
        
        switch saveResponse {
            
        case .success:
            return
            
        case .duplicateItem:
            
            try updateExistingMobileContentAuthToken(authTokenDataModel)
            
        case .unhandledError(let error):
            
            throw error
        }
    }
    
    func getMobileContentAuthToken(userId: Int) -> String? {
        
        let getQuery = buildGetQueryForAuthToken(userId: userId)
        
        var getResult: AnyObject?
        let getStatus = SecItemCopyMatching(getQuery, &getResult)
        let getResponse = KeychainServiceResponse(osStatus: getStatus)
        
        switch getResponse {
            
        case .success:
            
            return decodeAuthToken(from: getResult)
            
        default:
            
            return nil
        }
    }
}

// MARK: - Private
 
extension MobileContentAuthTokenKeychainAccessor {
    
    private func updateExistingMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        
        let (updateQuery, updateAttributes) = buildUpdateQueryAndAttributesFromAuthToken(authTokenDataModel)
        
        let updateStatus = SecItemUpdate(updateQuery, updateAttributes)
        let updateResponse = KeychainServiceResponse(osStatus: updateStatus)
        
        switch updateResponse {
            
        case .success:
            return
            
        case .unhandledError(let error):
            
            throw error
            
        default:
            return
        }
    }
    
    private func buildSaveQueryFromAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.moileContentAuthToken.rawValue,
            kSecAttrAccount as String: "\(authTokenDataModel.userId)",
            kSecValueData as String: Data(authTokenDataModel.token.utf8)
        ] as CFDictionary
    }
    
    private func buildUpdateQueryAndAttributesFromAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) -> (query: CFDictionary, updateAttributes: CFDictionary) {
        
        let updateQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.moileContentAuthToken.rawValue
        ] as CFDictionary
        
        let updateAttributes = [
            kSecAttrAccount as String: "\(authTokenDataModel.userId)",
            kSecValueData as String: Data(authTokenDataModel.token.utf8)
        ] as CFDictionary
        
        return (updateQuery, updateAttributes)
    }
    
    private func buildGetQueryForAuthToken(userId: Int) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.moileContentAuthToken.rawValue,
            kSecAttrAccount as String: "\(userId)",
            kSecReturnData as String: true
        ] as CFDictionary
    }
    
    private func decodeAuthToken(from result: AnyObject?) -> String? {
        
        guard let resultData = result as? Data else { return nil }
        return String(data: resultData, encoding: .utf8)
    }
}
