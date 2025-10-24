//
//  LiveActivitiesImageDownloader.swift
//  Actito Go
//
//  Created by Helder Pinhal on 15/12/2022.
//

import Foundation
import UIKit

private let IMAGE_MAX_SIZE: CGFloat = 256

@available(iOS 16.1, *)
class LiveActivitiesImageDownloader {
    static let shared = LiveActivitiesImageDownloader()

    private init() {}


    func image(for product: Product) -> UIImage? {
        guard let imageContainerUrl = imageContainerUrl(for: product) else {
            return nil
        }

        guard let image = UIImage(contentsOfFile: imageContainerUrl.path()) else {
            return nil
        }

        return image
    }

    func downloadImage(for product: Product) async throws {
        guard let imageContainerUrl = imageContainerUrl(for: product) else {
            throw LiveActivitiesImageDownloaderError.imageContainerUnavailable
        }

        guard !FileManager.default.fileExists(atPath: imageContainerUrl.path()) else {
            return
        }

        let (source, _) = try await URLSession.shared.download(from: URL(string: product.imageUrl)!)
        try FileManager.default.moveItem(at: source, to: imageContainerUrl)
        try resizeImage(url: imageContainerUrl)
    }

    private func imageContainerUrl(for product: Product) -> URL? {
        guard let imageUrl = URL(string: product.imageUrl) else {
            return nil
        }

        let applicationGroup = "group.re.notifica.go.widgets"
        guard let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: applicationGroup) else {
            return nil
        }

        return containerUrl.appendingPathComponent(imageUrl.lastPathComponent)
    }

    private func resizeImage(url: URL) throws {
        guard let image = UIImage(contentsOfFile: url.path()) else {
            return
        }

        guard image.size.width > IMAGE_MAX_SIZE, image.size.height > IMAGE_MAX_SIZE else {
            return
        }

        let size = image.size
        let targetSize = CGSize(width: IMAGE_MAX_SIZE, height: IMAGE_MAX_SIZE)

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio > heightRatio
            ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let newImage else {
            return
        }

        guard let data = newImage.jpegData(compressionQuality: 0.8) else {
            return
        }

        try data.write(to: url)
    }
}


enum LiveActivitiesImageDownloaderError: Error {
    case imageContainerUnavailable
}
