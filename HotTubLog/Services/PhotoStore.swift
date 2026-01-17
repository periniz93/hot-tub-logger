import Foundation
import UIKit

enum PhotoStore {
    private static let directoryName = "Photos"

    static func save(image: UIImage) throws -> String {
        let filename = "photo_\(UUID().uuidString).jpg"
        let url = try photoDirectory().appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw PhotoStoreError.encodingFailed
        }
        try data.write(to: url, options: [.atomic])
        return filename
    }

    static func load(filename: String) -> UIImage? {
        let url = try? photoDirectory().appendingPathComponent(filename)
        guard let fileURL = url else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    static func url(for filename: String) -> URL? {
        return try? photoDirectory().appendingPathComponent(filename)
    }

    private static func photoDirectory() throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documentsURL = documents else {
            throw PhotoStoreError.missingDocumentsDirectory
        }
        let directory = documentsURL.appendingPathComponent(directoryName)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }
}

enum PhotoStoreError: Error {
    case missingDocumentsDirectory
    case encodingFailed
}
