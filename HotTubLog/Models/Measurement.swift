import Foundation
import SwiftData

@Model
final class Measurement {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var value: Double
    var unit: String

    var logEntry: LogEntry?

    init(
        id: UUID = UUID(),
        kind: MeasurementKind,
        value: Double,
        unit: String,
        logEntry: LogEntry? = nil
    ) {
        self.id = id
        self.kindRaw = kind.rawValue
        self.value = value
        self.unit = unit
        self.logEntry = logEntry
    }

    var kind: MeasurementKind {
        get { MeasurementKind(rawValue: kindRaw) ?? .ph }
        set { kindRaw = newValue.rawValue }
    }
}
