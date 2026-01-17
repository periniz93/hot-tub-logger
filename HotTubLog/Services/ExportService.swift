import Foundation
import UIKit

enum ExportError: Error {
    case emptyEntries
    case writeFailed
    case invalidDirectory
}

enum ExportService {
    static func exportCSV(entries: [LogEntry]) throws -> URL {
        guard !entries.isEmpty else { throw ExportError.emptyEntries }

        let header = [
            "id",
            "type",
            "timestamp",
            "notes",
            "photoFilename",
            "pH",
            "sanitizer",
            "alkalinity",
            "hardness",
            "temperature"
        ]

        let formatter = ISO8601DateFormatter()
        var rows = [header.joined(separator: ",")]

        for entry in entries {
            let measurements = measurementValueMap(for: entry)
            let row: [String] = [
                entry.id.uuidString,
                entry.entryType?.name ?? "",
                formatter.string(from: entry.timestamp),
                entry.notes,
                entry.photoFilename ?? "",
                measurements[.ph] ?? "",
                measurements[.sanitizer] ?? "",
                measurements[.alkalinity] ?? "",
                measurements[.hardness] ?? "",
                measurements[.temperature] ?? ""
            ]
            rows.append(row.map { $0.csvEscaped }.joined(separator: ","))
        }

        let csv = rows.joined(separator: "\n")
        let url = try exportURL(filename: "hottub_log_\(timestampString()).csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            throw ExportError.writeFailed
        }
    }

    static func exportPDF(entries: [LogEntry]) throws -> URL {
        guard !entries.isEmpty else { throw ExportError.emptyEntries }

        let url = try exportURL(filename: "hottub_summary_\(timestampString()).pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))

        do {
            try renderer.writePDF(to: url, withActions: { context in
                var y: CGFloat = 40
                let pageWidth: CGFloat = 612
                let leftMargin: CGFloat = 40
                let rightMargin: CGFloat = 40
                let maxY: CGFloat = 760

                func beginPage() {
                    context.beginPage()
                    y = 40
                }

                func drawText(_ text: String, font: UIFont, yOffset: CGFloat = 0) {
                    let attributes: [NSAttributedString.Key: Any] = [.font: font]
                    let size = text.size(withAttributes: attributes)
                    let rect = CGRect(x: leftMargin, y: y + yOffset, width: pageWidth - leftMargin - rightMargin, height: size.height)
                    text.draw(in: rect, withAttributes: attributes)
                    y += size.height + 6
                }

                beginPage()

                drawText("Hot Tub Maintenance Summary", font: UIFont.boldSystemFont(ofSize: 20))
                drawText("Entries: \(entries.count)", font: UIFont.systemFont(ofSize: 12))

                let counts = Dictionary(grouping: entries) { $0.entryType?.name ?? "Unknown" }
                    .mapValues { $0.count }
                for (type, count) in counts.sorted(by: { $0.key < $1.key }) {
                    drawText("\(type): \(count)", font: UIFont.systemFont(ofSize: 12))
                }

                y += 10

                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short

                for entry in entries.sorted(by: { $0.timestamp > $1.timestamp }) {
                    if y > maxY {
                        beginPage()
                    }

                    let title = "\(entry.entryType?.name ?? "Entry") - \(dateFormatter.string(from: entry.timestamp))"
                    drawText(title, font: UIFont.boldSystemFont(ofSize: 13))

                    if !entry.notes.isEmpty {
                        drawText(entry.notes, font: UIFont.systemFont(ofSize: 11))
                    }

                    let measurements = measurementDisplayMap(for: entry)
                    let measurementLine = measurementSummary(from: measurements)
                    if !measurementLine.isEmpty {
                        drawText(measurementLine, font: UIFont.systemFont(ofSize: 11))
                    }

                    if let filename = entry.photoFilename, let image = PhotoStore.load(filename: filename) {
                        let thumbnailSize: CGFloat = 60
                        let imageRect = CGRect(x: pageWidth - rightMargin - thumbnailSize, y: y - 54, width: thumbnailSize, height: thumbnailSize)
                        image.draw(in: imageRect)
                    }

                    y += 8
                }
            })
        } catch {
            throw ExportError.writeFailed
        }

        return url
    }

    private static func measurementValueMap(for entry: LogEntry) -> [MeasurementKind: String] {
        var map: [MeasurementKind: String] = [:]
        for measurement in entry.measurements {
            let value = String(format: "%.2f", measurement.value)
            map[measurement.kind] = value
        }
        return map
    }

    private static func measurementDisplayMap(for entry: LogEntry) -> [MeasurementKind: String] {
        var map: [MeasurementKind: String] = [:]
        for measurement in entry.measurements {
            let value = String(format: "%.2f", measurement.value)
            map[measurement.kind] = "\(value) \(measurement.unit)"
        }
        return map
    }

    private static func measurementSummary(from map: [MeasurementKind: String]) -> String {
        let parts = MeasurementKind.allCases.compactMap { kind -> String? in
            guard let value = map[kind] else { return nil }
            return "\(kind.displayName): \(value)"
        }
        return parts.joined(separator: ", ")
    }

    private static func exportURL(filename: String) throws -> URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.invalidDirectory
        }
        let directory = documents.appendingPathComponent("Exports")
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory.appendingPathComponent(filename)
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: Date())
    }
}

private extension String {
    var csvEscaped: String {
        if contains(",") || contains("\"") || contains("\n") {
            let escaped = replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return self
    }
}
