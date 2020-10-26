//
//  RendererViewType.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol RendererViewType {
    
    associatedtype RendererNode: BaseRendererNode
    
    var view: UIView { get }
    
    func render(node: RendererNode)
}
