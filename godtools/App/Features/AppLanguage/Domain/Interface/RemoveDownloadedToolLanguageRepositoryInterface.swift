//
//  RemoveDownloadedToolLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 12/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol RemoveDownloadedToolLanguageRepositoryInterface {
    
    func removeDownloadedToolLanguage(languageId: String) -> AnyPublisher<Bool, Never>
}
