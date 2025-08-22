//
//  SwiftUIPreviewDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class SwiftUIPreviewDiContainer {
    
    private static let previewDatabase: SwiftUIPreviewDatabase = SwiftUIPreviewDatabase()
    
    init() {
        
    }
    
    func getAppDiContainer() -> AppDiContainer {
        
        let appBuild = AppBuild(buildConfiguration: .production)
        
        return AppDiContainer(
            appConfig: UITestsAppConfig(),
            realmDatabase: SwiftUIPreviewDiContainer.previewDatabase,
            dataLayerType: .mock
        )
    }
}
