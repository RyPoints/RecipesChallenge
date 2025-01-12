//
//  ImageCache.swift
//  ImageCache
//
//  Created by Ryan Davis on 1/10/25.
//

import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let expirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Clean expired cache on init
        Task {
            await cleanExpiredCache()
        }
    }
    
    func object(forKey key: String) async -> UIImage? {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Check disk cache
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey(key))
        let metadataURL = fileURL.appendingPathExtension("metadata")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Check expiration
        if let metadata = try? Data(contentsOf: metadataURL),
           let timestamp = try? JSONDecoder().decode(TimeInterval.self, from: metadata),
           Date().timeIntervalSince1970 - timestamp > expirationInterval {
            // Remove expired file
            try? fileManager.removeItem(at: fileURL)
            try? fileManager.removeItem(at: metadataURL)
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Cache in memory
        cache.setObject(image, forKey: key as NSString)
        return image
    }
    
    func set(_ image: UIImage, forKey key: String) async {
        // Save to memory cache
        cache.setObject(image, forKey: key as NSString)
        
        // Save to disk cache
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = cacheDirectory.appendingPathComponent(cacheKey(key))
        let metadataURL = fileURL.appendingPathExtension("metadata")
        
        do {
            try data.write(to: fileURL)
            let timestamp = Date().timeIntervalSince1970
            let metadata = try JSONEncoder().encode(timestamp)
            try metadata.write(to: metadataURL)
        } catch {
            print("Failed to write image to disk: \(error)")
        }
    }
    
    private func cleanExpiredCache() async {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension != "metadata" {
                let metadataURL = file.appendingPathExtension("metadata")
                
                if let metadata = try? Data(contentsOf: metadataURL),
                   let timestamp = try? JSONDecoder().decode(TimeInterval.self, from: metadata),
                   Date().timeIntervalSince1970 - timestamp > expirationInterval {
                    try? fileManager.removeItem(at: file)
                    try? fileManager.removeItem(at: metadataURL)
                }
            }
        } catch {
            print("Failed to clean expired cache: \(error)")
        }
    }
    
    func clearCache() async {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to clear disk cache: \(error)")
        }
    }
    
    private func cacheKey(_ urlString: String) -> String {
        // Convert string hash to base-36 for a shorter, filesystem-safe unique identifier
        return String(abs(urlString.hash), radix: 36)
    }
}
