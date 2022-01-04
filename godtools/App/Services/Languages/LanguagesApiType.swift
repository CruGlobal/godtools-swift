//
//  LanguagesApiType.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol LanguagesApiType {
    
    func newGetLanguagesOperation() -> RequestOperation
    func getLanguages(complete: @escaping ((_ result: Result<Data?, RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue
    func getLanguages(complete: @escaping ((_ result: Result<[LanguageModel], RequestResponseError<NoHttpClientErrorResponse>>) -> Void)) -> OperationQueue
}
