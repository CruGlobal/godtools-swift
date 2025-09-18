//
//  GetDownloadToolLanguageProgressInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetDownloadToolLanguageProgressInterface {
    
    func getProgressPublisher(languageId: String) -> AnyPublisher<DownloadToolLanguageProgressDomainModel, Never>
}
