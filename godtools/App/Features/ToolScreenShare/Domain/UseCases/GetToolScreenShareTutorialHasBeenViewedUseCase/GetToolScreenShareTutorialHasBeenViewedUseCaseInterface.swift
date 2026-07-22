//
//  GetToolScreenShareTutorialHasBeenViewedUseCaseInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol GetToolScreenShareTutorialHasBeenViewedUseCaseInterface {
    
    func execute(toolId: String) -> Bool
}
