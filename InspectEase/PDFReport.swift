//
//  PDFReport.swift
//  InspectEase
//
//  A4 inspection report, ported from PdfReportGenerator in the Android app.
//

import UIKit

enum PDFReport {
    private static let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)

    static func generate(for inspection: SavedInspection) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("InspectEase_Report_\(inspection.timestamp).pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        try renderer.writePDF(to: url) { context in
            context.beginPage()

            var y: CGFloat = 60
            draw(
                "InspectEase - Inspection Report",
                font: .boldSystemFont(ofSize: 26),
                color: UIColor(red: 1, green: 0.42, blue: 0.42, alpha: 1),
                at: CGPoint(x: 50, y: y)
            )
            y += 50

            let fields: [(label: String, value: String)] = [
                ("Address:", inspection.address.isEmpty ? "N/A" : inspection.address),
                ("Inspector:", inspection.inspectorName.isEmpty ? "N/A" : inspection.inspectorName),
                ("Date:", inspection.date.isEmpty ? "N/A" : inspection.date),
                ("Notes:", inspection.notes.isEmpty ? "No notes" : inspection.notes),
                ("Rating:", "\(inspection.rating)/5"),
            ]

            for field in fields {
                draw(field.label, font: .boldSystemFont(ofSize: 14), at: CGPoint(x: 50, y: y))
                y += 22

                if field.label == "Notes:" {
                    for line in chunks(field.value, size: 70) {
                        draw(line, font: .systemFont(ofSize: 14), at: CGPoint(x: 60, y: y))
                        y += 20
                    }
                } else {
                    draw(field.value, font: .systemFont(ofSize: 14), at: CGPoint(x: 60, y: y))
                    y += 35
                }
            }

            if !inspection.selectedIssues.isEmpty {
                y += 10
                draw("Issues Found:", font: .boldSystemFont(ofSize: 14), at: CGPoint(x: 50, y: y))
                y += 25
                for issue in inspection.selectedIssues {
                    draw("• \(issue)", font: .systemFont(ofSize: 14), at: CGPoint(x: 60, y: y))
                    y += 20
                }
            }
        }

        return url
    }

    private static func draw(
        _ text: String,
        font: UIFont,
        color: UIColor = .black,
        at point: CGPoint
    ) {
        (text as NSString).draw(at: point, withAttributes: [.font: font, .foregroundColor: color])
    }

    private static func chunks(_ text: String, size: Int) -> [String] {
        let characters = Array(text)
        return stride(from: 0, to: characters.count, by: size).map { start in
            String(characters[start..<min(start + size, characters.count)])
        }
    }
}
