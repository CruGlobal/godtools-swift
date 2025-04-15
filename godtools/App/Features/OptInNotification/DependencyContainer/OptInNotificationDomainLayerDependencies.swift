//
//  OptInNotificationDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationDomainLayerDependencies {

    private let dataLayer: OptInNotificationDataLayerDependencies

    init(dataLayer: OptInNotificationDataLayerDependencies) {

        self.dataLayer = dataLayer
    }

    func getViewOptInNotificationUseCase() -> ViewOptInNotificationUseCase {
        return ViewOptInNotificationUseCase(
            getInterfaceStringsRepository:dataLayer.getOptInNotificationInterfaceStringsRepositoryInterface()
        )
    }

    func getViewOptInDialogUseCase() -> ViewOptInDialogUseCase {
        return ViewOptInDialogUseCase(
            getInterfaceStringsRepository:dataLayer.getOptInDialogInterfaceStringsRepositoryInterface()
        )
    }

    func getRequestNotificationPermissionUseCase() -> RequestNotificationPermissionUseCase {
        return RequestNotificationPermissionUseCase(
            requestNotificationPermission:dataLayer.getRequestNotificationPermission()
        )
    }

    func getCheckNotificationStatusUseCase() -> CheckNotificationStatusUseCase {
        return CheckNotificationStatusUseCase(
            checkNotificationStatus: dataLayer.getCheckNotificationStatus()
        )
    }
}
