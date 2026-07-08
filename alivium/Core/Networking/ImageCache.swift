//
//  ImageCache.swift
//  alivium
//

import UIKit
import CryptoKit

/// Two-layer cache for remote catalog images (Phase 2 prep — CLAUDE.md 9.7). An in-memory
/// `NSCache` gives instant re-access within a session; a disk cache under the app's Caches
/// directory means a relaunch doesn't have to re-download images it already fetched. `actor`
/// isolation makes both layers safe to hit concurrently from many scrolling grid cells at once
/// without any manual locking.
actor ImageCache {
    static let shared = ImageCache()

    /// Keyed by the SHA256 hex of the URL rather than the URL itself — `NSCache` only needs
    /// object identity/equality, but the disk layer below reuses the same key as a filename, and
    /// URLs can contain characters (`/`, `?`, `:`) that aren't safe path components.
    private let memoryCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        // Cost is decoded byte size (not item count) — a handful of full-bleed hero photos
        // shouldn't be able to evict an entire grid's worth of thumbnails just because both
        // "count" as one item each.
        cache.totalCostLimit = 100 * 1024 * 1024 // ~100 MB of decoded pixel data
        return cache
    }()

    private let diskCacheURL: URL
    private let fileManager = FileManager.default

    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cachesDirectory.appendingPathComponent("CatalogImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    /// Returns the cached image for `url`, checking memory first, then disk — or `nil` if it
    /// hasn't been fetched before (the caller is expected to download and `store` it).
    func cachedImage(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)

        if let memoryHit = memoryCache.object(forKey: key as NSString) {
            return memoryHit
        }

        guard let diskData = fileManager.contents(atPath: diskFilePath(for: key)),
              let diskImage = UIImage(data: diskData) else {
            return nil
        }
        memoryCache.setObject(diskImage, forKey: key as NSString, cost: cost(of: diskImage))
        return diskImage
    }

    /// Populates both layers. Disk writes happen synchronously within the actor — image payloads
    /// are small enough (thumbnail/product-photo scale) that this doesn't meaningfully contend
    /// with the next call queued behind it.
    func store(_ image: UIImage, data: Data, for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString, cost: cost(of: image))
        fileManager.createFile(atPath: diskFilePath(for: key), contents: data)
    }

    /// Clears both layers — not on any hot path today, but every cache needs an escape hatch
    /// (e.g. a future "Clear Cache" row in Profile's settings, or test teardown).
    func clearAll() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func diskFilePath(for key: String) -> String {
        diskCacheURL.appendingPathComponent(key).path
    }

    private func cost(of image: UIImage) -> Int {
        guard let cgImage = image.cgImage else {
            return Int(image.size.width * image.size.height * 4)
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}
