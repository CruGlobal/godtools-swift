//
//  ResourcesApiType.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol ResourcesApiType {
    
    func newResourcesPlusLatestTranslationsAndAttachmentsOperation() -> RequestOperation
    func getResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
    func getResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ result: Result<ResourcesPlusLatestTranslationsAndAttachmentsModel?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue
}
