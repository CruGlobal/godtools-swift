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
        case mobileContent
        case mobileContentAuthToken
        case appleRefreshToken
    }
    
    enum Account: String {
        case userId
    }
    
    func saveMobileContentAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        
        try saveUserId(authTokenDataModel.userId)
        try saveAuthToken(authTokenDataModel)
        try saveAppleRefreshToken(authTokenDataModel.appleRefreshToken, userId: authTokenDataModel.userId)
    }
    
    func deleteMobileContentAuthTokenAndUserId(userId: String) {
        
        let authTokenDeleteQuery = buildDeleteQueryForAuthToken(userId: userId)
        let _ = SecItemDelete(authTokenDeleteQuery)
        
        let userIdDeleteQuery = buildDeleteQueryForUserId()
        let _ = SecItemDelete(userIdDeleteQuery)
        
        let appleRefreshTokenDeleteQuery = buildDeleteQueryForAppleRefreshToken(userId: userId)
        let _ = SecItemDelete(appleRefreshTokenDeleteQuery)
    }
    
    func getMobileContentAuthToken(userId: String) -> String? {
        
        let getQuery = buildGetQueryForAuthToken(userId: userId)
        
        var getResult: AnyObject?
        let getStatus = SecItemCopyMatching(getQuery, &getResult)
        let getResponse = KeychainServiceResponse(osStatus: getStatus)
        
        switch getResponse {
            
        case .success:
            
            return decodeString(from: getResult)
            
        default:
            
            return nil
        }
    }
    
    func getMobileContentUserId() -> String? {
        
        let getQuery = buildGetQueryForUserId()
        
        var getResult: AnyObject?
        let getStatus = SecItemCopyMatching(getQuery, &getResult)
        let getResponse = KeychainServiceResponse(osStatus: getStatus)
        
        switch getResponse {
            
        case .success:
            
            return decodeString(from: getResult)
            
        default:
            
            return nil
        }
    }
    
    func getAppleRefreshToken(userId: String) -> String? {
        
        let getQuery = buildGetQueryForAppleRefreshToken(userId: userId)
        
        var getResult: AnyObject?
        let getStatus = SecItemCopyMatching(getQuery, &getResult)
        let getResponse = KeychainServiceResponse(osStatus: getStatus)
        
        switch getResponse {
            
        case .success:
            
            return decodeString(from: getResult)
            
        default:
            
            return nil
        }
    }
}

// MARK: - Private
 
extension MobileContentAuthTokenKeychainAccessor {
    
    private func saveAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) throws {
        
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
    
    private func saveUserId(_ userId: String) throws {
        
        let saveQuery = buildSaveQueryFromUserId(userId)
        let saveStatus = SecItemAdd(saveQuery, nil)
        
        let saveResponse = KeychainServiceResponse(osStatus: saveStatus)
        
        switch saveResponse {
            
        case .success:
            return
            
        case .duplicateItem:
            
            try updateExistingMobileContentUserId(userId)
            
        case .unhandledError(let error):
            
            throw error
        }
    }
    
    private func saveAppleRefreshToken(_ appleRefreshToken: String?, userId: String) throws {
        
        guard let appleRefreshToken = appleRefreshToken else { return }
        
        let saveQuery = buildSaveQueryFromAppleRefreshToken(appleRefreshToken: appleRefreshToken, userId: userId)
        let saveStatus = SecItemAdd(saveQuery, nil)
        
        let saveResponse = KeychainServiceResponse(osStatus: saveStatus)
        
        switch saveResponse {
            
        case .success:
            return
            
        case .duplicateItem:
            
            try updateExistingAppleRefreshToken(appleRefreshToken, userId: userId)
            
        case .unhandledError(let error):
            
            throw error
        }
    }
    
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
    
    private func updateExistingMobileContentUserId(_ userId: String) throws {
        
        let (updateQuery, updateAttributes) = buildUpdateQueryAndAttributesFromUserId(userId)
        
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
    
    private func updateExistingAppleRefreshToken(_ appleRefreshToken: String, userId: String) throws {
        
        let (updateQuery, updateAttributes) = buildUpdateQueryAndAttributesFromAppleRefreshToken(appleRefreshToken: appleRefreshToken, userId: userId)
        
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
            kSecAttrService as String: Service.mobileContentAuthToken.rawValue,
            kSecAttrAccount as String: authTokenDataModel.userId,
            kSecValueData as String: Data(authTokenDataModel.token.utf8)
        ] as CFDictionary
    }
    
    private func buildSaveQueryFromUserId(_ userId: String) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContent.rawValue,
            kSecAttrAccount as String: Account.userId.rawValue,
            kSecValueData as String: Data(userId.utf8)
        ] as CFDictionary
    }
    
    private func buildSaveQueryFromAppleRefreshToken(appleRefreshToken: String, userId: String) -> CFDictionary {
                
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.appleRefreshToken.rawValue,
            kSecAttrAccount as String: userId,
            kSecValueData as String: Data(appleRefreshToken.utf8)
        ] as CFDictionary
    }
    
    private func buildUpdateQueryAndAttributesFromAuthToken(_ authTokenDataModel: MobileContentAuthTokenDataModel) -> (query: CFDictionary, updateAttributes: CFDictionary) {
        
        let updateQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContentAuthToken.rawValue
        ] as CFDictionary
        
        let updateAttributes = [
            kSecAttrAccount as String: authTokenDataModel.userId,
            kSecValueData as String: Data(authTokenDataModel.token.utf8)
        ] as CFDictionary
        
        return (updateQuery, updateAttributes)
    }
    
    private func buildUpdateQueryAndAttributesFromUserId(_ userId: String) -> (query: CFDictionary, updateAttributes: CFDictionary) {
        
        let updateQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContent.rawValue
        ] as CFDictionary
        
        let updateAttributes = [
            kSecAttrAccount as String: Account.userId.rawValue,
            kSecValueData as String: Data(userId.utf8)
        ] as CFDictionary
        
        return (updateQuery, updateAttributes)
    }
    
    private func buildUpdateQueryAndAttributesFromAppleRefreshToken(appleRefreshToken: String, userId: String) -> (query: CFDictionary, updateAttributes: CFDictionary) {
        
        let updateQuery = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.appleRefreshToken.rawValue
        ] as CFDictionary
        
        let updateAttributes = [
            kSecAttrAccount as String: userId,
            kSecValueData as String: Data(appleRefreshToken.utf8)
        ] as CFDictionary
        
        return (updateQuery, updateAttributes)
    }
    
    private func buildDeleteQueryForAuthToken(userId: String) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContentAuthToken.rawValue,
            kSecAttrAccount as String: userId
        ] as CFDictionary
    }
    
    private func buildGetQueryForAuthToken(userId: String) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContentAuthToken.rawValue,
            kSecAttrAccount as String: userId,
            kSecReturnData as String: true
        ] as CFDictionary
    }
    
    private func buildGetQueryForUserId() -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContent.rawValue,
            kSecAttrAccount as String: Account.userId.rawValue,
            kSecReturnData as String: true
        ] as CFDictionary
    }
    
    private func buildDeleteQueryForUserId() -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.mobileContent.rawValue,
            kSecAttrAccount as String: Account.userId.rawValue,
        ] as CFDictionary
    }
    
    private func buildGetQueryForAppleRefreshToken(userId: String) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.appleRefreshToken.rawValue,
            kSecAttrAccount as String: userId,
            kSecReturnData as String: true
        ] as CFDictionary
    }
    
    private func buildDeleteQueryForAppleRefreshToken(userId: String) -> CFDictionary {
        
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Service.appleRefreshToken.rawValue,
            kSecAttrAccount as String: userId
        ] as CFDictionary
    }
    
    private func decodeString(from result: AnyObject?) -> String? {
        
        guard let resultData = result as? Data else { return nil }
        return String(data: resultData, encoding: .utf8)
    }
}
