import Foundation

struct ChantSession: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let count: Int
}
