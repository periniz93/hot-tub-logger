import Foundation

enum MeasurementKind: String, CaseIterable, Codable, Identifiable {
    case ph
    case sanitizer
    case alkalinity
    case hardness
    case temperature

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ph:
            return "pH"
        case .sanitizer:
            return "Sanitizer"
        case .alkalinity:
            return "Alkalinity"
        case .hardness:
            return "Hardness"
        case .temperature:
            return "Temperature"
        }
    }

    var defaultUnit: String {
        switch self {
        case .ph:
            return "pH"
        case .sanitizer:
            return "ppm"
        case .alkalinity:
            return "ppm"
        case .hardness:
            return "ppm"
        case .temperature:
            return "F"
        }
    }
}

enum FieldKind: String, CaseIterable, Codable, Identifiable {
    case notes
    case photo
    case ph
    case sanitizer
    case alkalinity
    case hardness
    case temperature

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notes:
            return "Notes"
        case .photo:
            return "Photo"
        case .ph:
            return "pH"
        case .sanitizer:
            return "Sanitizer"
        case .alkalinity:
            return "Alkalinity"
        case .hardness:
            return "Hardness"
        case .temperature:
            return "Temperature"
        }
    }

    var measurementKind: MeasurementKind? {
        switch self {
        case .ph:
            return .ph
        case .sanitizer:
            return .sanitizer
        case .alkalinity:
            return .alkalinity
        case .hardness:
            return .hardness
        case .temperature:
            return .temperature
        default:
            return nil
        }
    }

    var isMeasurement: Bool {
        measurementKind != nil
    }

    var defaultOrder: Int {
        switch self {
        case .notes:
            return 60
        case .photo:
            return 70
        case .ph:
            return 10
        case .sanitizer:
            return 20
        case .alkalinity:
            return 30
        case .hardness:
            return 40
        case .temperature:
            return 50
        }
    }
}

enum ReminderUnit: String, CaseIterable, Codable, Identifiable {
    case day
    case week
    case month

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        }
    }

    var secondsMultiplier: TimeInterval {
        switch self {
        case .day:
            return 86400
        case .week:
            return 604800
        case .month:
            return 2592000
        }
    }
}
