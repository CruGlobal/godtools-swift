//
//  DownloadToolLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DownloadToolLanguageRepositoryInterface {
    
    func downloadToolLanguage(languageId: String) -> AnyPublisher<Bool, Never>
}
