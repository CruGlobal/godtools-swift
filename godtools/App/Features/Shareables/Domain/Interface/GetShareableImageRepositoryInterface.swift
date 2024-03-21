//
//  GetShareableImageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol GetShareableImageRepositoryInterface {
    
    func getImagePublisher(shareable: ShareableDomainModel) -> AnyPublisher<ShareableImageDomainModel?, Never>
}
