//
//  DeleteUserDetailsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/12/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

protocol DeleteUserDetailsInterface {
    
    func deleteUserDetailsPublisher() -> AnyPublisher<Void, Error>
}
