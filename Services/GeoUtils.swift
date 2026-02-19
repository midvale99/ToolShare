import CoreLocation

struct GeoPoint {
    let latitude: Double
    let longitude: Double
}

func distanceInMeters(from: GeoPoint, to: GeoPoint) -> Double {
    let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
    return loc1.distance(from: loc2)
}

func isWithinRadius(user: GeoPoint, listing: GeoPoint, radiusMeters: Double = 200.0) -> Bool {
    distanceInMeters(from: user, to: listing) <= radiusMeters
}

