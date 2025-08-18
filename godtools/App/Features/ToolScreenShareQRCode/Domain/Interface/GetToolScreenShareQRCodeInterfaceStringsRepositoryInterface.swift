//
//  GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 7/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface {
    
    func getStringsPublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolScreenShareQRCodeInterfaceStringsDomainModel, Never>
}
