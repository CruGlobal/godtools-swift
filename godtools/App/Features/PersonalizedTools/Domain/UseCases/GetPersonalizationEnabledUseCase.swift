//
//  GetPersonalizationEnabledUseCase.swift
//  godtools
//
//  Created by Jason Bennett on 11/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetPersonalizationEnabledUseCase: Sendable {

    private let remoteConfigRepository: RemoteConfigRepository

    init(remoteConfigRepository: RemoteConfigRepository) {

        self.remoteConfigRepository = remoteConfigRepository
    }

    func execute() async -> Bool {

        return await remoteConfigRepository
            .getRemoteConfig()?
            .personalizationIsEnabled ?? false
    }
}
