//
//  TrafficModels.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import Foundation

// MARK: - Road Traffic Models
struct RoadIncident: Identifiable, Codable {
    let id = UUID()
    let description: String
    let location: String
    let severity: String
    let startTime: Date?
    let expectedEndTime: Date?
    let roadNumber: String
    
    enum CodingKeys: String, CodingKey {
        case description, location, severity, startTime, expectedEndTime, roadNumber
    }
}

// MARK: - Train Models
struct TrainDelay: Identifiable, Codable, Hashable {
    let id = UUID()
    let trainNumber: String
    let route: String
    let station: String
    let scheduledTime: Date
    let actualTime: Date?
    let delayMinutes: Int
    let reason: String?
    
    enum CodingKeys: String, CodingKey {
        case trainNumber, route, station, scheduledTime, actualTime, delayMinutes, reason
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(trainNumber)
        hasher.combine(route)
        hasher.combine(station)
        hasher.combine(scheduledTime)
    }
    
    // Implement Equatable (required by Hashable)
    static func == (lhs: TrainDelay, rhs: TrainDelay) -> Bool {
        return lhs.trainNumber == rhs.trainNumber &&
               lhs.route == rhs.route &&
               lhs.station == rhs.station &&
               lhs.scheduledTime == rhs.scheduledTime
    }
}

struct TrainService: Identifiable, Codable {
    let id = UUID()
    let operatorName: String
    let route: String
    let status: ServiceStatus
    let delays: [TrainDelay]
    
    enum CodingKeys: String, CodingKey {
        case operatorName = "operator"
        case route, status, delays
    }
}

// MARK: - Bus Models
struct BusDelay: Identifiable, Codable {
    let id = UUID()
    let lineNumber: String
    let route: String
    let stop: String
    let scheduledTime: Date
    let actualTime: Date?
    let delayMinutes: Int
    let reason: String?
    
    enum CodingKeys: String, CodingKey {
        case lineNumber, route, stop, scheduledTime, actualTime, delayMinutes, reason
    }
}

struct BusService: Identifiable, Codable {
    let id = UUID()
    let operatorName: String
    let region: String
    let status: ServiceStatus
    let delays: [BusDelay]
    
    enum CodingKeys: String, CodingKey {
        case operatorName = "operator"
        case region, status, delays
    }
}

// MARK: - Common Models
enum ServiceStatus: String, CaseIterable, Codable {
    case normal = "Normal"
    case delayed = "Delayed"
    case disrupted = "Disrupted"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .normal: return "green"
        case .delayed: return "orange"
        case .disrupted: return "red"
        case .cancelled: return "red"
        }
    }
}

enum TransportType: String, CaseIterable {
    case road = "Road"
    case train = "Train"
    case bus = "Bus"
    
    var systemImage: String {
        switch self {
        case .road: return "car.fill"
        case .train: return "train.side.front.car"
        case .bus: return "bus.fill"
        }
    }
}

// MARK: - Combined Traffic Info
struct TrafficInfo {
    let roadIncidents: [RoadIncident]
    let trainServices: [TrainService]
    let busServices: [BusService]
    let lastUpdated: Date
}