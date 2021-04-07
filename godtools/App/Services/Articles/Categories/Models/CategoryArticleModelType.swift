//
//  CategoryArticleModelType.swift
//  godtools
//
//  Created by Levi Eggert on 3/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol CategoryArticleModelType {

    associatedtype AemUrisList: Sequence
    associatedtype UUIDString: Equatable
    
    var aemTag: String { get }
    var aemUris: AemUrisList { get }
    var categoryId: String { get }
    var languageCode: String { get }
    var uuid: UUIDString { get }
}
