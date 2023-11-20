//
//  GetDownloadToolProgressInterfaceStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetDownloadToolProgressInterfaceStringsUseCaseTests: QuickSpec {
    
    override class func spec() {
    
        describe("User tapped a tool and is viewing downloading tool progress.") {
         
            let downloadToolMessage: String = "Downloading tool."
            let favoriteThisToolForOfflineUseMessage: String = "Downloading tool. Favorite this tool for offline use."
            
            context("When a tool is favorited.") {
                
                let getDownloadToolProgressInterfaceStringsRepository = TestsGetDownloadToolProgressInterfaceStringsRepository(
                    toolIsFavorited: true,
                    downloadToolMessage: downloadToolMessage,
                    favoriteThisToolForOfflineUseMessage: favoriteThisToolForOfflineUseMessage
                )
                
                let getDownloadToolProgressInterfaceStringsUseCase = GetDownloadToolProgressInterfaceStringsUseCase(
                    getInterfaceStringsRepositoryInterface: getDownloadToolProgressInterfaceStringsRepository
                )
                
                it("The message should be the downloading tool message.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsUseCase
                            .getStringsPublisher(resource: nil, appLanguagePublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(downloadToolMessage))
                }
            }
            
            context("When a tool is not favorited.") {
                
                let getDownloadToolProgressInterfaceStringsRepository = TestsGetDownloadToolProgressInterfaceStringsRepository(
                    toolIsFavorited: false,
                    downloadToolMessage: downloadToolMessage,
                    favoriteThisToolForOfflineUseMessage: favoriteThisToolForOfflineUseMessage
                )
                
                let getDownloadToolProgressInterfaceStringsUseCase = GetDownloadToolProgressInterfaceStringsUseCase(
                    getInterfaceStringsRepositoryInterface: getDownloadToolProgressInterfaceStringsRepository
                )
                
                it("The message should be the downloading tool message with favorite this tool for offline use messaging.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsUseCase
                            .getStringsPublisher(resource: nil, appLanguagePublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(favoriteThisToolForOfflineUseMessage))
                }
            }
            
            context("When a tool is not favoritable.") {
                
                let getDownloadToolProgressInterfaceStringsRepository = TestsGetDownloadToolProgressInterfaceStringsRepository(
                    toolIsFavorited: nil,
                    downloadToolMessage: downloadToolMessage,
                    favoriteThisToolForOfflineUseMessage: favoriteThisToolForOfflineUseMessage
                )
                
                let getDownloadToolProgressInterfaceStringsUseCase = GetDownloadToolProgressInterfaceStringsUseCase(
                    getInterfaceStringsRepositoryInterface: getDownloadToolProgressInterfaceStringsRepository
                )
                
                it("The message should be the downloading tool message.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var interfaceStringsRef: DownloadToolProgressInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getDownloadToolProgressInterfaceStringsUseCase
                            .getStringsPublisher(resource: nil, appLanguagePublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (interfaceStrings: DownloadToolProgressInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    interfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                            }
                    }

                    expect(interfaceStringsRef?.downloadMessage).to(equal(downloadToolMessage))
                }
            }
        }
    }
}
