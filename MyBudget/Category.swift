import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable {
    case food = "საკვები"
    case transport = "ტრანსპორტი"
    case entertainment = "გართობა"
    case other = "სხვა"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .food:
            return "fork.knife"
        case .transport:
            return "bus.fill"
        case .entertainment:
            return "film.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}