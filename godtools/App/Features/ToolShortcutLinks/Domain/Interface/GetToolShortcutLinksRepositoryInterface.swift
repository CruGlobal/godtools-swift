//
//  GetToolShortcutLinksRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetToolShortcutLinksRepositoryInterface {
    
    func getLinksPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<[ToolShortcutLinkDomainModel], Never>
}
