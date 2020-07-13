//
//  TranslationsApiType.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol TranslationsApiType {
    
    var session: URLSession { get }
    
    func newTranslationZipDataRequest(translationId: String) -> URLRequest
    func newTranslationZipDataOperation(translationId: String) -> RequestOperation
    func getTranslationZipData(translationId: String, complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
