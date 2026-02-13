//
//  MobileContentApiAuthSession.swift
//  godtools
//
//  Created by Rachael Skeath on 11/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

final class MobileContentApiAuthSession {
    
    private let requestSender: RequestSender
    
    let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    let userAuthentication: UserAuthentication
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(requestSender: RequestSender, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository, userAuthentication: UserAuthentication) {
     
        self.requestSender = requestSender
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
        self.userAuthentication = userAuthentication
    }
    
    func sendAuthenticatedRequest(urlRequest: URLRequest, urlSession: URLSession) async throws -> Data {
        
        let authToken: String = try await getAuthToken()
        
        do {
            
            let data: Data = try await attemptDataTaskWithAuthToken(authToken: authToken, urlRequest: urlRequest, session: urlSession)
            
            return data
        }
        catch let error {
            
            let notAuthorized: Bool = error.code == 401
            
            if notAuthorized {
                
                return try await fetchFreshAuthTokenAndReattemptDataTask(
                    urlRequest: urlRequest,
                    session: urlSession
                )
            }
            
            throw error
        }
    }
    
    private func getAuthToken() async throws -> String {
        
        if let cachedAuthTokenDataModel = mobileContentAuthTokenRepository.getCachedAuthTokenModel(), !cachedAuthTokenDataModel.isExpired {
            
            return cachedAuthTokenDataModel.token
        }
        
        return try await fetchRemoteAuthToken()
    }
    
    private func fetchRemoteAuthToken(createUser: Bool = false) async throws -> String {
        
        let result: Result<MobileContentAuthTokenDataModel, MobileContentApiError> = try await userAuthentication.renewToken()
        
        switch result {
        
        case .success(let authToken):
            return authToken.token
        
        case .failure(let apiError):
            throw apiError.getError()
        }
    }
    
    private func attemptDataTaskWithAuthToken(authToken: String, urlRequest: URLRequest, session: URLSession) async throws -> Data {
        
        let urlRequest: URLRequest = buildAuthenticatedRequest(
            from: urlRequest,
            authToken: authToken
        )
        
        let response: RequestDataResponse = try await requestSender.sendDataTask(
            urlRequest: urlRequest,
            urlSession: session
        ).validate()
                
        return response.data
    }
    
    private func fetchFreshAuthTokenAndReattemptDataTask(urlRequest: URLRequest, session: URLSession) async throws -> Data {
        
        let authToken: String = try await fetchRemoteAuthToken()
        
        return try await attemptDataTaskWithAuthToken(
            authToken: authToken,
            urlRequest: urlRequest,
            session: session
        )
    }
    
    private func buildAuthenticatedRequest(from urlRequest: URLRequest, authToken: String) -> URLRequest {
        
        var authenticatedRequest = urlRequest
        
        var headers = [String: String]()
        if let existingHeaders = authenticatedRequest.allHTTPHeaderFields {
            
            headers = existingHeaders
        }
        
        headers["Authorization"] = authToken
        authenticatedRequest.allHTTPHeaderFields = headers
        
        return authenticatedRequest
    }
}
