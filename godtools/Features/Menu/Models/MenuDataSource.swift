//
//  MenuDataSource.swift
//  godtools
//
//  Created by Levi Eggert on 2/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct MenuDataSource {
    
    let sections: [MenuSection]
    let items: [MenuSectionId: [MenuItem]]
    
    static var emptyData: MenuDataSource {
        return MenuDataSource(sections: [], items: [: ])
    }
}
