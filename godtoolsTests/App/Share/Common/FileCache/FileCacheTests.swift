//
//  FileCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/12/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation

@Suite(.serialized)
struct FileCacheTests {
    
    private static let testsFileCacheRootDirectory: String = "tests_file_cache"
    private static let tempDirectoryName: String = "temp_directory"
    
    @Test("")
    func returnsRootDirectoryUrl() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            #expect(url.absoluteString.contains(Self.testsFileCacheRootDirectory))
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func returnsDirectoryUrl() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let location = FileCacheLocation(relativeUrlString: Self.testsFileCacheRootDirectory)
        
        switch fileCache.getDirectory(location: location) {
        case .success(let url):
            #expect(url.absoluteString.contains(Self.testsFileCacheRootDirectory))
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func isDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == true)
    }
    
    @Test("")
    func isNotDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        let isDirectory: Bool = fileCache.getIsDirectory(url: newDiretoryUrl)
        
        #expect(isDirectory == false)
    }
    
    @Test("")
    func isFile() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == true)
        case .failure(let error):
            throw error
        }
        
        let fileUrl: URL
        
        switch fileCache.getFile(location: fileLocation) {
        case .success(let url):
            fileUrl = url
        case .failure(let error):
            throw error
        }
        
        #expect(fileUrl.absoluteString.contains(fileName))
    }
    
    @Test("")
    func removeDirectory() async throws {
        
        let fileCache = Self.getTestsFileCache()
        let rootDirectoryUrl: URL
        
        switch fileCache.getRootDirectory() {
        case .success(let url):
            rootDirectoryUrl = url
        case .failure(let error):
            throw error
        }
        
        let newDiretoryUrl: URL = rootDirectoryUrl.appendingPathComponent(Self.tempDirectoryName)
        
        switch fileCache.createDirectoryIfNotExists(directoryUrl: newDiretoryUrl) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == true)
        
        if let error = fileCache.removeItem(url: newDiretoryUrl) {
            throw error
        }
                
        #expect(fileCache.getIsDirectory(url: newDiretoryUrl) == false)
    }
    
    @Test("")
    func removeFile() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == true)
        case .failure(let error):
            throw error
        }
        
        if let error = fileCache.removeFile(location: fileLocation) {
            throw error
        }
        
        switch fileCache.getFileExists(location: fileLocation) {
        case .success(let fileExists):
            #expect(fileExists == false)
        case .failure(let error):
            throw error
        }
    }
    
    @Test("")
    func getData() async throws {
        
        let fileCache = Self.getTestsFileCache()
        
        switch fileCache.getRootDirectory() {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
                
        let optionalFileData: Data? = "text data".data(using: .utf8)
        let fileData: Data = try #require(optionalFileData)
        let fileName: String = "file.txt"
        let fileLocation = FileCacheLocation(relativeUrlString: "\(Self.tempDirectoryName)/\(fileName)")
        
        switch fileCache.storeFile(location: fileLocation, data: fileData) {
        case .success( _):
            break
        case .failure(let error):
            throw error
        }
        
        switch fileCache.getData(location: fileLocation) {
        case .success(let data):
            #expect(data != nil)
        case .failure(let error):
            throw error
        }
    }
}

extension FileCacheTests {
    
    private static func getTestsFileCache() -> FileCache {
        Self.clearTestsFileCache()
        return FileCache(rootDirectory: Self.testsFileCacheRootDirectory)
    }
    
    private static func clearTestsFileCache() {
        _ = FileCache(rootDirectory: Self.testsFileCacheRootDirectory).removeRootDirectory()
    }
}
