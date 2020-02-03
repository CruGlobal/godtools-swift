//
//  MenuProviderType.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol MenuProviderType {
    
    func getMenuDataSource(generalMenuSectionId: GeneralMenuSectionId) -> MenuDataSource
}
