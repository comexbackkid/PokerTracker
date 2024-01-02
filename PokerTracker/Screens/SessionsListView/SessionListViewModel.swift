//
//  SessionListViewModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/24/21.
//

import SwiftUI
import WidgetKit

class SessionsListViewModel: ObservableObject {
    
    @Published var uniqueStakes: [String] = []
    @Published var locations: [LocationModel] = DefaultLocations.allLocations
    {
        didSet {
            saveLocations()
        }
    }
    
    @Published var sessions: [PokerSession] = [] {
        didSet {
            saveSessions()
            setUniqueStakes()
            writeToWidget()
        }
    }
    
    init() {
        getSessions()
        getLocations()
    }
    
    // MARK: SAVING & LOADING APP DATA
    
    var sessionsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("sessions.json")
    }
    
    var locationsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("locations.json")
    }
    
    // Saves the list of sessions with FileManager
    func saveSessions() {
        do {
            if let encodedData = try? JSONEncoder().encode(sessions) {
                try? FileManager.default.removeItem(at: sessionsPath)
                try encodedData.write(to: sessionsPath)
            }
        } catch {
            print("Failed to write out sessions \(error)")
        }
    }
    
    // Loads all sessions from FileManager upon app launch
    func getSessions() {
        guard
            let data = try? Data(contentsOf: sessionsPath),
            let savedSessions = try? JSONDecoder().decode([PokerSession].self, from: data)
        else { return }
        
        self.sessions = savedSessions
    }
    
    // MARK: LOCATION FUNCTIONS SUCH AS ADD, DELETE, & MERGE
    
    // Saves the list of locations the user has created with FileManager
    func saveLocations() {
        do {
            if let encodedData = try? JSONEncoder().encode(locations) {
                try? FileManager.default.removeItem(at: locationsPath)
                try encodedData.write(to: locationsPath)
            }
        } catch {
            print("Failed to write out locations, \(error)")
        }
    }
    
    // Function to delete from user's list of Locations from the Settings screen
    func delete(_ location: LocationModel) {
        if let index = locations.firstIndex(where: { $0.id == location.id })
        {
            locations.remove(at: index)
            saveLocations()
        }
    }
    
    // Loads the locations the user has created upon app launch
    func getLocations() {
        guard
            let data = try? Data(contentsOf: locationsPath),
            let savedLocations = try? JSONDecoder().decode([LocationModel].self, from: data)
                
        else { return }
        
        self.locations = savedLocations
    }
    
    // Will merge Default Locations in to the current saved Locations and also keep the same order
    // Question is, do we absolutely need to run this? If a user deletes a default location, they presumably don't want it back?
    // Maybe there's a "Restore to Defaults" button?
    func mergeLocations() {
        var modifiedLocations = self.locations
        
        for newLocation in DefaultLocations.allLocations {
            if !modifiedLocations.contains(newLocation) {
                modifiedLocations.append(newLocation)
            }
        }
        
        self.locations = modifiedLocations
    }
    
    // Adds a new Location to the app
    func addLocation(name: String,
                     localImage: String,
                     imageURL: String) {
        
        let newLocation = LocationModel(name: name,
                                        localImage: localImage,
                                        imageURL: imageURL)
        
        locations.append(newLocation)
    }
    
    // This is only working when you filter by .name versus the .id not sure why? Does it matter? What if the name is changed by the user?
    func uniqueLocationCount(location: LocationModel) -> Int {
        let array = self.sessions.filter({ $0.location.id == location.id })
        return array.count
    }
    
    func setUniqueStakes() {
        uniqueStakes = Array(Set(sessions.filter({ $0.isTournament == false || $0.isTournament == nil }).map({ $0.stakes })))
    }
    
    // MARK: CALCULATIONS & DATA PRESENTATION FOR USE IN CHARTS & METRICS VIEW
    
    // Calculate current bankroll
    func tallyBankroll() -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        let bankroll = sessions.map { Int($0.profit) }.reduce(0, +)
        return bankroll
    }
    
    // Creates an array of our running, cumulative bankroll for use with charts
    func chartArray() -> [Double] {
        let profitsArray = sessions.map { Double($0.profit) }
        var cumBankroll = [Double]()
        var runningTotal = 0.0
        cumBankroll.append(0.0)
        
        for value in profitsArray.reversed() {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }
    
    // Converts our profit data into coordinates tuples for charting
    func chartCoordinates() -> [Point] {
        
        var shortenedChart = [Double]()
        
        for (index, item) in chartArray().enumerated() {
            if index.isMultiple(of: 2) {
                shortenedChart.append(item)
            }
            
            if index.isMultiple(of: 5) {
                shortenedChart.append(item)
            }
        }
        
        // If there's over 25 sessions, we will use every other data point, or every 5 data points (depending) to chart the data to smooth it out
        if chartArray().count > 25 {
            return shortenedChart.enumerated().map({ Point(x:CGFloat($0.offset), y: $0.element) })
            
        } else {
            return chartArray().enumerated().map({ Point(x:CGFloat($0.offset), y: $0.element) })
        }
    }
    
    // Custom designed Bar Chart weekday profit totals
//    func barGraphByDay() -> [Int] {
//        let sunday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Sunday" }).map({ $0.profit }).reduce(0,+)
//        let monday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Monday" }).map({ $0.profit }).reduce(0,+)
//        let tuesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Tuesday" }).map({ $0.profit }).reduce(0,+)
//        let wednesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Wednesday" }).map({ $0.profit }).reduce(0,+)
//        let thursday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Thursday" }).map({ $0.profit }).reduce(0,+)
//        let friday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Friday" }).map({ $0.profit }).reduce(0,+)
//        let saturday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Saturday" }).map({ $0.profit }).reduce(0,+)
//        return [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
//    }
    
    // Returns a tuple array for use in Swift Charts bar chart
    func barChartByDay() -> [SessionData] {
        let sunday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Sunday" }).map({ $0.profit }).reduce(0,+)
        let monday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Monday" }).map({ $0.profit }).reduce(0,+)
        let tuesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Tuesday" }).map({ $0.profit }).reduce(0,+)
        let wednesday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Wednesday" }).map({ $0.profit }).reduce(0,+)
        let thursday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Thursday" }).map({ $0.profit }).reduce(0,+)
        let friday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Friday" }).map({ $0.profit }).reduce(0,+)
        let saturday = sessions.filter({ $0.date.dayOfWeek(day: $0.date) == "Saturday" }).map({ $0.profit }).reduce(0,+)
        return [("Su", sunday), ("M", monday), ("T", tuesday), ("W", wednesday), ("Th", thursday), ("F", friday), ("S", saturday)].map(SessionData.init)
    }
    
    // Simply counts how many sessions played by year. Used in Study section
    func sessionsPerYear(year: String) -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.filter({ $0.date.getYear() == year }).count
    }
    
    // Adds up total number of profitable sessions
    func numOfCashes() -> Int {
        guard !sessions.isEmpty else { return 0 }
        return sessions.filter { $0.profit > 0 }.count
    }
    
    // Returns percentage of winning seessions
    func winRate() -> String {
        guard !sessions.isEmpty else { return "0%" }
        let winPercentage = Double(numOfCashes()) / Double(sessions.count)
        return winPercentage.asPercent()
    }
    
    // Calculate total hourly earnings rate for MetricsView
    func hourlyRate() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let totalHours = sessions.map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        let totalMinutes = Float(sessions.map { Int($0.sessionDuration.minute ?? 0) }.reduce(0,+))
        
        if totalHours < 1 {
            return Int(Float(tallyBankroll()) / (totalMinutes / 60))
        } else {
            return tallyBankroll() / totalHours
        }
    }
    
    // Calculate average session duration for MetricsView
    func avgDuration() -> String {
        guard !sessions.isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +) / sessions.count
        let totalMinutes = minutesArray.reduce(0, +) / sessions.count
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.formattedDuration
    }
    
    // Calculate average profit per session
    func avgProfit() -> Int {
        guard !sessions.isEmpty else { return 0 }
        return tallyBankroll() / sessions.count
    }
    
    // Total hours played from all sessions
    func totalHoursPlayed() -> String {
        guard !sessions.isEmpty else { return "0" }
        let totalHours = sessions.map { $0.sessionDuration.hour ?? 0 }.reduce(0, +)
        let totalMins = sessions.map { $0.sessionDuration.minute ?? 0 }.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMins)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    // MARK: CALCULATIONS FOR ANNUAL REPORT VIEW
    
    func bankrollByYear(year: String) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let bankroll = sessions.filter({ $0.date.getYear() == year }).map { Int($0.profit) }.reduce(0, +)
        return bankroll
    }
    
    func hourlyByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let hoursArray = sessions.filter({ $0.date.getYear() == year }).map { Int($0.sessionDuration.hour ?? 0) }
        let minutesArray = sessions.filter({ $0.date.getYear() == year }).map { Int($0.sessionDuration.minute ?? 0) }
        let totalHours = hoursArray.reduce(0,+)
        let totalMinutes = Float(minutesArray.reduce(0, +))
        
        if totalHours < 1 {
            return Int(Float(bankrollByYear(year: year)) / (totalMinutes / 60))
        } else {
            return bankrollByYear(year: year) / totalHours
        }
    }
    
    func hourlyByLocation(venue: String, total: Int) -> Int {
        guard !sessions.filter({ $0.location.name == venue }).isEmpty else { return 0 }
        let totalHours = sessions.filter({ $0.location.name == venue }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        return total / totalHours
    }
    
    func hourlyByStakes(stakes: String, total: Int) -> Int {
        guard !sessions.filter({$0.stakes == stakes}).isEmpty else { return 0 }
        let totalHours = sessions.filter({ $0.stakes == stakes }).map { Int($0.sessionDuration.hour ?? 0) }.reduce(0,+)
        return total / totalHours
    }
    
    func avgProfitByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        return bankrollByYear(year: year) / sessions.filter({ $0.date.getYear() == year }).count
    }
    
    func hoursPlayedByYear(year: String) -> String {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return "0" }
        let hoursArray: [Int] = sessions.filter({ $0.date.getYear() == year }).map { $0.sessionDuration.hour ?? 0 }
        let minutesArray: [Int] = sessions.filter({ $0.date.getYear() == year }).map { $0.sessionDuration.minute ?? 0 }
        let totalHours = hoursArray.reduce(0, +)
        let totalMinutes = minutesArray.reduce(0, +)
        let dateComponents = DateComponents(hour: totalHours, minute: totalMinutes)
        return dateComponents.abbreviated(duration: dateComponents)
    }
    
    func totalExpenses() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let expenses = sessions.map { $0.expenses ?? 0 }.reduce(0,+)
        return expenses
    }
    
    func totalExpensesByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let expenses = sessions.filter({ $0.date.getYear() == year }).map { $0.expenses ?? 0 }.reduce(0,+)
        return expenses
    }
    
    func numOfCashesByYear(year: String) -> Int {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return 0 }
        let profitableSessions = sessions.filter({ $0.date.getYear() == year }).filter { $0.profit > 0 }
        return profitableSessions.count
    }
    
    func winRateByYear(year: String) -> String {
        guard !sessions.filter({ $0.date.getYear() == year }).isEmpty else { return "0%" }
        let wins = Double(numOfCashesByYear(year: year))
        let sessions = Double(sessionsPerYear(year: year))
        let winPercentage = wins / sessions
        return winPercentage.asPercent()
    }
    
    func bestLocation(year: String? = nil) -> LocationModel? {
        guard !sessions.isEmpty else { return DefaultData.defaultLocation }
        if let yearFilter = year {
            let filteredSessions = sessions.filter({ $0.date.getYear() == yearFilter }).map({ ($0.location, $0.profit) })
            let maxProfit = Dictionary(filteredSessions, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
            return maxProfit?.key
            
        } else {
            let locationTuple = sessions.map({ ($0.location, $0.profit) })
            let maxProfit = Dictionary(locationTuple, uniquingKeysWith: { $0 + $1 }).max { $0.value < $1.value }
            return maxProfit?.key
        }   
    }
    
    func bestSession(year: String? = nil) -> Int? {
        guard !sessions.isEmpty else { return 0 }
        if let yearFilter = year {
            let filteredSessions = sessions.filter({ $0.date.getYear() == yearFilter })
            return filteredSessions.map({ $0.profit }).max(by: { $0 < $1 })
        }
        
        else {
            let bestSession = sessions.map({ $0.profit }).max(by: { $0 < $1 })
            return bestSession
        }
    }
    
    // MARK: CHART FUNCTIONS
    
    func yearlyChartArray(year: String) -> [Double] {
        let profitsArray = sessions.filter({ $0.date.getYear() == year }).map { Double($0.profit) }
        var cumBankroll = [Double]()
        var runningTotal = 0.0
        cumBankroll.append(0.0)

        for value in profitsArray.reversed() {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }

    func yearlyChartCoordinates(year: String) -> [Point] {
        return yearlyChartArray(year: year).enumerated().map({Point(x:CGFloat($0.offset), y: $0.element)})
    }
    
    // MARK: ADDITIONAL METRICS CARDS
    
    func sessionsByLocation(_ location: String) -> [PokerSession] {
        sessions.filter({ $0.location.name == location })
    }
    
    func profitByLocation(_ location: String) -> Int {
        return sessionsByLocation(location).reduce(0) { $0 + $1.profit }
    }
    
//    func sessionsByDayOfWeek(_ day: String) -> [PokerSession] {
//        sessions.filter({ $0.date.dayOfWeek(day: $0.date) == day })
//    }
//
//    func profitByDayOfWeek(_ day: String) -> Int {
//        return sessionsByDayOfWeek(day).reduce(0) { $0 + $1.profit }
//    }
    
    func sessionsByMonth(_ month: String) -> [PokerSession] {
        sessions.filter({ $0.date.monthOfYear(month: $0.date) == month })
    }
    
    func profitByMonth(_ month: String) -> Int {
        return sessionsByMonth(month).reduce(0) { $0 + $1.profit }
    }
    
    func sessionsByStakes(_ stakes: String) -> [PokerSession] {
        sessions.filter({ $0.stakes == stakes })
    }
    
    func profitByStakes(_ stakes: String) -> Int {
        return sessionsByStakes(stakes).reduce(0) { $0 + $1.profit }
    }
    
    // Function that adds a new session to variable sessions, above, from NewSessionView
    func addSession(location: LocationModel,
                    game: String,
                    stakes: String,
                    date: Date,
                    profit: Int,
                    notes: String,
                    startTime: Date, endTime: Date,
                    expenses: Int,
                    isTournament: Bool,
                    entrants: Int) {
        
        let newSession = PokerSession(location: location,
                                      game: game,
                                      stakes: stakes,
                                      date: date,
                                      profit: profit,
                                      notes: notes,
                                      startTime: startTime, endTime: endTime,
                                      expenses: expenses,
                                      isTournament: isTournament,
                                      entrants: entrants)
        sessions.append(newSession)
        sessions.sort(by: {$0.date > $1.date})
    }
    
    // MARK: SAVING & EXPORTING USER'S SESSIONS
    
    // In the future, can we write a function that converts their Annual Summary into a CSV file?
    // Then immediately after the export file modifier called to save the file to iCloud
    
    
//    func pathForUserData() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[1]
//    }
//    
//    func writeUserData() {
//        
//        let dummyData = UserYearlySummary.init(year: "2022", netProfit: "3700", hourlyRate: "50", profitPerSession: "25", expenses: "98", winRate: "67%", biggestWin: "2200", bestLocation: "Chaser's Poker")
//        let url = pathForUserData().appendingPathComponent("test.json")
//        
//        do {
//            if let encodedUserData = try? JSONEncoder().encode(dummyData) {
//                try? FileManager.default.removeItem(at: url)
//                try encodedUserData.write(to: url)
//            }
//        } catch {
//            print("Failed to save user data, \(error)")
//        }
//    }
    
    // MARK: WIDGET FUNCTIONS
    
    func writeToWidget() {
        guard let defaults = UserDefaults(suiteName: AppGroup.bankrollSuite) else {
            print("Unable to write to User Defaults!")
            return
        }

        defaults.set(self.tallyBankroll(), forKey: AppGroup.bankrollKey)
        defaults.set(self.sessions.first?.profit ?? 0, forKey: AppGroup.lastSessionKey)
        defaults.set(self.hourlyRate(), forKey: AppGroup.hourlyKey)
        defaults.set(self.sessions.count, forKey: AppGroup.totalSessionsKey)

        guard let chartData = try? JSONEncoder().encode(self.chartCoordinates()) else {
            print("Error writing chart data")
            return
        }

        defaults.set(chartData, forKey: AppGroup.chartKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: MOCK DATA FOR PREVIEW & TESTING
    
    // Loading fake data for Preview Provider
    func getMockSessions() {
        let fakeSessions = MockData.allSessions.sorted(by: {$0.date > $1.date})
        self.sessions = fakeSessions
    }
    
    // Loading fake locations so our filtered views can work correctly
    func getMockLocations() {
            let fakeLocations = MockData.allLocations
            self.locations = fakeLocations
    }
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let daysOfWeekAbbreviated = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}
