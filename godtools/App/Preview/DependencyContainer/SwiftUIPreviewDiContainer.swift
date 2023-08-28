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
    
    private static let previewDatabase: SwiftUIPreviewDatabase = SwiftUIPreviewDatabase(databaseConfiguration: SwiftUIPreviewDatabaseConfiguration())
    
    init() {
        
    }
    
    func getAppDiContainer() -> AppDiContainer {
        
        let infoPlist = InfoPlist()
        let appBuild = AppBuild(infoPlist: infoPlist)
        
        return AppDiContainer(
            appBuild: appBuild,
            appConfig: AppConfig(appBuild: appBuild),
            infoPlist: infoPlist,
            realmDatabase: SwiftUIPreviewDiContainer.previewDatabase
        )
    }
}
