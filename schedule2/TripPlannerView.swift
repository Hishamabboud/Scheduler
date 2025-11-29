//
//  TripPlannerView.swift
//  schedule2
//
//  Created by Hisham Abboud on 28/09/2025.
//

import SwiftUI
import MapKit
import Combine

struct TripPlannerView: View {
    @StateObject private var trafficService = RealTimeTrafficService()
    @StateObject private var tripsService = NSTripsService()
    @State private var fromAddress = ""
    @State private var toAddress = ""
    @State private var departureTime = Date()
    @State private var selectedTransportMode: TripTransportMode = .train
    @State private var tripResult: TripResult?
    @State private var liveTripOptions: [LiveTripResult] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingAddressPicker = false
    @State private var isSelectingFromAddress = true
    @State private var showingQuickActions = false
    @State private var selectedQuickTrip: QuickTrip?
    @State private var showLiveResults = true
    
    // Map-related state
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041), // Amsterdam center
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var fromLocation: CLLocationCoordinate2D?
    @State private var toLocation: CLLocationCoordinate2D?
    @State private var routeOverlays: [MKOverlay] = []
    @State private var showingMap = false
    
    // Quick trip suggestions
    private let quickTrips = [
        QuickTrip(from: "Amsterdam Centraal", to: "Utrecht Centraal", icon: "train.side.front.car", duration: "38 min"),
        QuickTrip(from: "Amsterdam Centraal", to: "Rotterdam Centraal", icon: "train.side.front.car", duration: "42 min"),
        QuickTrip(from: "Amsterdam Centraal", to: "Schiphol Airport", icon: "airplane", duration: "20 min"),
        QuickTrip(from: "Utrecht Centraal", to: "Amsterdam Centraal", icon: "train.side.front.car", duration: "35 min")
    ]
    
    // Common Dutch locations and addresses
    private let commonLocations = [
        // Major train stations
        "Amsterdam Centraal", "Utrecht Centraal", "Rotterdam Centraal",
        "Den Haag Centraal", "Eindhoven Centraal", "Groningen", "Zwolle",
        "Tilburg", "Breda", "Amersfoort", "Haarlem", "Lelystad",
        "Maastricht", "Venlo", "Assen", "Almere Centrum", "Delft",
        "Leiden Centraal", "Hilversum", "Deventer",
        
        // Popular addresses and landmarks
        "Schiphol Airport", "Amsterdam Airport", 
        "Dam Square, Amsterdam", "Vondelpark, Amsterdam",
        "Keukenhof, Lisse", "Kinderdijk, Netherlands",
        "Zaanse Schans, Zaandam", "Giethoorn, Netherlands",
        "Madurodam, Den Haag", "Binnenhof, Den Haag",
        "Erasmus Bridge, Rotterdam", "Markthal, Rotterdam",
        "Dom Tower, Utrecht", "Rietveld Schröder House, Utrecht",
        "Van Gogh Museum, Amsterdam", "Rijksmuseum, Amsterdam",
        "Anne Frank House, Amsterdam", "Stedelijk Museum, Amsterdam",
        "Peace Palace, Den Haag", "Noordeinde Palace, Den Haag",
        "Philips Stadium, Eindhoven", "TU Delft Campus",
        "Leiden University", "Erasmus University Rotterdam",
        "VU University Amsterdam", "University of Amsterdam"
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero section
                        heroSection
                            .frame(height: 160)
                        
                        // Quick actions section
                        quickActionsSection
                            .padding(.top, -20) // Overlap with hero section
                        
                        // Main content
                        VStack(spacing: 24) {
                            // Transport mode selection
                            transportModeCard
                            
                            // Address input section
                            addressInputCard
                            
                            // Departure time section  
                            timeSelectionCard
                            
                            // Plan trip button
                            planTripButton
                                .padding(.horizontal)

                            // Live trip options
                            if !liveTripOptions.isEmpty {
                                liveTripResultsSection
                            }

                            // Delay analysis results (shown below live results)
                            if let result = tripResult, result.hasDelays {
                                tripResultsCard(result)
                            }

                            if !errorMessage.isEmpty {
                                errorCard
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddressPicker) {
                addressPickerSheet
            }
            .sheet(isPresented: $showingMap) {
                TripMapView(
                    fromAddress: fromAddress,
                    toAddress: toAddress,
                    fromLocation: fromLocation,
                    toLocation: toLocation,
                    tripResult: tripResult
                )
            }
            .sheet(isPresented: $showingQuickActions) {
                quickActionsSheet
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                // Animated background pattern
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: -100, y: -50)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 150, height: 150)
                    .offset(x: 120, y: 30)
                    .blur(radius: 15)
            }
            
            VStack(spacing: 12) {
                // App icon and title
                HStack(spacing: 16) {
                    Image(systemName: "map")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .glassEffect(.regular.tint(.white.opacity(0.1)), in: .rect(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trip Planner")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Plan your journey across the Netherlands")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60) // Account for status bar
                
                Spacer()
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Trips")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("View All") {
                    showingQuickActions = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickTrips.prefix(4)) { trip in
                        QuickTripCard(trip: trip) {
                            selectQuickTrip(trip)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .glassEffect(.regular.tint(.blue.opacity(0.05)), in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Transport Mode Card
    private var transportModeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .foregroundColor(.blue)
                Text("Transport Mode")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 12) {
                ForEach(TripTransportMode.allCases, id: \.self) { mode in
                    TransportModeButton(
                        mode: mode,
                        isSelected: selectedTransportMode == mode
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTransportMode = mode
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
    
    // MARK: - Address Input Card
    private var addressInputCard: some View {
        VStack(spacing: 20) {
            // Card header
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.green)
                Text("Journey")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                Button(action: swapAddresses) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(fromAddress.isEmpty && toAddress.isEmpty)
            }
            
            VStack(spacing: 16) {
                // From address
                AddressInputField(
                    title: "From",
                    address: $fromAddress,
                    placeholder: "Enter departure location",
                    icon: "location.circle.fill",
                    iconColor: .green,
                    onAddressPicker: {
                        isSelectingFromAddress = true
                        showingAddressPicker = true
                    },
                    onMapShow: {
                        showingMap = true
                        geocodeAddresses()
                    }
                )
                
                // Connecting line
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(.secondary.opacity(0.4))
                                .frame(width: 3, height: 3)
                        }
                    }
                    Spacer()
                }
                
                // To address
                AddressInputField(
                    title: "To",
                    address: $toAddress,
                    placeholder: "Enter destination",
                    icon: "location.fill",
                    iconColor: .red,
                    onAddressPicker: {
                        isSelectingFromAddress = false
                        showingAddressPicker = true
                    },
                    onMapShow: {
                        showingMap = true
                        geocodeAddresses()
                    }
                )
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .onChange(of: fromAddress) { _ in
            Task { await geocodeFromAddress() }
        }
        .onChange(of: toAddress) { _ in
            Task { await geocodeToAddress() }
        }
    }
    
    // MARK: - Time Selection Card
    private var timeSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                Text("Departure Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                DatePicker(
                    "Departure",
                    selection: $departureTime,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                
                HStack {
                    Button("Now") {
                        withAnimation(.spring()) {
                            departureTime = Date()
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("In 1 hour") {
                        withAnimation(.spring()) {
                            departureTime = Date().addingTimeInterval(3600)
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    
    // MARK: - Plan Trip Button
    private var planTripButton: some View {
        Button(action: planTrip) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                }
                
                Text(isLoading ? "Planning Your Journey..." : "Plan My Trip")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background {
                if canPlanTrip && !isLoading {
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.gray.opacity(0.5)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .glassEffect(.regular.interactive(!isLoading && canPlanTrip), in: .rect(cornerRadius: 16))
            .scaleEffect(isLoading ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
        }
        .disabled(!canPlanTrip || isLoading)
        .buttonStyle(.plain)
    }
    
    // MARK: - Trip Results Card
    private func tripResultsCard(_ result: TripResult) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: result.hasDelays ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(result.hasDelays ? .orange : .green)
                            .font(.title2)
                        
                        Text("Trip Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text(result.hasDelays ? "Delays detected on your route" : "Your route looks good!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Map button
                Button(action: {
                    showingMap = true
                    geocodeAddresses()
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .clipShape(Circle())
                        .glassEffect(.regular.interactive(), in: .circle)
                }
            }
            
            // Status cards
            if result.hasDelays {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatusInfoCard(
                        title: "Delays",
                        value: "\(result.affectedSegments.count)",
                        subtitle: "segments affected",
                        icon: "exclamationmark.triangle.fill",
                        color: .orange
                    )
                    
                    StatusInfoCard(
                        title: "Extra Time",
                        value: "\(result.totalDelayMinutes) min",
                        subtitle: "total delay",
                        icon: "clock.fill",
                        color: .red
                    )
                }
            }
            
            // Affected segments
            if !result.affectedSegments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Affected Routes")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(result.affectedSegments) { segment in
                        ModernTripDelayRow(segment: segment)
                    }
                }
            }
            
            // Alternative options
            if result.hasDelays && !result.alternatives.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alternative Options")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(result.alternatives) { alternative in
                        ModernAlternativeRouteRow(alternative: alternative)
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Error Card
    private var errorCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Try Again") {
                planTrip()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    // MARK: - Live Trip Results Section
    private var liveTripResultsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: tripsService.isUsingLiveData ? "antenna.radiowaves.left.and.right" : "info.circle")
                            .foregroundColor(tripsService.isUsingLiveData ? .green : .orange)
                            .font(.title2)

                        Text("Journey Options")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Text(tripsService.isUsingLiveData ? "Live data from NS" : "Demo data - configure API key for live results")
                        .font(.caption)
                        .foregroundColor(tripsService.isUsingLiveData ? .green : .orange)
                }

                Spacer()

                Button(action: {
                    showingMap = true
                    geocodeAddresses()
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .clipShape(Circle())
                        .glassEffect(.regular.interactive(), in: .circle)
                }
            }

            // Trip options list
            ForEach(liveTripOptions) { trip in
                LiveTripOptionCard(trip: trip)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
    
    // MARK: - Quick Actions Sheet
    private var quickActionsSheet: some View {
        NavigationStack {
            List {
                ForEach(quickTrips) { trip in
                    QuickTripRowView(trip: trip) {
                        selectQuickTrip(trip)
                        showingQuickActions = false
                    }
                }
            }
            .navigationTitle("Quick Trips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingQuickActions = false
                    }
                }
            }
        }
    }
    
    private var canPlanTrip: Bool {
        !fromAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !toAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Functions
    private func selectQuickTrip(_ trip: QuickTrip) {
        withAnimation(.spring()) {
            fromAddress = trip.from
            toAddress = trip.to
        }
        
        // Geocode the addresses
        Task {
            await geocodeAddresses()
        }
    }
    private var addressPickerSheet: some View {
        NavigationView {
            List {
                // Search section with MapKit search
                Section("Search Locations") {
                    AddressSearchView(
                        selectedAddress: Binding(
                            get: { isSelectingFromAddress ? fromAddress : toAddress },
                            set: { address in
                                if isSelectingFromAddress {
                                    fromAddress = address
                                } else {
                                    toAddress = address
                                }
                            }
                        ),
                        onSelection: {
                            showingAddressPicker = false
                            Task {
                                await geocodeAddresses()
                            }
                        }
                    )
                }
                
                // Popular locations section
                Section("Popular Locations") {
                    ForEach(commonLocations, id: \.self) { location in
                        Button(action: {
                            if isSelectingFromAddress {
                                fromAddress = location
                            } else {
                                toAddress = location
                            }
                            showingAddressPicker = false
                            
                            // Geocode the selected location
                            Task {
                                if isSelectingFromAddress {
                                    await geocodeFromAddress()
                                } else {
                                    await geocodeToAddress()
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: getLocationIcon(for: location))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location)
                                        .foregroundColor(.primary)
                                    if location.contains(",") {
                                        Text(getLocationCategory(for: location))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle(isSelectingFromAddress ? "Select Departure" : "Select Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingAddressPicker = false
                    }
                }
            }
        }
    }
    
    private func getLocationIcon(for location: String) -> String {
        let lowercased = location.lowercased()
        if lowercased.contains("centraal") || lowercased.contains("station") {
            return selectedTransportMode.systemImage
        } else if lowercased.contains("airport") || lowercased.contains("schiphol") {
            return "airplane"
        } else if lowercased.contains("museum") {
            return "building.columns"
        } else if lowercased.contains("university") || lowercased.contains("campus") {
            return "building.2"
        } else if lowercased.contains("park") {
            return "leaf"
        } else if lowercased.contains("palace") || lowercased.contains("binnenhof") {
            return "crown"
        } else if lowercased.contains("bridge") {
            return "point.topleft.down.curvedto.point.bottomright.up"
        } else if lowercased.contains("stadium") {
            return "sportscourt"
        } else {
            return "mappin"
        }
    }
    
    private func getLocationCategory(for location: String) -> String {
        let lowercased = location.lowercased()
        if lowercased.contains("centraal") || lowercased.contains("station") {
            return "Train Station"
        } else if lowercased.contains("airport") {
            return "Airport"
        } else if lowercased.contains("museum") {
            return "Museum"
        } else if lowercased.contains("university") || lowercased.contains("campus") {
            return "University"
        } else if lowercased.contains("park") {
            return "Park"
        } else if lowercased.contains("palace") {
            return "Palace"
        } else if lowercased.contains("bridge") {
            return "Landmark"
        } else if lowercased.contains("stadium") {
            return "Stadium"
        } else {
            return "Location"
        }
    }
    
    private func swapAddresses() {
        let temp = fromAddress
        fromAddress = toAddress
        toAddress = temp
        
        let tempLocation = fromLocation
        fromLocation = toLocation
        toLocation = tempLocation
    }
    
    // MARK: - Geocoding Functions
    private func geocodeAddresses() {
        Task {
            await geocodeFromAddress()
            await geocodeToAddress()
        }
    }
    
    private func geocodeFromAddress() async {
        guard !fromAddress.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(fromAddress)
            if let location = placemarks.first?.location {
                await MainActor.run {
                    fromLocation = location.coordinate
                }
            }
        } catch {
            print("Geocoding failed for from address: \(error)")
        }
    }
    
    private func geocodeToAddress() async {
        guard !toAddress.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(toAddress)
            if let location = placemarks.first?.location {
                await MainActor.run {
                    toLocation = location.coordinate
                }
            }
        } catch {
            print("Geocoding failed for to address: \(error)")
        }
    }
    
    private func planTrip() {
        isLoading = true
        errorMessage = ""
        liveTripOptions = []
        tripResult = nil

        Task {
            // Fetch live trip options from NS API
            await tripsService.fetchTrips(
                from: fromAddress,
                to: toAddress,
                dateTime: departureTime
            )

            // Also analyze for delays
            let delayResult = await analyzeTrip(
                from: fromAddress,
                to: toAddress,
                departureTime: departureTime,
                transportMode: selectedTransportMode
            )

            await MainActor.run {
                self.liveTripOptions = tripsService.tripOptions
                self.tripResult = delayResult

                if let error = tripsService.error {
                    self.errorMessage = error
                }

                self.isLoading = false
            }
        }
    }
    
    private func analyzeTrip(from: String, to: String, departureTime: Date, transportMode: TripTransportMode) async -> TripResult {
        // Fetch current traffic data
        await trafficService.fetchTrafficInfo()
        
        var affectedSegments: [TripSegment] = []
        var totalDelay = 0
        var alternatives: [AlternativeRoute] = []
        
        // Analyze based on transport mode
        switch transportMode {
        case .train:
            if let trafficInfo = trafficService.trafficInfo {
                for service in trafficInfo.trainServices {
                    for delay in service.delays {
                        // Check if this delay affects the user's route
                        if routeAffectedByDelay(from: from, to: to, delay: delay.station, route: delay.route) {
                            let segment = TripSegment(
                                operator: service.operatorName,
                                route: delay.route,
                                delayMinutes: delay.delayMinutes,
                                reason: delay.reason ?? "Unspecified delay",
                                affectedStation: delay.station,
                                trainNumber: delay.trainNumber
                            )
                            affectedSegments.append(segment)
                            totalDelay += delay.delayMinutes
                        }
                    }
                }
                
                // Generate alternatives if there are delays
                if !affectedSegments.isEmpty {
                    alternatives = generateAlternatives(from: from, to: to, transportMode: transportMode)
                }
            }
            
        case .bus:
            if let trafficInfo = trafficService.trafficInfo {
                for service in trafficInfo.busServices {
                    for delay in service.delays {
                        // Check if this delay affects the user's route
                        if routeAffectedByDelay(from: from, to: to, delay: delay.stop, route: delay.route) {
                            let segment = TripSegment(
                                operator: service.operatorName,
                                route: delay.route,
                                delayMinutes: delay.delayMinutes,
                                reason: delay.reason ?? "Unspecified delay",
                                affectedStation: delay.stop,
                                trainNumber: delay.lineNumber
                            )
                            affectedSegments.append(segment)
                            totalDelay += delay.delayMinutes
                        }
                    }
                }
                
                if !affectedSegments.isEmpty {
                    alternatives = generateAlternatives(from: from, to: to, transportMode: transportMode)
                }
            }
            
        case .mixed:
            // Check both train and bus delays
            if let trafficInfo = trafficService.trafficInfo {
                // Check trains
                for service in trafficInfo.trainServices {
                    for delay in service.delays {
                        if routeAffectedByDelay(from: from, to: to, delay: delay.station, route: delay.route) {
                            let segment = TripSegment(
                                operator: service.operatorName,
                                route: delay.route,
                                delayMinutes: delay.delayMinutes,
                                reason: delay.reason ?? "Unspecified delay",
                                affectedStation: delay.station,
                                trainNumber: delay.trainNumber
                            )
                            affectedSegments.append(segment)
                            totalDelay += delay.delayMinutes
                        }
                    }
                }
                
                // Check buses
                for service in trafficInfo.busServices {
                    for delay in service.delays {
                        if routeAffectedByDelay(from: from, to: to, delay: delay.stop, route: delay.route) {
                            let segment = TripSegment(
                                operator: service.operatorName,
                                route: delay.route,
                                delayMinutes: delay.delayMinutes,
                                reason: delay.reason ?? "Unspecified delay",
                                affectedStation: delay.stop,
                                trainNumber: delay.lineNumber
                            )
                            affectedSegments.append(segment)
                            totalDelay += delay.delayMinutes
                        }
                    }
                }
                
                if !affectedSegments.isEmpty {
                    alternatives = generateAlternatives(from: from, to: to, transportMode: transportMode)
                }
            }
        }
        
        return TripResult(
            from: from,
            to: to,
            departureTime: departureTime,
            transportMode: transportMode,
            affectedSegments: affectedSegments,
            totalDelayMinutes: totalDelay,
            alternatives: alternatives
        )
    }
    
    private func routeAffectedByDelay(from: String, to: String, delay: String, route: String) -> Bool {
        // Enhanced heuristic to check if a delay affects the user's route
        let fromLower = from.lowercased()
        let toLower = to.lowercased()
        let delayLower = delay.lowercased()
        let routeLower = route.lowercased()
        
        // Extract city names from addresses
        let fromCity = extractCityName(from: fromLower)
        let toCity = extractCityName(from: toLower)
        let delayCity = extractCityName(from: delayLower)
        
        // Check direct matches
        if delayLower.contains(fromLower) || 
           delayLower.contains(toLower) ||
           routeLower.contains(fromLower) || 
           routeLower.contains(toLower) {
            return true
        }
        
        // Check city-level matches
        if delayCity == fromCity || delayCity == toCity {
            return true
        }
        
        // Check major stations and landmarks
        let majorKeywords = ["centraal", "airport", "schiphol"]
        for keyword in majorKeywords {
            if (fromLower.contains(keyword) && delayLower.contains(keyword)) ||
               (toLower.contains(keyword) && delayLower.contains(keyword)) {
                return true
            }
        }
        
        // Check if route connects the cities
        if routeLower.contains(fromCity) && routeLower.contains(toCity) {
            return true
        }
        
        return false
    }
    
    private func extractCityName(from address: String) -> String {
        let addressLower = address.lowercased()
        
        // Extract city from common patterns like "Location, City"
        if let commaIndex = addressLower.lastIndex(of: ",") {
            let cityPart = String(addressLower[addressLower.index(after: commaIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return cityPart
        }
        
        // Check for common city names in the address
        let cities = ["amsterdam", "utrecht", "rotterdam", "den haag", "eindhoven", 
                     "groningen", "tilburg", "breda", "haarlem", "leiden", "delft",
                     "maastricht", "venlo", "assen", "almere", "hilversum", "deventer",
                     "zwolle", "amersfoort", "lelystad", "lisse", "zaandam"]
        
        for city in cities {
            if addressLower.contains(city) {
                return city
            }
        }
        
        // If no specific city found, return the first word (might be the city)
        return addressLower.components(separatedBy: " ").first ?? addressLower
    }
    
    private func generateAlternatives(from: String, to: String, transportMode: TripTransportMode) -> [AlternativeRoute] {
        var alternatives: [AlternativeRoute] = []
        
        let fromCity = extractCityName(from: from.lowercased())
        let toCity = extractCityName(from: to.lowercased())
        
        switch transportMode {
        case .train:
            alternatives.append(AlternativeRoute(
                description: "Bus + Train combination",
                estimatedDelay: "+15-20 minutes",
                recommendation: "Take local bus to nearest train station, then continue by train"
            ))
            alternatives.append(AlternativeRoute(
                description: "Later train departure",
                estimatedDelay: "+30-45 minutes",
                recommendation: "Wait for next scheduled train departure"
            ))
            if fromCity != toCity {
                alternatives.append(AlternativeRoute(
                    description: "Direct bus connection",
                    estimatedDelay: "+45-60 minutes",
                    recommendation: "Take intercity bus service between \(fromCity.capitalized) and \(toCity.capitalized)"
                ))
            }
            
        case .bus:
            alternatives.append(AlternativeRoute(
                description: "Alternative bus route",
                estimatedDelay: "+10-15 minutes",
                recommendation: "Use different bus line with transfer"
            ))
            if fromCity != toCity {
                alternatives.append(AlternativeRoute(
                    description: "Train connection",
                    estimatedDelay: "+5-10 minutes",
                    recommendation: "Take local transport to train station, then train to destination"
                ))
            }
            alternatives.append(AlternativeRoute(
                description: "Walking + Public transport",
                estimatedDelay: "+20-30 minutes",
                recommendation: "Walk to nearby transport hub and continue with available options"
            ))
            
        case .mixed:
            alternatives.append(AlternativeRoute(
                description: "Train-focused route",
                estimatedDelay: "+10-15 minutes", 
                recommendation: "Use local transport to train stations and travel primarily by train"
            ))
            alternatives.append(AlternativeRoute(
                description: "Bus-focused route",
                estimatedDelay: "+20-25 minutes",
                recommendation: "Use bus connections with minimal walking between stops"
            ))
            alternatives.append(AlternativeRoute(
                description: "Multi-modal with cycling",
                estimatedDelay: "+15-25 minutes",
                recommendation: "Combine cycling to transport hubs with public transport"
            ))
        }
        
        return alternatives
    }
}

// MARK: - Supporting Views
struct TripDelayRow: View {
    let segment: TripSegment
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(segment.`operator`)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(segment.route)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let trainNumber = segment.trainNumber {
                    Text(trainNumber)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                Text(segment.reason)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(segment.delayMinutes) min")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                Text(segment.affectedStation)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct AlternativeRouteRow: View {
    let alternative: AlternativeRoute
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.branch")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alternative.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(alternative.recommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(alternative.estimatedDelay)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Types
enum TripTransportMode: String, CaseIterable {
    case train = "train"
    case bus = "bus"
    case mixed = "mixed"
    
    var displayName: String {
        switch self {
        case .train: return "Train"
        case .bus: return "Bus"
        case .mixed: return "Mixed"
        }
    }
    
    var systemImage: String {
        switch self {
        case .train: return "train.side.front.car"
        case .bus: return "bus.fill"
        case .mixed: return "arrow.triangle.branch"
        }
    }
    
    var color: Color {
        switch self {
        case .train: return .blue
        case .bus: return .green
        case .mixed: return .purple
        }
    }
}

struct TripResult {
    let from: String
    let to: String
    let departureTime: Date
    let transportMode: TripTransportMode
    let affectedSegments: [TripSegment]
    let totalDelayMinutes: Int
    let alternatives: [AlternativeRoute]
    
    var hasDelays: Bool {
        !affectedSegments.isEmpty
    }
}

struct TripSegment: Identifiable {
    let id = UUID()
    let `operator`: String
    let route: String
    let delayMinutes: Int
    let reason: String
    let affectedStation: String
    let trainNumber: String?
}

struct AlternativeRoute: Identifiable {
    let id = UUID()
    let description: String
    let estimatedDelay: String
    let recommendation: String
}

// MARK: - Address Search View
struct AddressSearchView: View {
    @Binding var selectedAddress: String
    let onSelection: () -> Void
    
    @State private var searchText = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var searchCompleter = SearchCompleterWrapper()
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search for places", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        searchResults = []
                    }
                    .foregroundColor(.blue)
                    .font(.caption)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            ForEach(searchResults.prefix(5), id: \.self) { result in
                Button(action: {
                    selectedAddress = "\(result.title), \(result.subtitle)"
                    onSelection()
                }) {
                    HStack {
                        Image(systemName: "mappin")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.title)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .foregroundColor(.primary)
            }
        }
        .onAppear {
            setupSearchCompleter()
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                searchResults = []
            } else {
                searchCompleter.updateQuery(newValue)
            }
        }
        .onReceive(searchCompleter.$results) { results in
            self.searchResults = results
        }
    }
    
    private func setupSearchCompleter() {
        searchCompleter.setupRegion(
            center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            
            let results = response.mapItems.compactMap { item in
                CustomSearchCompletion(
                    title: item.name ?? "Unknown",
                    subtitle: item.placemark.title ?? ""
                )
            }
            
            self.searchResults = Array(results.prefix(5))
        }
    }
}

class SearchCompleterWrapper: ObservableObject {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()
    private let delegate = SearchCompleterDelegate()
    
    init() {
        completer.delegate = delegate
        delegate.onResults = { [weak self] results in
            DispatchQueue.main.async {
                self?.results = results
            }
        }
    }
    
    func updateQuery(_ query: String) {
        completer.queryFragment = query
    }
    
    func setupRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        completer.region = MKCoordinateRegion(center: center, span: span)
    }
}

class CustomSearchCompletion: MKLocalSearchCompletion {
    private let _title: String
    private let _subtitle: String
    
    init(title: String, subtitle: String) {
        self._title = title
        self._subtitle = subtitle
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var title: String { _title }
    override var subtitle: String { _subtitle }
}

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onResults: (([MKLocalSearchCompletion]) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onResults?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer failed with error: \(error)")
        onResults?([])
    }
}



// MARK: - Trip Map View
struct TripMapView: View {
    let fromAddress: String
    let toAddress: String
    let fromLocation: CLLocationCoordinate2D?
    let toLocation: CLLocationCoordinate2D?
    let tripResult: TripResult?
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041), // Amsterdam center
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    @State private var route: MKRoute?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $mapRegion, interactionModes: .all, showsUserLocation: false, annotationItems: mapAnnotations) { annotation in
                    MapPin(coordinate: annotation.coordinate, tint: annotation.isStart ? .green : .red)
                }
                .onAppear {
                    setupMapRegion()
                    calculateRoute()
                }
                
                // Trip info overlay
                VStack {
                    Spacer()
                    
                    if let result = tripResult {
                        TripMapInfoCard(
                            fromAddress: fromAddress,
                            toAddress: toAddress,
                            tripResult: result
                        )
                        .padding()
                    } else {
                        RouteInfoCard(
                            fromAddress: fromAddress,
                            toAddress: toAddress
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Trip Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var mapAnnotations: [MapPointAnnotation] {
        var annotations: [MapPointAnnotation] = []
        
        if let fromLocation = fromLocation {
            annotations.append(MapPointAnnotation(coordinate: fromLocation, isStart: true))
        }
        
        if let toLocation = toLocation {
            annotations.append(MapPointAnnotation(coordinate: toLocation, isStart: false))
        }
        
        return annotations
    }
    
    private func setupMapRegion() {
        guard let fromLocation = fromLocation, let toLocation = toLocation else { return }
        
        let centerLat = (fromLocation.latitude + toLocation.latitude) / 2
        let centerLon = (fromLocation.longitude + toLocation.longitude) / 2
        
        let latDelta = abs(fromLocation.latitude - toLocation.latitude) * 1.5
        let lonDelta = abs(fromLocation.longitude - toLocation.longitude) * 1.5
        
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(
                latitudeDelta: max(latDelta, 0.01),
                longitudeDelta: max(lonDelta, 0.01)
            )
        )
    }
    
    private func calculateRoute() {
        guard let fromLocation = fromLocation, let toLocation = toLocation else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: fromLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toLocation))
        request.transportType = .transit // Use public transit when possible
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.route = route
            }
        }
    }
}

struct MapPointAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isStart: Bool
    let title: String
    
    init(coordinate: CLLocationCoordinate2D, isStart: Bool) {
        self.coordinate = coordinate
        self.isStart = isStart
        self.title = isStart ? "Start" : "End"
    }
}

struct TripMapInfoCard: View {
    let fromAddress: String
    let toAddress: String
    let tripResult: TripResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Route")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(fromAddress)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(toAddress)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: tripResult.hasDelays ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                        .foregroundColor(tripResult.hasDelays ? .orange : .green)
                        .font(.title2)
                    
                    if tripResult.hasDelays {
                        Text("+\(tripResult.totalDelayMinutes) min")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    } else {
                        Text("On Time")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if tripResult.hasDelays {
                Text("\(tripResult.affectedSegments.count) delay(s) on your route")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RouteInfoCard: View {
    let fromAddress: String
    let toAddress: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Route")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 8) {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text(fromAddress)
                    .font(.caption)
                    .lineLimit(1)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text(toAddress)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Supporting View Components

struct QuickTrip: Identifiable {
    let id = UUID()
    let from: String
    let to: String
    let icon: String
    let duration: String
}

struct QuickTripCard: View {
    let trip: QuickTrip
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: trip.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(extractCityName(trip.from))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                    
                    Text(extractCityName(trip.to))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text(trip.duration)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 120)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func extractCityName(_ address: String) -> String {
        if let spaceIndex = address.firstIndex(of: " ") {
            return String(address[..<spaceIndex])
        }
        return address
    }
}

struct QuickTripRowView: View {
    let trip: QuickTrip
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: trip.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(.blue.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(trip.from)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(trip.to)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Estimated: \(trip.duration)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct TransportModeButton: View {
    let mode: TripTransportMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? .blue : .blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(mode.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? .blue.opacity(0.1) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct AddressInputField: View {
    let title: String
    @Binding var address: String
    let placeholder: String
    let icon: String
    let iconColor: Color
    let onAddressPicker: () -> Void
    let onMapShow: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $address)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
                
                Button(action: onAddressPicker) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(.blue)
                        .clipShape(Circle())
                }
                .glassEffect(.regular.interactive(), in: .circle)
                
                Button(action: onMapShow) {
                    Image(systemName: "map")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(.green)
                        .clipShape(Circle())
                }
                .glassEffect(.regular.interactive(), in: .circle)
            }
        }
    }
}

struct StatusInfoCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .medium))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ModernTripDelayRow: View {
    let segment: TripSegment
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .frame(width: 20)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(segment.operator)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("+\(segment.delayMinutes) min")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Text(segment.route)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let trainNumber = segment.trainNumber {
                    Text(trainNumber)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Text(segment.reason)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(.orange.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernAlternativeRouteRow: View {
    let alternative: AlternativeRoute
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.branch")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alternative.description)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(alternative.estimatedDelay)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundColor(.blue)
                }
                
                Text(alternative.recommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Live Trip Option Card
struct LiveTripOptionCard: View {
    let trip: LiveTripResult
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main summary row
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 16) {
                    // Status icon
                    Image(systemName: trip.status.icon)
                        .foregroundColor(trip.status.color)
                        .font(.title2)
                        .frame(width: 32)

                    // Times and duration
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(trip.departureTime, style: .time)
                                .font(.headline)
                                .fontWeight(.bold)

                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(trip.arrivalTime, style: .time)
                                .font(.headline)
                                .fontWeight(.bold)
                        }

                        HStack(spacing: 8) {
                            Text(trip.formattedDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if trip.transfers > 0 {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("\(trip.transfers) transfer\(trip.transfers > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text("Direct")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    Spacer()

                    // Price and expand indicator
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(trip.formattedPrice)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)

                        if trip.isOptimal {
                            Text("Recommended")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1), in: Capsule())
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)

            // Warnings
            if !trip.warnings.isEmpty {
                ForEach(trip.warnings.prefix(2), id: \.self) { warning in
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(warning)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .lineLimit(2)
                    }
                }
            }

            // Expanded leg details
            if isExpanded {
                Divider()

                ForEach(Array(trip.legs.enumerated()), id: \.offset) { index, leg in
                    LiveTripLegRow(leg: leg, isLast: index == trip.legs.count - 1)
                }

                // Crowd forecast
                if let crowd = trip.crowdForecast {
                    HStack(spacing: 8) {
                        Image(systemName: crowdIcon(for: crowd))
                            .foregroundColor(crowdColor(for: crowd))
                        Text("Expected crowd: \(crowd.capitalized)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(16)
        .background(backgroundColorForStatus(trip.status).opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(backgroundColorForStatus(trip.status).opacity(0.2), lineWidth: 1)
        )
    }

    private func backgroundColorForStatus(_ status: TripStatus) -> Color {
        switch status {
        case .normal: return .green
        case .delayed: return .orange
        case .cancelled: return .red
        case .alternative: return .blue
        case .disruption: return .red
        }
    }

    private func crowdIcon(for forecast: String) -> String {
        switch forecast.uppercased() {
        case "LOW": return "person"
        case "MEDIUM": return "person.2"
        case "HIGH": return "person.3"
        default: return "person.2"
        }
    }

    private func crowdColor(for forecast: String) -> Color {
        switch forecast.uppercased() {
        case "LOW": return .green
        case "MEDIUM": return .orange
        case "HIGH": return .red
        default: return .secondary
        }
    }
}

// MARK: - Live Trip Leg Row
struct LiveTripLegRow: View {
    let leg: LiveTripLeg
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(leg.mode.color)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(leg.mode.color.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
            }
            .frame(width: 16)

            // Leg details
            VStack(alignment: .leading, spacing: 6) {
                // Transport info
                HStack(spacing: 8) {
                    Image(systemName: leg.mode.systemImage)
                        .foregroundColor(leg.mode.color)
                        .font(.system(size: 14, weight: .medium))

                    Text(leg.lineName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if let lineNumber = leg.lineNumber {
                        Text(lineNumber)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1), in: Capsule())
                    }

                    Spacer()

                    if leg.hasDelay {
                        Text("+\(leg.delayMinutes) min")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }

                // From station with time and track
                HStack(spacing: 8) {
                    Text(leg.departureTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Text(leg.fromStation)
                        .font(.caption)
                        .lineLimit(1)

                    if let track = leg.actualDepartureTrack ?? leg.plannedDepartureTrack {
                        Spacer()
                        HStack(spacing: 2) {
                            Text("Platform")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(track)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(leg.trackChanged ? .orange : .primary)
                        }
                    }
                }

                // Direction
                if let direction = leg.direction {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                        Text("Direction: \(direction)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // To station with time
                HStack(spacing: 8) {
                    Text(leg.arrivalTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .leading)

                    Text(leg.toStation)
                        .font(.caption)
                        .lineLimit(1)

                    if let track = leg.actualArrivalTrack ?? leg.plannedArrivalTrack {
                        Spacer()
                        HStack(spacing: 2) {
                            Text("Platform")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(track)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }

                // Duration
                Text("\(leg.durationMinutes) min")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                // Messages
                if !leg.messages.isEmpty {
                    ForEach(leg.messages.prefix(2), id: \.self) { message in
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption2)
                            Text(message)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TripPlannerView()
}
