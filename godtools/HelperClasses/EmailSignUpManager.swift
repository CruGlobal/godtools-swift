//
//  EmailSignUpManager.swift
//  godtools
//
//  Created by Greg Weiss on 8/1/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

enum DataManagerError: Error {
    case StatusCodeError(Int)
}

class EmailSignUpManager {
    
    static let emailSignupURL = URL(string: "https://campaign-forms.cru.org/forms")!
    static let emailCampaignId = "3fb6022c-5ef9-458c-928a-0380c4a0e57b"
    
    func signUpUserForEmailRegistration(attributes: [String: String]?) {
        if let userAtts = attributes {
            let userAttributes = processAttributes(dict: userAtts)
            sendPostWithUserEmail(attributes: userAttributes)
            UserDefaults.standard.set(true, forKey: GTConstants.kUserEmailIsRegistered)
        }
    }
    
     private func processAttributes(dict: [String: String]) -> [String: String] {
        var userDict = [String: String]()
        if let lastName = dict["lastName"] {
            userDict["last_name"] = lastName
        }
        if let firstName = dict["firstName"] {
            userDict["first_name"] = firstName
        }
        if let email = dict["email"] {
            userDict["email_address"] = email
            userDict["id"] = EmailSignUpManager.emailCampaignId
        }
        return userDict
    }
    
    private func sendPostWithUserEmail(attributes: [String: String]) {
        Alamofire.request(EmailSignUpManager.emailSignupURL, method: .post, parameters: attributes).validate { (request, response, data) -> Request.ValidationResult in
            if response.statusCode / 100 != 2 {
                return .failure(DataManagerError.StatusCodeError(response.statusCode))
            }
            return .success
        }
    }
    
}
