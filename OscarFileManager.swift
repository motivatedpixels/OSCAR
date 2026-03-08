//
//  OscarFileManager.swift
//  OSCAR
//
//  File management layer for oscar.txt
//

import Foundation

enum OscarFileError: LocalizedError {
    case directoryCreationFailed
    case bundleFileNotFound
    case fileCopyFailed
    case fileNotFound
    case permissionDenied
    case invalidContent
    case emptyContent

    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return "Failed to create Application Support directory"
        case .bundleFileNotFound:
            return "Could not find oscar.txt in app bundle"
        case .fileCopyFailed:
            return "Failed to copy oscar.txt to Application Support"
        case .fileNotFound:
            return "Could not find oscar.txt file"
        case .permissionDenied:
            return "Permission denied accessing oscar.txt"
        case .invalidContent:
            return "Invalid content in oscar.txt"
        case .emptyContent:
            return "Cannot save empty file. The bingo grid requires 24 unique items."
        }
    }
}

class OscarFileManager {
    static let shared = OscarFileManager()

    private let fileManager = FileManager.default
    private let oscarFileName = "oscar.txt"
    private let bundleInputPath = "oscar"

    private init() {}

    /// Get or create the Application Support directory for OSCAR
    func getApplicationSupportDirectory() throws -> URL {
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw OscarFileError.directoryCreationFailed
        }

        let oscarDirectory = appSupportURL.appendingPathComponent("OSCAR")

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: oscarDirectory.path) {
            do {
                try fileManager.createDirectory(at: oscarDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw OscarFileError.directoryCreationFailed
            }
        }

        return oscarDirectory
    }

    /// Ensure oscar.txt exists in Application Support (copy from bundle if needed)
    func ensureOscarFileExists() throws -> URL {
        let appSupportDir = try getApplicationSupportDirectory()
        let oscarFileURL = appSupportDir.appendingPathComponent(oscarFileName)

        // If file already exists, return its URL
        if fileManager.fileExists(atPath: oscarFileURL.path) {
            return oscarFileURL
        }

        // File doesn't exist, copy from bundle
        guard let bundleURL = Bundle.main.url(forResource: bundleInputPath, withExtension: "txt") else {
            throw OscarFileError.bundleFileNotFound
        }

        do {
            try fileManager.copyItem(at: bundleURL, to: oscarFileURL)
        } catch {
            throw OscarFileError.fileCopyFailed
        }

        return oscarFileURL
    }

    /// Load raw oscar.txt content for the editor (preserves section dividers starting with "-")
    func loadOscarContentForEditor() throws -> String {
        let fileURL = try ensureOscarFileExists()
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoPermissionError {
                throw OscarFileError.permissionDenied
            }
            throw OscarFileError.fileNotFound
        }
    }

    /// Load oscar.txt lines from Application Support (copy from bundle first if needed).
    /// Excludes empty lines and section dividers (lines starting with "-"); use for grid item selection only.
    func loadOscarLines() throws -> [String] {
        let content = try loadOscarContentForEditor()

        // Split into lines and filter (remove empty lines and section dividers starting with "-")
        let lines = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("-") }

        if lines.isEmpty {
            throw OscarFileError.invalidContent
        }

        return lines
    }

    /// Save content to oscar.txt in Application Support
    func saveOscarContent(_ content: String) throws {
        // Validate content is not empty
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContent.isEmpty {
            throw OscarFileError.emptyContent
        }

        let oscarFileURL = try ensureOscarFileExists()

        do {
            try content.write(to: oscarFileURL, atomically: true, encoding: .utf8)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileWriteNoPermissionError {
                throw OscarFileError.permissionDenied
            }
            throw error
        }
    }

    /// Count number of non-empty lines in content (excluding headers starting with "-")
    func countItems(in content: String) -> Int {
        return content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("-") }
            .count
    }
}
