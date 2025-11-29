//
//  NSTripsService.swift
//  schedule2
//
//  Created by Claude Assistant on 29/11/2025.
//

import Foundation
import SwiftUI

// MARK: - NS Trips API Response Models

struct NSTripsResponse: Codable {
    let trips: [NSTrip]
}

struct NSTrip: Codable {
    let uid: String?
    let plannedDurationInMinutes: Int?
    let actualDurationInMinutes: Int?
    let transfers: Int?
    let status: String?
    let primaryMessage: NSMessage?
    let legs: [NSLeg]
    let fareRoute: NSFareRoute?
    let fares: [NSFare]?
    let productFare: NSProductFare?
    let crowdForecast: String?
    let optimal: Bool?

    enum CodingKeys: String, CodingKey {
        case uid, plannedDurationInMinutes, actualDurationInMinutes, transfers, status
        case primaryMessage, legs, fareRoute, fares, productFare, crowdForecast, optimal
    }
}

struct NSMessage: Codable {
    let title: String?
    let nesColor: NSColor?
    let type: String?
    let text: String?
}

struct NSColor: Codable {
    let r: Int?
    let g: Int?
    let b: Int?
}

struct NSLeg: Codable {
    let idx: String?
    let name: String?
    let travelType: String?
    let direction: String?
    let cancelled: Bool?
    let changePossible: Bool?
    let alternativeTransport: Bool?
    let journeyDetailRef: String?
    let origin: NSStop
    let destination: NSStop
    let product: NSProduct?
    let messages: [NSLegMessage]?
    let stops: [NSIntermediateStop]?
    let crowdForecast: String?
    let punctuality: Double?
    let shorterStock: Bool?
    let journeyDetail: [NSJourneyDetail]?
    let reachable: Bool?
    let plannedDurationInMinutes: Int?
    let transferMessages: [NSTransferMessage]?
    let notes: [NSNote]?

    enum CodingKeys: String, CodingKey {
        case idx, name, travelType, direction, cancelled, changePossible, alternativeTransport
        case journeyDetailRef, origin, destination, product, messages, stops, crowdForecast
        case punctuality, shorterStock, journeyDetail, reachable, plannedDurationInMinutes
        case transferMessages, notes
    }
}

struct NSStop: Codable {
    let name: String?
    let lng: Double?
    let lat: Double?
    let countryCode: String?
    let uicCode: String?
    let stationCode: String?
    let type: String?
    let plannedDateTime: String?
    let actualDateTime: String?
    let plannedTimeZoneOffset: Int?
    let actualTimeZoneOffset: Int?
    let plannedTrack: String?
    let actualTrack: String?
    let exitSide: String?
    let checkinStatus: String?
    let notes: [NSNote]?
}

struct NSProduct: Codable {
    let number: String?
    let categoryCode: String?
    let shortCategoryName: String?
    let longCategoryName: String?
    let operatorCode: String?
    let operatorName: String?
    let type: String?
    let displayName: String?
}

struct NSLegMessage: Codable {
    let id: String?
    let externalId: String?
    let head: String?
    let text: String?
    let lead: String?
    let routeIdxFrom: Int?
    let routeIdxTo: Int?
    let type: String?
    let nesColor: NSColor?
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
}

struct NSIntermediateStop: Codable {
    let uicCode: String?
    let name: String?
    let lat: Double?
    let lng: Double?
    let countryCode: String?
    let notes: [NSNote]?
    let routeIdx: Int?
    let plannedDepartureDateTime: String?
    let actualDepartureDateTime: String?
    let plannedArrivalDateTime: String?
    let actualArrivalDateTime: String?
    let cancelled: Bool?
    let plannedDepartureTrack: String?
    let actualDepartureTrack: String?
    let plannedArrivalTrack: String?
    let actualArrivalTrack: String?
    let departureDelayInSeconds: Int?
    let arrivalDelayInSeconds: Int?
    let quayCode: String?
}

struct NSJourneyDetail: Codable {
    let type: String?
    let link: NSLink?
}

struct NSLink: Codable {
    let uri: String?
}

struct NSTransferMessage: Codable {
    let message: String?
    let accessibilityMessage: String?
}

struct NSNote: Codable {
    let value: String?
    let key: String?
    let noteType: String?
    let priority: Int?
    let routeIdxFrom: Int?
    let routeIdxTo: Int?
    let link: NSNoteLink?
    let isPresentationRequired: Bool?
    let category: String?
}

struct NSNoteLink: Codable {
    let title: String?
    let url: String?
}

struct NSFareRoute: Codable {
    let routeId: String?
    let origin: NSFareStop?
    let destination: NSFareStop?
}

struct NSFareStop: Codable {
    let varCode: Int?
    let name: String?
}

struct NSFare: Codable {
    let priceInCents: Int?
    let product: String?
    let travelClass: String?
    let discountType: String?
}

struct NSProductFare: Codable {
    let priceInCents: Int?
    let priceInCentsExcludingSupplement: Int?
    let supplementInCents: Int?
    let buyableTicketPriceInCents: Int?
    let buyableTicketPriceInCentsExcludingSupplement: Int?
    let buyableTicketSupplementPriceInCents: Int?
    let product: String?
    let travelClass: String?
    let discountType: String?
}

// MARK: - Live Trip Result Models

struct LiveTripResult: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let departureTime: Date
    let arrivalTime: Date
    let durationMinutes: Int
    let transfers: Int
    let priceInCents: Int?
    let status: TripStatus
    let legs: [LiveTripLeg]
    let crowdForecast: String?
    let isOptimal: Bool
    let warnings: [String]

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let mins = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins) min"
    }

    var formattedPrice: String {
        guard let cents = priceInCents else { return "Price unavailable" }
        let euros = Double(cents) / 100.0
        return String(format: "€%.2f", euros)
    }
}

struct LiveTripLeg: Identifiable {
    let id = UUID()
    let mode: TripTransportMode
    let lineName: String
    let lineNumber: String?
    let operatorName: String?
    let direction: String?
    let fromStation: String
    let toStation: String
    let departureTime: Date
    let arrivalTime: Date
    let plannedDepartureTrack: String?
    let actualDepartureTrack: String?
    let plannedArrivalTrack: String?
    let actualArrivalTrack: String?
    let durationMinutes: Int
    let delayMinutes: Int
    let isCancelled: Bool
    let crowdForecast: String?
    let intermediateStops: [String]
    let messages: [String]

    var hasDelay: Bool {
        delayMinutes > 0
    }

    var trackChanged: Bool {
        if let planned = plannedDepartureTrack, let actual = actualDepartureTrack {
            return planned != actual
        }
        return false
    }
}

enum TripStatus: String {
    case normal = "NORMAL"
    case delayed = "DELAYED"
    case cancelled = "CANCELLED"
    case alternative = "ALTERNATIVE"
    case disruption = "DISRUPTION"

    var color: Color {
        switch self {
        case .normal: return .green
        case .delayed: return .orange
        case .cancelled: return .red
        case .alternative: return .blue
        case .disruption: return .red
        }
    }

    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .delayed: return "clock.fill"
        case .cancelled: return "xmark.circle.fill"
        case .alternative: return "arrow.triangle.branch"
        case .disruption: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - NS Trips Service

@MainActor
class NSTripsService: ObservableObject {
    @Published var tripOptions: [LiveTripResult] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var isUsingLiveData = false

    private let session = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()

    private var nsAPIKey: String {
        let userKey = UserDefaults.standard.string(forKey: "nsAPIKey") ?? ""
        // Use hardcoded key as fallback if user hasn't set one
        return userKey.isEmpty ? "24580b0cd78f49d489cea30d58fb2150" : userKey
    }

    // MARK: - Fetch Live Trips

    func fetchTrips(from: String, to: String, dateTime: Date, transportMode: TripTransportMode = .train, isArrival: Bool = false) async {
        isLoading = true
        error = nil
        tripOptions = []
        isUsingLiveData = false

        // Convert location names to station codes
        let fromStation = convertToStationCode(from)
        let toStation = convertToStationCode(to)

        let modeEmoji = transportMode == .train ? "🚆" : (transportMode == .bus ? "🚌" : "🚇")
        print("\(modeEmoji) Fetching live \(transportMode.displayName) trips from \(fromStation) to \(toStation)")

        // Format the datetime for API
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let dateTimeString = formatter.string(from: dateTime)

        // Build the URL with transport mode filters
        var urlComponents = URLComponents(string: "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v3/trips")!
        var queryItems = [
            URLQueryItem(name: "fromStation", value: fromStation),
            URLQueryItem(name: "toStation", value: toStation),
            URLQueryItem(name: "dateTime", value: dateTimeString),
            URLQueryItem(name: "searchForArrival", value: isArrival ? "true" : "false")
        ]

        // Add transport mode specific filters
        // NS API supports product filtering to include different transport types
        switch transportMode {
        case .train:
            // Only train services
            queryItems.append(URLQueryItem(name: "product", value: "TRAIN"))
        case .bus:
            // Bus only - but NS API focuses on trains, so we'll include bus connections
            queryItems.append(URLQueryItem(name: "product", value: "BUS"))
            // Also try with all products as bus-only may not return results
            queryItems.append(URLQueryItem(name: "travelAssistanceTransferTime", value: "0"))
        case .mixed:
            // All transport types - train, bus, metro, tram, ferry
            // Don't filter - get all options including bus, tram, metro connections
            queryItems.append(URLQueryItem(name: "travelAssistanceTransferTime", value: "0"))
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            error = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(nsAPIKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        print("🌐 Making request to: \(url)")

        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    let trips = try parseTripsResponse(data: data, from: from, to: to, transportMode: transportMode)
                    tripOptions = trips
                    isUsingLiveData = true
                    print("✅ Successfully fetched \(trips.count) live trip options")
                } else {
                    // Log the error response
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    print("❌ API Error: \(responseString)")

                    // Fall back to demo data
                    tripOptions = createDemoTrips(from: from, to: to, dateTime: dateTime, transportMode: transportMode)
                    error = "Using demo data (API returned status \(httpResponse.statusCode))"
                }
            }
        } catch {
            print("❌ Network error: \(error)")
            self.error = "Network error: \(error.localizedDescription)"

            // Fall back to demo data
            tripOptions = createDemoTrips(from: from, to: to, dateTime: dateTime, transportMode: transportMode)
        }

        isLoading = false
    }

    // MARK: - Parse Response

    private func parseTripsResponse(data: Data, from: String, to: String, transportMode: TripTransportMode = .train) throws -> [LiveTripResult] {
        var results: [LiveTripResult] = []

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let trips = json["trips"] as? [[String: Any]] {

                print("📋 Parsing \(trips.count) trips")

                for tripData in trips.prefix(5) { // Show top 5 options
                    if let trip = parseSingleTrip(tripData: tripData, from: from, to: to) {
                        results.append(trip)
                    }
                }
            }
        } catch {
            print("❌ JSON parsing error: \(error)")
            throw error
        }

        return results
    }

    private func parseSingleTrip(tripData: [String: Any], from: String, to: String) -> LiveTripResult? {
        guard let legsData = tripData["legs"] as? [[String: Any]], !legsData.isEmpty else {
            return nil
        }

        // Parse basic trip info
        let durationMinutes = tripData["actualDurationInMinutes"] as? Int
            ?? tripData["plannedDurationInMinutes"] as? Int
            ?? 0
        let transfers = tripData["transfers"] as? Int ?? 0
        let isOptimal = tripData["optimal"] as? Bool ?? false
        let crowdForecast = tripData["crowdForecast"] as? String
        let statusString = tripData["status"] as? String ?? "NORMAL"

        // Parse fare info
        var priceInCents: Int? = nil
        if let productFare = tripData["productFare"] as? [String: Any] {
            priceInCents = productFare["priceInCents"] as? Int
        } else if let fares = tripData["fares"] as? [[String: Any]], let firstFare = fares.first {
            priceInCents = firstFare["priceInCents"] as? Int
        }

        // Parse legs
        var legs: [LiveTripLeg] = []
        var departureTime: Date?
        var arrivalTime: Date?
        var warnings: [String] = []
        var hasDelay = false
        var isCancelled = false

        for legData in legsData {
            if let leg = parseLeg(legData: legData) {
                legs.append(leg)

                if departureTime == nil {
                    departureTime = leg.departureTime
                }
                arrivalTime = leg.arrivalTime

                if leg.hasDelay {
                    hasDelay = true
                }
                if leg.isCancelled {
                    isCancelled = true
                }

                // Collect warnings from leg messages
                warnings.append(contentsOf: leg.messages)
            }
        }

        guard let depTime = departureTime, let arrTime = arrivalTime else {
            return nil
        }

        // Determine status
        var status: TripStatus = .normal
        if isCancelled {
            status = .cancelled
        } else if hasDelay {
            status = .delayed
        } else if statusString == "ALTERNATIVE" {
            status = .alternative
        }

        // Check for primary message warnings
        if let primaryMessage = tripData["primaryMessage"] as? [String: Any],
           let text = primaryMessage["text"] as? String {
            warnings.insert(text, at: 0)
            if text.lowercased().contains("disruption") || text.lowercased().contains("cancel") {
                status = .disruption
            }
        }

        return LiveTripResult(
            from: from,
            to: to,
            departureTime: depTime,
            arrivalTime: arrTime,
            durationMinutes: durationMinutes,
            transfers: transfers,
            priceInCents: priceInCents,
            status: status,
            legs: legs,
            crowdForecast: crowdForecast,
            isOptimal: isOptimal,
            warnings: Array(Set(warnings)) // Remove duplicates
        )
    }

    private func parseLeg(legData: [String: Any]) -> LiveTripLeg? {
        guard let origin = legData["origin"] as? [String: Any],
              let destination = legData["destination"] as? [String: Any] else {
            return nil
        }

        let fromStation = origin["name"] as? String ?? "Unknown"
        let toStation = destination["name"] as? String ?? "Unknown"

        // Parse times
        let plannedDeparture = origin["plannedDateTime"] as? String
        let actualDeparture = origin["actualDateTime"] as? String ?? plannedDeparture
        let plannedArrival = destination["plannedDateTime"] as? String
        let actualArrival = destination["actualDateTime"] as? String ?? plannedArrival

        guard let depTimeStr = actualDeparture,
              let arrTimeStr = actualArrival,
              let depTime = dateFormatter.date(from: depTimeStr),
              let arrTime = dateFormatter.date(from: arrTimeStr) else {
            return nil
        }

        // Calculate delay
        var delayMinutes = 0
        if let plannedStr = plannedDeparture,
           let plannedTime = dateFormatter.date(from: plannedStr) {
            delayMinutes = Int(depTime.timeIntervalSince(plannedTime) / 60)
        }

        // Parse product info
        var lineName = legData["name"] as? String ?? "Unknown"
        var lineNumber: String? = nil
        var operatorName: String? = nil
        var mode: TripTransportMode = .train

        if let product = legData["product"] as? [String: Any] {
            lineNumber = product["number"] as? String
            operatorName = product["operatorName"] as? String
            let categoryCode = (product["categoryCode"] as? String ?? "").uppercased()
            let productType = (product["type"] as? String ?? "").uppercased()
            let shortName = (product["shortCategoryName"] as? String ?? "").uppercased()
            lineName = product["displayName"] as? String ?? product["longCategoryName"] as? String ?? lineName

            // Determine mode based on category code and product type
            // NS API uses various codes: IC, SPR, IC Direct, BUS, METRO, TRAM, FERRY, etc.
            if categoryCode.contains("BUS") || productType.contains("BUS") || shortName.contains("BUS") {
                mode = .bus
                lineName = "Bus \(lineNumber ?? "")"
            } else if categoryCode.contains("METRO") || productType.contains("METRO") || shortName.contains("METRO") {
                mode = .mixed
                lineName = "Metro \(lineNumber ?? "")"
            } else if categoryCode.contains("TRAM") || productType.contains("TRAM") || shortName.contains("TRAM") {
                mode = .mixed
                lineName = "Tram \(lineNumber ?? "")"
            } else if categoryCode.contains("FERRY") || productType.contains("FERRY") || shortName.contains("FERRY") {
                mode = .mixed
                lineName = "Ferry"
            } else if categoryCode.contains("WALK") || productType.contains("WALK") {
                mode = .mixed
                lineName = "Walk"
            } else {
                // Default to train for IC, SPR, IC Direct, etc.
                mode = .train
            }
        }

        // Check travel type for walking segments
        let travelType = legData["travelType"] as? String ?? ""
        if travelType.uppercased() == "WALK" {
            lineName = "Walk"
            mode = .mixed
        } else if travelType.uppercased() == "TRANSFER" {
            lineName = "Transfer"
            mode = .mixed
        }

        let direction = legData["direction"] as? String
        let isCancelled = legData["cancelled"] as? Bool ?? false
        let crowdForecast = legData["crowdForecast"] as? String
        let durationMinutes = legData["plannedDurationInMinutes"] as? Int ?? Int(arrTime.timeIntervalSince(depTime) / 60)

        // Parse tracks
        let plannedDepartureTrack = origin["plannedTrack"] as? String
        let actualDepartureTrack = origin["actualTrack"] as? String
        let plannedArrivalTrack = destination["plannedTrack"] as? String
        let actualArrivalTrack = destination["actualTrack"] as? String

        // Parse intermediate stops
        var intermediateStops: [String] = []
        if let stops = legData["stops"] as? [[String: Any]] {
            intermediateStops = stops.compactMap { $0["name"] as? String }
        }

        // Parse messages
        var messages: [String] = []
        if let legMessages = legData["messages"] as? [[String: Any]] {
            for msg in legMessages {
                if let text = msg["text"] as? String {
                    messages.append(text)
                }
            }
        }
        if let notes = legData["notes"] as? [[String: Any]] {
            for note in notes {
                if let value = note["value"] as? String {
                    messages.append(value)
                }
            }
        }

        return LiveTripLeg(
            mode: mode,
            lineName: lineName,
            lineNumber: lineNumber,
            operatorName: operatorName,
            direction: direction,
            fromStation: fromStation,
            toStation: toStation,
            departureTime: depTime,
            arrivalTime: arrTime,
            plannedDepartureTrack: plannedDepartureTrack,
            actualDepartureTrack: actualDepartureTrack,
            plannedArrivalTrack: plannedArrivalTrack,
            actualArrivalTrack: actualArrivalTrack,
            durationMinutes: durationMinutes,
            delayMinutes: max(0, delayMinutes),
            isCancelled: isCancelled,
            crowdForecast: crowdForecast,
            intermediateStops: intermediateStops,
            messages: messages
        )
    }

    // MARK: - Station Code Conversion

    private func convertToStationCode(_ location: String) -> String {
        let stationMappings: [String: String] = [
            // Major stations
            "amsterdam centraal": "ASD",
            "amsterdam": "ASD",
            "utrecht centraal": "UT",
            "utrecht": "UT",
            "rotterdam centraal": "RTD",
            "rotterdam": "RTD",
            "den haag centraal": "GVC",
            "den haag": "GVC",
            "the hague": "GVC",
            "eindhoven centraal": "EHV",
            "eindhoven": "EHV",
            "groningen": "GN",
            "zwolle": "ZL",
            "tilburg": "TBG",
            "breda": "BD",
            "amersfoort": "AMF",
            "haarlem": "HLM",
            "lelystad": "LEW",
            "maastricht": "MT",
            "venlo": "VL",
            "assen": "ASN",
            "almere centrum": "ALMR",
            "almere": "ALMR",
            "delft": "DT",
            "leiden centraal": "LEDN",
            "leiden": "LEDN",
            "hilversum": "HVS",
            "deventer": "DV",
            "schiphol airport": "SHL",
            "schiphol": "SHL",
            "amsterdam airport": "SHL",
            "nijmegen": "NM",
            "arnhem centraal": "AH",
            "arnhem": "AH",
            "dordrecht": "DDR",
            "alkmaar": "AMR",
            "apeldoorn": "APD",
            "enschede": "ES",
            "leeuwarden": "LW",
            "heerlen": "HRL",
            "sittard": "STD",
            "roermond": "RM",
            "gouda": "GD",
            "zaandam": "ZD",
            "hoorn": "HN",
            "den bosch": "HT",
            "'s-hertogenbosch": "HT",
            "hertogenbosch": "HT"
        ]

        let normalized = location.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Direct lookup
        if let code = stationMappings[normalized] {
            return code
        }

        // Partial match
        for (name, code) in stationMappings {
            if normalized.contains(name) || name.contains(normalized) {
                return code
            }
        }

        // If no match found, return as-is (API might accept full names)
        return location
    }

    // MARK: - Demo Data Fallback

    private func createDemoTrips(from: String, to: String, dateTime: Date, transportMode: TripTransportMode = .train) -> [LiveTripResult] {
        print("📋 Creating demo \(transportMode.displayName) trip data as fallback")

        let baseDuration = calculateEstimatedDuration(from: from, to: to)
        let basePrice = calculateEstimatedPrice(from: from, to: to)

        switch transportMode {
        case .train:
            return createTrainDemoTrips(from: from, to: to, dateTime: dateTime, baseDuration: baseDuration, basePrice: basePrice)
        case .bus:
            return createBusDemoTrips(from: from, to: to, dateTime: dateTime, baseDuration: baseDuration, basePrice: basePrice)
        case .mixed:
            return createMixedDemoTrips(from: from, to: to, dateTime: dateTime, baseDuration: baseDuration, basePrice: basePrice)
        }
    }

    private func createTrainDemoTrips(from: String, to: String, dateTime: Date, baseDuration: Int, basePrice: Int) -> [LiveTripResult] {
        return [
            // Option 1: Direct/fastest
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime,
                arrivalTime: dateTime.addingTimeInterval(Double(baseDuration) * 60),
                durationMinutes: baseDuration,
                transfers: 0,
                priceInCents: basePrice,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Intercity Direct",
                        lineNumber: "IC \(Int.random(in: 1000...9999))",
                        operatorName: "NS",
                        direction: to,
                        fromStation: from,
                        toStation: to,
                        departureTime: dateTime,
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "LOW",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "LOW",
                isOptimal: true,
                warnings: ["Demo data - configure NS API key for live results"]
            ),
            // Option 2: With transfer
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime.addingTimeInterval(15 * 60),
                arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 20) * 60),
                durationMinutes: baseDuration + 20,
                transfers: 1,
                priceInCents: basePrice - 100,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Sprinter",
                        lineNumber: "SPR \(Int.random(in: 5000...9999))",
                        operatorName: "NS",
                        direction: "Utrecht Centraal",
                        fromStation: from,
                        toStation: "Utrecht Centraal",
                        departureTime: dateTime.addingTimeInterval(15 * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration / 2 + 15) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration / 2,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    ),
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Intercity",
                        lineNumber: "IC \(Int.random(in: 1000...9999))",
                        operatorName: "NS",
                        direction: to,
                        fromStation: "Utrecht Centraal",
                        toStation: to,
                        departureTime: dateTime.addingTimeInterval(Double(baseDuration / 2 + 20) * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 20) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration / 2,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "MEDIUM",
                isOptimal: false,
                warnings: ["Demo data - configure NS API key for live results"]
            )
        ]
    }

    private func createBusDemoTrips(from: String, to: String, dateTime: Date, baseDuration: Int, basePrice: Int) -> [LiveTripResult] {
        let busDuration = Int(Double(baseDuration) * 1.3) // Buses are typically 30% slower
        let busPrice = Int(Double(basePrice) * 0.7) // Buses are typically 30% cheaper

        return [
            // Option 1: Direct bus
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime,
                arrivalTime: dateTime.addingTimeInterval(Double(busDuration) * 60),
                durationMinutes: busDuration,
                transfers: 0,
                priceInCents: busPrice,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .bus,
                        lineName: "Bus \(Int.random(in: 100...999))",
                        lineNumber: "\(Int.random(in: 100...999))",
                        operatorName: "GVB",
                        direction: to,
                        fromStation: from,
                        toStation: to,
                        departureTime: dateTime,
                        arrivalTime: dateTime.addingTimeInterval(Double(busDuration) * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: busDuration,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "MEDIUM",
                isOptimal: true,
                warnings: ["Demo data - configure NS API key for live results"]
            ),
            // Option 2: Bus with transfer
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime.addingTimeInterval(10 * 60),
                arrivalTime: dateTime.addingTimeInterval(Double(busDuration + 25) * 60),
                durationMinutes: busDuration + 25,
                transfers: 1,
                priceInCents: busPrice,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .bus,
                        lineName: "Bus \(Int.random(in: 100...999))",
                        lineNumber: "\(Int.random(in: 100...999))",
                        operatorName: "Connexxion",
                        direction: "Station",
                        fromStation: from,
                        toStation: "Central Station",
                        departureTime: dateTime.addingTimeInterval(10 * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(busDuration / 2 + 10) * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: busDuration / 2,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    ),
                    LiveTripLeg(
                        mode: .bus,
                        lineName: "Bus \(Int.random(in: 100...999))",
                        lineNumber: "\(Int.random(in: 100...999))",
                        operatorName: "Arriva",
                        direction: to,
                        fromStation: "Central Station",
                        toStation: to,
                        departureTime: dateTime.addingTimeInterval(Double(busDuration / 2 + 20) * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(busDuration + 25) * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: busDuration / 2 + 5,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "LOW",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "MEDIUM",
                isOptimal: false,
                warnings: ["Demo data - configure NS API key for live results"]
            )
        ]
    }

    private func createMixedDemoTrips(from: String, to: String, dateTime: Date, baseDuration: Int, basePrice: Int) -> [LiveTripResult] {
        return [
            // Option 1: Train + Metro
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime,
                arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 10) * 60),
                durationMinutes: baseDuration + 10,
                transfers: 1,
                priceInCents: basePrice,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Intercity",
                        lineNumber: "IC \(Int.random(in: 1000...9999))",
                        operatorName: "NS",
                        direction: "Amsterdam Centraal",
                        fromStation: from,
                        toStation: "Amsterdam Centraal",
                        departureTime: dateTime,
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    ),
                    LiveTripLeg(
                        mode: .mixed,
                        lineName: "Metro 52",
                        lineNumber: "52",
                        operatorName: "GVB",
                        direction: to,
                        fromStation: "Amsterdam Centraal",
                        toStation: to,
                        departureTime: dateTime.addingTimeInterval(Double(baseDuration + 3) * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 10) * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: 7,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "LOW",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "MEDIUM",
                isOptimal: true,
                warnings: ["Demo data - configure NS API key for live results"]
            ),
            // Option 2: Bus + Train + Tram
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime.addingTimeInterval(5 * 60),
                arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 25) * 60),
                durationMinutes: baseDuration + 25,
                transfers: 2,
                priceInCents: basePrice - 50,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .bus,
                        lineName: "Bus \(Int.random(in: 100...999))",
                        lineNumber: "\(Int.random(in: 100...999))",
                        operatorName: "Connexxion",
                        direction: "Station",
                        fromStation: from,
                        toStation: "Local Station",
                        departureTime: dateTime.addingTimeInterval(5 * 60),
                        arrivalTime: dateTime.addingTimeInterval(15 * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: 10,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "LOW",
                        intermediateStops: [],
                        messages: []
                    ),
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Sprinter",
                        lineNumber: "SPR \(Int.random(in: 5000...9999))",
                        operatorName: "NS",
                        direction: "Rotterdam Centraal",
                        fromStation: "Local Station",
                        toStation: "Rotterdam Centraal",
                        departureTime: dateTime.addingTimeInterval(20 * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 10) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration - 10,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    ),
                    LiveTripLeg(
                        mode: .mixed,
                        lineName: "Tram 25",
                        lineNumber: "25",
                        operatorName: "RET",
                        direction: to,
                        fromStation: "Rotterdam Centraal",
                        toStation: to,
                        departureTime: dateTime.addingTimeInterval(Double(baseDuration + 15) * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 25) * 60),
                        plannedDepartureTrack: nil,
                        actualDepartureTrack: nil,
                        plannedArrivalTrack: nil,
                        actualArrivalTrack: nil,
                        durationMinutes: 10,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "MEDIUM",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "MEDIUM",
                isOptimal: false,
                warnings: ["Demo data - configure NS API key for live results"]
            ),
            // Option 3: Train only (direct)
            LiveTripResult(
                from: from,
                to: to,
                departureTime: dateTime.addingTimeInterval(20 * 60),
                arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 20) * 60),
                durationMinutes: baseDuration,
                transfers: 0,
                priceInCents: basePrice,
                status: .normal,
                legs: [
                    LiveTripLeg(
                        mode: .train,
                        lineName: "Intercity Direct",
                        lineNumber: "IC \(Int.random(in: 1000...9999))",
                        operatorName: "NS",
                        direction: to,
                        fromStation: from,
                        toStation: to,
                        departureTime: dateTime.addingTimeInterval(20 * 60),
                        arrivalTime: dateTime.addingTimeInterval(Double(baseDuration + 20) * 60),
                        plannedDepartureTrack: "\(Int.random(in: 1...15))",
                        actualDepartureTrack: "\(Int.random(in: 1...15))",
                        plannedArrivalTrack: "\(Int.random(in: 1...15))",
                        actualArrivalTrack: "\(Int.random(in: 1...15))",
                        durationMinutes: baseDuration,
                        delayMinutes: 0,
                        isCancelled: false,
                        crowdForecast: "LOW",
                        intermediateStops: [],
                        messages: []
                    )
                ],
                crowdForecast: "LOW",
                isOptimal: false,
                warnings: ["Demo data - configure NS API key for live results"]
            )
        ]
    }

    private func calculateEstimatedDuration(from: String, to: String) -> Int {
        // Rough estimates based on common routes
        let routeDurations: [String: Int] = [
            "amsterdam-utrecht": 27,
            "amsterdam-rotterdam": 40,
            "amsterdam-den haag": 50,
            "amsterdam-eindhoven": 75,
            "amsterdam-schiphol": 15,
            "utrecht-rotterdam": 35,
            "utrecht-den haag": 40,
            "rotterdam-den haag": 25,
            "default": 45
        ]

        let fromLower = from.lowercased()
        let toLower = to.lowercased()

        for (route, duration) in routeDurations {
            let cities = route.split(separator: "-")
            if cities.count == 2 {
                let city1 = String(cities[0])
                let city2 = String(cities[1])
                if (fromLower.contains(city1) && toLower.contains(city2)) ||
                   (fromLower.contains(city2) && toLower.contains(city1)) {
                    return duration
                }
            }
        }

        return routeDurations["default"]!
    }

    private func calculateEstimatedPrice(from: String, to: String) -> Int {
        // Rough price estimates (in cents)
        let duration = calculateEstimatedDuration(from: from, to: to)
        // Roughly €0.20 per minute
        return duration * 20 + 200 // base fare + per-minute
    }
}

// Note: ATSHelper is defined in ATSHelper.swift
