//
//  LanguagesApiType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol LanguagesApiType {
    
    func newGetLanguagesOperation() -> RequestOperation
    func getLanguages(complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
