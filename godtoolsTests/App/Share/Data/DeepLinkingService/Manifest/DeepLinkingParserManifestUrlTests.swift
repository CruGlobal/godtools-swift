//
//  DeepLinkingParserManifestUrlTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine

struct DeepLinkingParserManifestUrlTests {
    
    private static let schemeGodtools: String = "godtools"
    private static let schemeHttp: String = "http"
    private static let schemeHttps: String = "https"
    private static let hostGodTools: String = "org.cru.godtools"
    private static let hostGodToolsApp: String = "godtoolsapp.com"
    private static let hostKnowGod: String = "knowgod.com"
    
    struct TestArgument {
        let scheme: String
        let host: String
        let path: String?
        let parserClass: DeepLinkParserInterface.Type
        let incomingDeepLinkUrl: String
        let expectedParserClass: DeepLinkParserInterface.Type?
    }
    
    @Test(
        "Should return a matching parser when both scheme and host match the incoming deep link url.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttp,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "http://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeGodtools,
                host: Self.hostKnowGod,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "godtools://knowgod.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func findsDeepLinkParserWhenSchemeAndHostAreSupported(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser != nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass))
    }
    
    @Test(
        "Should return a null parser if either the scheme or host are an empty string on the manifest.",
        arguments: [
            TestArgument(
                scheme: "",
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com",
                expectedParserClass: nil
            ),
            TestArgument(
                scheme: "",
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "://godtoolsapp.com",
                expectedParserClass: nil
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: "",
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://",
                expectedParserClass: nil
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: "",
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com",
                expectedParserClass: nil
            )
        ]
    )
    func returnsNullDeepLinkParserWhenEitherSchemeOrHostAreEmptyStrings(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser == nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass) == false)
    }
    
    @Test(
        "Should return a null parser if either the scheme or host do not match the incoming deep link url.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "http://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttp,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeGodtools,
                host: Self.hostKnowGod,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "godtools://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsNullDeepLinkParserWhenEitherSchemeOrHostAreNotSupported(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser == nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass) == false)
    }
    
    @Test(
        "Should return a matching parser when manifest path is null and incoming deep link url has a path.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: nil,
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1?param_0=0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func findsDeepLinkParserWhenPathIsNullAndIncomingDeepLinkUrlHasAPath(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser != nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass))
    }
    
    @Test(
        "Should return a parser when manifest path is empty and incoming deep link url path is empty.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsDeepLinkParserWhenPathIsEmptyAndIncomingDeepLinkUrlPathIsEmpty(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser != nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass))
    }
    
    @Test(
        "Should return a null parser when manifest path is empty and incoming deep link url has a path.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1?param_0=0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsNullDeepLinkParserWhenPathIsEmptyAndIncomingDeepLinkUrlHasAPath(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser == nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass) == false)
    }
    
    @Test(
        "Should return a null parser when manifest path is larger than incoming deep link url path.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsNullDeepLinkParserWhenPathIsLargerThanIncomingDeepLinkUrlPath(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser == nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass) == false)
    }
    
    @Test(
        "Should return a null parser when manifest path does not match incoming deep link url path.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_2/path_1/path_0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_0/path_2",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsNullDeepLinkParserWhenPathDoesNotMatchIncomingDeepLinkUrlPath(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser == nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass) == false)
    }
    
    @Test(
        "Should return a parser when manifest path matches some or all of the incoming deep link url path.",
        arguments: [
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1?param_0=0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1/path_2",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1/path_2",
                expectedParserClass: MockEmptyDeepLinkParser.self
            ),
            TestArgument(
                scheme: Self.schemeHttps,
                host: Self.hostGodToolsApp,
                path: "path_0/path_1/path_2",
                parserClass: MockEmptyDeepLinkParser.self,
                incomingDeepLinkUrl: "https://godtoolsapp.com/path_0/path_1/path_2?param_0=0",
                expectedParserClass: MockEmptyDeepLinkParser.self
            )
        ]
    )
    func returnsDeepLinkParserWhenManifestHasAPathAndIncomingDeepLinkUrlHasAPath(argument: TestArgument) async {
        
        let deepLinkingParserUrlManifest = DeepLinkingParserManifestUrl(
            scheme: argument.scheme,
            host: argument.host,
            path: argument.path,
            parserClass: argument.parserClass
        )
        
        let url = IncomingDeepLinkUrl(url: URL(string: argument.incomingDeepLinkUrl)!)
        
        let incomingDeepLink: IncomingDeepLinkType = .url(incomingUrl: url)
        
        let parser: DeepLinkParserInterface? = deepLinkingParserUrlManifest.getParserIfValidIncomingDeepLink(incomingDeepLink: incomingDeepLink)
                        
        #expect(parser != nil)
        #expect(Self.getParserTypesMatch(parser: parser, expectedParserType: argument.expectedParserClass))
    }
}

extension DeepLinkingParserManifestUrlTests {
    
    private static func getParserTypesMatch(parser: DeepLinkParserInterface?, expectedParserType: DeepLinkParserInterface.Type?) -> Bool {
        
        let parserTypesMatch: Bool
        
        if let parser = parser, let expectedParserType = expectedParserType {
            
            let parserType: DeepLinkParserInterface.Type = type(of: parser)
            let expectedType: DeepLinkParserInterface.Type = expectedParserType
            
            parserTypesMatch = parserType == expectedType
        }
        else {
            
            parserTypesMatch = false
        }
        
        return parserTypesMatch
    }
}
