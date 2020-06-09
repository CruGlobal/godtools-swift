//
//  ToolsViewModelType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolsViewModelType {
    
    var tools: ObservableValue<[DownloadedResource]> { get }
    var toolListIsEditable: Bool { get }
    
    func favoriteTapped(resource: DownloadedResource)
    func unfavoriteTapped(resource: DownloadedResource)
    func toolTapped(resource: DownloadedResource)
    func toolDetailsTapped(resource: DownloadedResource)
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath)
}
