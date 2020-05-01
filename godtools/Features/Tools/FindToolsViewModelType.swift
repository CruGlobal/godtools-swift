//
//  FindToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol FindToolsViewModelType {
    
    func pageViewed()
    func toolTapped(resource: DownloadedResource)
    func toolInfoTapped(resource: DownloadedResource)
}
