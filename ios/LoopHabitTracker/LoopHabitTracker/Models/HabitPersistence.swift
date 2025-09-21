import Foundation

struct HabitPersistence {
    enum PersistenceError: LocalizedError, Equatable {
        case failedToAccessDirectory
        case failedToLoad(String)
        case failedToSave(String)

        var errorDescription: String? {
            switch self {
            case .failedToAccessDirectory:
                return NSLocalizedString("Unable to access documents directory.", comment: "Persistence error")
            case .failedToLoad(let message):
                return message
            case .failedToSave(let message):
                return message
            }
        }
    }

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager

    init(fileManager: FileManager = .default, directory: URL? = nil) {
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        if let directory {
            self.fileURL = directory.appendingPathComponent("habits.json")
        } else {
            let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
            self.fileURL = base.appendingPathComponent("habits.json")
        }
    }

    func load() async throws -> [Habit] {
        if !fileManager.fileExists(atPath: fileURL.path) {
            return PreviewData.bootstrapHabits
        }

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let habits = try decoder.decode([Habit].self, from: data)
                    continuation.resume(returning: habits)
                } catch {
                    continuation.resume(throwing: PersistenceError.failedToLoad(error.localizedDescription))
                }
            }
        }
    }

    func save(_ habits: [Habit]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                do {
                    let directory = fileURL.deletingLastPathComponent()
                    if !fileManager.fileExists(atPath: directory.path) {
                        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    }
                    let data = try encoder.encode(habits)
                    try data.write(to: fileURL, options: [.atomic])
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: PersistenceError.failedToSave(error.localizedDescription))
                }
            }
        }
    }
}
