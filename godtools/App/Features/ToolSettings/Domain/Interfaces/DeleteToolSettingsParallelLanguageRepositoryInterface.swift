//
//  DeleteToolSettingsParallelLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DeleteToolSettingsParallelLanguageRepositoryInterface {

    func deletePublisher() -> AnyPublisher<Void, Never>
}
