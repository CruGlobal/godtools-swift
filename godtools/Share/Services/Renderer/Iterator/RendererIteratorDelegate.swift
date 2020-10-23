//
//  RendererIteratorDelegate.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol RendererIteratorDelegate: class {
    
    func rendererIteratorDidIterateNode(rendererIterator: RendererIteratorType, node: BaseRendererNode)
    func rendererIteratorError()
}
