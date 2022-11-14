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
    
    init() {
        
    }
    
    func getAppDiContainer() -> AppDiContainer {
        
        let infoPlist = InfoPlist()
        let appBuild = AppBuild(infoPlist: infoPlist)
        
        return AppDiContainer(
            appBuild: appBuild,
            appConfig: AppConfig(appBuild: appBuild),
            infoPlist: infoPlist,
            realmDatabase: RealmDatabase(databaseConfiguration: RealmDatabaseProductionConfiguration())
        )
    }
}
