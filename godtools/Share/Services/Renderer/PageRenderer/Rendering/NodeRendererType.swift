//
//  NodeRendererType.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol NodeRendererType {
    
    var parent: UIView { get }
    
    init(parent: UIView)
    func render(children: [PageXmlNode])
}
