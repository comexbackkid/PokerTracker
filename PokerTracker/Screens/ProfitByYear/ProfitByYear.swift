//
//  ProfitByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/4/22.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ProfitByYear: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    @StateObject var vm: AnnualReportViewModel
    @StateObject var exportUtility = CSVConversion()
    
    @State private var showError: Bool = false
    @State private var showPaywall = false
    @State private var sessionFilter: SessionFilter = .all
    
    var body: some View {

        ScrollView {
            
            HStack {
                Text("Annual Report")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            VStack {
                
                lineChart

                CustomPicker(vm: vm)
                    .padding(.bottom, 35)
                    .padding(.top)
                
                incomeReport
                
                bestPlays
                
                barChart
                
                exportButton
                
                Spacer()
            }
            .padding(.bottom, 50)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
    }
    
    var lineChart: some View {
        
        VStack {
            
            let year = vm.chartRange(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            if year.isEmpty {
                
                VStack {
                    Image("bargraphvector-transparent")
                        .resizable()
                        .frame(width: 125, height: 125)
                    
                    Text("No Sessions")
                        .cardTitleStyle()
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                .animation(nil, value: year)
                .frame(height: 250)
                .padding(.vertical)
                
            } else {
                
                BankrollLineChart(yearSelection: year, showTitle: false, showYAxis: true, showRangeSelector: false, overlayAnnotation: true)
                    .animation(nil, value: year)
                    .padding(.horizontal, 30)
                    .frame(height: 250)
                    .padding(.vertical)
            }
        }
    }
    
    var headerInfo: some View {
        
        VStack {
            
            HStack {
                Text("Session Type")
                    .bodyStyle()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $sessionFilter) {
                        ForEach(SessionFilter.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                } label: {
                    Text(sessionFilter.description + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
    }
    
    var incomeReport: some View {
        
        VStack (spacing: 12) {
            
            headerInfo
            
            Divider().padding(.vertical)
            
            switch sessionFilter {
            case .all:
                allGamesReport
            case .cash:
                cashReport
            case .tournaments:
                tournamentReport
            }
            
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .lineSpacing(2.5)
        .animation(nil, value: vm.pickerSelection)
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        
    }
    
    var allGamesReport: some View {
        
        VStack (spacing: 12) {
            
            let grossIncome = vm.grossIncome(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalExpenses = vm.expensesByYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let netProfitTotal = grossIncome - totalExpenses
            let hourlyRate = vm.hourlyCalc(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let profitPerSession = vm.avgProfit(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let winRatio = vm.winRatio(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalHours = vm.totalHours(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalSessions = vm.sessionsPerYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let bestProfit = vm.bestProfit(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let roi = vm.returnOnInvestmentPerYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            HStack {
                Text("Gross Income")
                
                Spacer()
                Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: grossIncome)
            }
            
            HStack {
                Text("Expenses")
                
                Spacer()
                Text(totalExpenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(totalExpenses > 0 ? .red : Color(.systemGray))
            }
            
            if sessionFilter == .all {
                HStack {
                    Text("(Includes Tournament Buy Ins)")
                        .captionStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                Text(netProfitTotal, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfitTotal)
            }
            
            Divider().padding(.vertical)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                Text(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: hourlyRate)
            }
            
            HStack {
                Text("Profit Per Session")
                
                Spacer()
                Text(profitPerSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitPerSession)
            }
            
            HStack {
                Text("Biggest Session")
                
                Spacer()
                Text(bestProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bestProfit)
            }
            
            HStack {
                Text("Win Ratio")
                
                Spacer()
                Text(winRatio)
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                Text(totalSessions)
            }
            
            HStack {
                Text("ROI")
                
                Spacer()
                Text(roi)
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                Text(totalHours)
            }
        }
    }
    
    var cashReport: some View {
        
        VStack (spacing: 12) {
            
            let grossIncome = vm.grossIncome(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalExpenses = vm.expensesByYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let netProfitTotal = grossIncome - totalExpenses
            let hourlyRate = vm.hourlyCalc(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let profitPerSession = vm.avgProfit(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let winRatio = vm.winRatio(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalHours = vm.totalHours(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalSessions = vm.sessionsPerYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let bestProfit = vm.bestProfit(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            HStack {
                Text("Gross Income")
                
                Spacer()
                Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: grossIncome)
            }
            
            HStack {
                Text("Expenses")
                
                Spacer()
                Text(totalExpenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(totalExpenses > 0 ? .red : Color(.systemGray))
            }
            
            if sessionFilter == .all {
                HStack {
                    Text("(Includes Tournament Buy Ins)")
                        .captionStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                }
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                Text(netProfitTotal, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfitTotal)
            }
            
            Divider().padding(.vertical)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                Text(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: hourlyRate)
            }
            
            HStack {
                Text("Profit Per Session")
                
                Spacer()
                Text(profitPerSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitPerSession)
            }
            
            HStack {
                Text("Biggest Session")
                
                Spacer()
                Text(bestProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bestProfit)
            }
            
            HStack {
                Text("Win Ratio")
                
                Spacer()
                Text(winRatio)
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                Text(totalSessions)
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                Text(totalHours)
            }
        }
    }
    
    var tournamentReport: some View {
        
        VStack (spacing: 12) {
            
            let grossIncome = vm.grossIncome(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalExpenses = vm.expensesByYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let netProfitTotal = grossIncome - totalExpenses
            let hourlyRate = vm.hourlyCalc(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let winRatio = vm.winRatio(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalHours = vm.totalHours(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let totalSessions = vm.sessionsPerYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let bestProfit = vm.bestProfit(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            let roi = vm.returnOnInvestmentPerYear(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            HStack {
                Text("Gross Income")
                
                Spacer()
                Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: grossIncome)
            }
            
            HStack {
                Text("Total Buy Ins")
                
                Spacer()
                Text(totalExpenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(totalExpenses > 0 ? .red : Color(.systemGray))
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                Text(netProfitTotal, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfitTotal)
            }
            
            Divider().padding(.vertical)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                Text(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: hourlyRate)
            }
            
            HStack {
                Text("Biggest Win")
                
                Spacer()
                Text(bestProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bestProfit)
            }
            
            HStack {
                Text("ITM Ratio")
                
                Spacer()
                Text(winRatio)
            }
            
            HStack {
                Text("ROI")
                
                Spacer()
                Text(roi)
            }
            
            HStack {
                Text("No. of Entries")
                
                Spacer()
                Text(totalSessions)
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                Text(totalHours)
            }
        }
    }
    
    var barChart: some View {
        
        VStack {
            
            let dateRange = vm.chartRange(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            BarChartWeeklySessionCount(showTitle: true, dateRange: dateRange)
                .padding(30)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 220)
                .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                .padding(.top, 20)
                .overlay {
                    if dateRange.isEmpty {
                        VStack {
                            Text("No chart data to display.")
                                .calloutStyle()
                                .foregroundStyle(.secondary)
                        }
                        .offset(y: 20)
                    }
                }
        }
        
    }
    
    var bestPlays: some View {
        
        VStack (spacing: 30) {
            
            let bestLocation = vm.bestLocation(timeline: vm.pickerSelection, sessionFilter: sessionFilter)
            
            BestLocationView(location: bestLocation ?? DefaultData.defaultLocation)

        }
        .animation(nil, value: vm.pickerSelection)
        .padding(.top, 20)
    }
    
    var exportButton: some View {
        
        Button {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            if subManager.isSubscribed {
                do {
                    
                    let fileURL = try CSVConversion.exportCSV(from: viewModel.allSessionDataByYear(year: vm.lastYear))
                    shareFile(fileURL)
                    
                } catch {
                    
                    exportUtility.errorMsg = "\(error.localizedDescription)"
                    showError.toggle()
                }
            } else {
                
                showPaywall = true
                
            }
            
        } label: {
            PrimaryButton(title: "Export as CSV")
        }
        .padding(.top)
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"), message: Text(exportUtility.errorMsg ?? ""), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                .dynamicTypeSize(.medium...DynamicTypeSize.large)
                .overlay {
                    HStack {
                        Spacer()
                        VStack {
                            DismissButton()
                                .padding()
                                .onTapGesture {
                                    showPaywall = false
                            }
                            Spacer()
                        }
                    }
                }
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }

    func shareFile(_ fileURL: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(vm: AnnualReportViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}
