//
//  LocalizationServicesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol LocalizationServicesInterface {
 
    func stringForEnglish(key: String, fileType: LocalizableStringsFileType) -> String
    func stringForSystemElseEnglish(key: String, fileType: LocalizableStringsFileType) -> String
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType) -> String
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType) -> String
}
