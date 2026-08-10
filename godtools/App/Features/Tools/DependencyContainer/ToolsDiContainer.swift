//
//  ToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ToolsDiContainer {

    private let dataLayer: ToolsDataLayerDependencies

    let domainLayer: ToolsDomainLayerDependencies

    init(
        dataLayer: ToolsDataLayerDependencies,
        domainLayer: ToolsDomainLayerDependencies
    ) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
