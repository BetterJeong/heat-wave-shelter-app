import Foundation
import CoreLocation

struct Shelter: Codable {
    let title: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: String
    let capacity: Int
    let nightOpen: Bool
    let holidayOpen: Bool
    let lodgingAvailable: Bool
    let notes: String
    var isFavorite: Bool = false
}
