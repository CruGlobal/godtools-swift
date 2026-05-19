//
//  ToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class ToolsDiContainer {

    private let dataLayer: ToolsDataLayerDependencies

    let domainLayer: ToolsDomainLayerDependencies

    init(core: AppCoreDiContainer, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies, tutorialDomainLayer: TutorialDomainLayerDependencies) {

        self.dataLayer = ToolsDataLayerDependencies(coreDataLayer: core.dataLayer)
        self.domainLayer = ToolsDomainLayerDependencies(core: core, dataLayer: dataLayer, personalizedToolsDataLayer: personalizedToolsDataLayer, tutorialDomainLayer: tutorialDomainLayer)
    }
}
