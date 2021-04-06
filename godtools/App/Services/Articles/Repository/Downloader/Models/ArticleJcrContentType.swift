//
//  ArticleJcrContentType.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ArticleJcrContentType {
    
    associatedtype TagsList: Sequence
    
    var aemUri: String { get }
    var canonical: String? { get }
    var tags: TagsList { get }
    var title: String? { get }
    var uuid: String? { get }
}
