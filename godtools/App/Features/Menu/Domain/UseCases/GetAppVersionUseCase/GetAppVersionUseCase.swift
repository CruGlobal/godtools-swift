//
//  GetAppVersionUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAppVersionUseCase {
    
    private let infoPlist: InfoPlist
    
    init(infoPlist: InfoPlist) {
        
        self.infoPlist = infoPlist
    }
    
    func getAppVersionPublisher() -> AnyPublisher<AppVersionDomainModel, Never> {
        
        let versionString: String
        
        if let appVersion = infoPlist.appVersion, let bundleVersion = infoPlist.bundleVersion {
            versionString = "v" + appVersion + " " + "(" + bundleVersion + ")"
        }
        else {
            versionString = ""
        }
                
        let appVersion = AppVersionDomainModel(versionString: versionString)
        
        return Just(appVersion)
            .eraseToAnyPublisher()
    }
}
