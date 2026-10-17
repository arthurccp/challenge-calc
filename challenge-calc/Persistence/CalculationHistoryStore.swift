import Foundation

struct CalculationHistoryStore {
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        )[0].appendingPathComponent("Calculator", isDirectory: true)
            .appendingPathComponent("history.json")
    }

    func load() throws -> [Calculation] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Calculation].self, from: data)
            .sorted { $0.date > $1.date }
    }

    func save(_ calculations: [Calculation]) throws {
        let data = try JSONEncoder().encode(calculations)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
    }
}
