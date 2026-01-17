import Foundation
import SwiftData

@Model
final class LogEntry {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var notes: String
    var photoFilename: String?
    var createdAt: Date

    var entryType: EntryType?
    @Relationship(deleteRule: .cascade) var measurements: [Measurement]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        notes: String = "",
        photoFilename: String? = nil,
        createdAt: Date = Date(),
        entryType: EntryType? = nil,
        measurements: [Measurement] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.notes = notes
        self.photoFilename = photoFilename
        self.createdAt = createdAt
        self.entryType = entryType
        self.measurements = measurements
    }

    func measurementValue(for kind: MeasurementKind) -> Measurement? {
        measurements.first { $0.kind == kind }
    }
}
