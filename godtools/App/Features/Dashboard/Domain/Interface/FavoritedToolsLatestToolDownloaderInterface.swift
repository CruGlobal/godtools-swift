//
//  FavoritedToolsLatestToolDownloaderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 1/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol FavoritedToolsLatestToolDownloaderInterface {
    
    func downloadLatestToolsPublisher(inLanguages: [BCP47LanguageIdentifier]) -> AnyPublisher<Void, Never>
}
