#if os(iOS)
import UIKit
public typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#endif
import UniformTypeIdentifiers
import Foundation
import Photos

public extension NSItemProvider {
    
    func loadImage() async -> PlatformImage? {
#if os(iOS)
        await loadImageIOS()
#elseif os(macOS)
        await loadImageMacOS()
#endif
    }
}

// MARK: - Shared

extension NSItemProvider {
    
    private static let imageUTIs: [String] = [
        UTType.jpeg.identifier,
        UTType.png.identifier,
        "public.heic",
        "public.heif",
        UTType.tiff.identifier,
        UTType.gif.identifier,
        UTType.webP.identifier,
        UTType.image.identifier
    ]
    
    func loadDataSafely(forTypeIdentifier uti: String) async -> Data? {
        guard hasItemConformingToTypeIdentifier(uti) else { return nil }
        return await withCheckedContinuation { continuation in
            var resumed = false
            let timeout = Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: nil)
            }
            loadDataRepresentation(forTypeIdentifier: uti) { data, _ in
                timeout.cancel()
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: data)
            }
        }
    }
}

// MARK: - iOS

#if os(iOS)
extension NSItemProvider {
    
    func loadImageIOS() async -> UIImage? {
        
        if canLoadObject(ofClass: UIImage.self) {
            if let image = await withCheckedContinuation({ continuation in
                var resumed = false
                let timeout = Task {
                    try? await Task.sleep(nanoseconds: 15_000_000_000)
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: Optional<UIImage>.none)
                }
                loadObject(ofClass: UIImage.self) { object, _ in
                    timeout.cancel()
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: object as? UIImage)
                }
            }) {
                return image
            }
        }
        
        for uti in Self.imageUTIs {
            if let data = await loadDataSafely(forTypeIdentifier: uti),
               let image = UIImage(data: data) {
                return image
            }
        }
        
        if let image = await loadViaPHAsset() { return image }
        
        for uti in Self.imageUTIs {
            guard hasItemConformingToTypeIdentifier(uti) else { continue }
            if let image = await loadFileSafely(forTypeIdentifier: uti) {
                return image
            }
        }
        
        return nil
    }
    
    // MARK: PHAsset fallback
    private func loadViaPHAsset() async -> UIImage? {
        let assetUTI = "com.apple.photos.asset-identifier"
        guard hasItemConformingToTypeIdentifier(assetUTI) else { return nil }
        
        let identifier: String? = await withCheckedContinuation { continuation in
            var resumed = false
            loadItem(forTypeIdentifier: assetUTI) { item, _ in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: item as? String)
            }
        }
        guard let identifier else { return nil }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else { return nil }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject else { return nil }
        
        return await withCheckedContinuation { continuation in
            var resumed = false
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .none
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                guard !isDegraded, !resumed else { return }
                resumed = true
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: File representation fallback
    private func loadFileSafely(forTypeIdentifier uti: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            var resumed = false
            let timeout = Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: Optional<UIImage>.none)
            }
            loadFileRepresentation(forTypeIdentifier: uti) { url, _ in
                timeout.cancel()
                guard !resumed, let url else {
                    if !resumed { resumed = true; continuation.resume(returning: nil) }
                    return
                }
                let temp = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                do {
                    try FileManager.default.copyItem(at: url, to: temp)
                    let data = try Data(contentsOf: temp)
                    try? FileManager.default.removeItem(at: temp)
                    resumed = true
                    continuation.resume(returning: UIImage(data: data))
                } catch {
                    resumed = true
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
#endif

// MARK: - macOS

#if os(macOS)
extension NSItemProvider {
    func loadImageMacOS() async -> NSImage? {
        if #available(macOS 13.0, *), canLoadObject(ofClass: NSImage.self) {
            if let image = await withCheckedContinuation({ continuation in
                var resumed = false
                let timeout = Task {
                    try? await Task.sleep(nanoseconds: 15_000_000_000)
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: Optional<NSImage>.none)
                }
                loadObject(ofClass: NSImage.self) { object, _ in
                    timeout.cancel()
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: object as? NSImage)
                }
            }) {
                return image
            }
        }
        
        for uti in Self.imageUTIs {
            if let data = await loadDataSafely(forTypeIdentifier: uti),
               let image = NSImage(data: data) {
                return image
            }
        }
        
        for uti in Self.imageUTIs {
            guard hasItemConformingToTypeIdentifier(uti) else { continue }
            if let image = await loadFileSafelyMacOS(forTypeIdentifier: uti) {
                return image
            }
        }
        
        return nil
    }
    
    private func loadFileSafelyMacOS(forTypeIdentifier uti: String) async -> NSImage? {
        await withCheckedContinuation { continuation in
            var resumed = false
            let timeout = Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: Optional<NSImage>.none)
            }
            loadFileRepresentation(forTypeIdentifier: uti) { url, _ in
                timeout.cancel()
                guard !resumed, let url else {
                    if !resumed { resumed = true; continuation.resume(returning: nil) }
                    return
                }
                let temp = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                do {
                    try FileManager.default.copyItem(at: url, to: temp)
                    let data = try Data(contentsOf: temp)
                    try? FileManager.default.removeItem(at: temp)
                    resumed = true
                    continuation.resume(returning: NSImage(data: data))
                } catch {
                    resumed = true
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
#endif
