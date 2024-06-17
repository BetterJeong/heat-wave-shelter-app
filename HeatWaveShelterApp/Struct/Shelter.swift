import Foundation
import CoreLocation

struct Shelter {
    let title: String
    let address: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let type: String
    let capacity: Int
    let nightOpen: Bool
    let holidayOpen: Bool
    let lodgingAvailable: Bool
    let notes: String
}
