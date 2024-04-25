//
//  ProfitByLocationView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 10/6/21.
//

import SwiftUI
import RevenueCatUI
import RevenueCat


struct ProfitByLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var yearFilter = Date().getYear()
    @State private var metricFilter = "Total"
    @State private var showPaywall = false
    
    @EnvironmentObject var subManager: SubscriptionManager
    
    @ObservedObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ScrollView {
            
            ZStack {
                VStack {
                    
                    if viewModel.sessions.isEmpty {
                        
                        EmptyState(image: .locations)
                        
                    } else {

                        VStack (spacing: 10) {
                            
                            headerInfo
                            
                            Divider()
                                .padding(.bottom, 10)
                            
                            locationTotals
                            
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle(Text("Location Statistics"))
                        .padding(30)
                        .frame(width: UIScreen.main.bounds.width * 0.9)
                        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                        .cornerRadius(20)
                        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                        .padding(.top, 50)
                        
                        yearTotal
                        
                        if subManager.isSubscribed {
                            locationWinRatesChart
                        } else {
                            locationWinRatesChart
                                .blur(radius: 8)
                                .overlay {
                                    Button {
                                       showPaywall = true
                                        
                                    } label: {
                                        Text("Upgrade for Access")
                                            .buttonTextStyle()
                                            .frame(height: 55)
                                            .frame(width: UIScreen.main.bounds.width * 0.7)
                                            .background(Color.brandPrimary)
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                    }
                                }
                        }
                    }
                    
                    HStack {
                        Spacer()
                    }
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
                        .dynamicTypeSize(.medium...DynamicTypeSize.large)
                }
                .task {
                    for await customerInfo in Purchases.shared.customerInfoStream {
                        showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                        await subManager.checkSubscriptionStatus()
                    }
                }
            }
            .padding(.bottom, 60)
        }
        .background(Color.brandBackground)
    }
    
    var headerInfo: some View {
        
        VStack (spacing: 7) {
            
            HStack {
                Text("Select Year")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                let allYears = viewModel.sessions.map({ $0.date.getYear() }).uniqued()
                
                Menu {
                    Picker("", selection: $yearFilter) {
                        ForEach(allYears, id: \.self) {
                            Text($0)
                        }
                    }
                } label: {
                    Text(yearFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
            
            HStack {
                Text("Select Metric")
                    .bodyStyle()
                    .bold()
                
                Spacer()
                
                Menu {
                    Picker("", selection: $metricFilter) {
                        Text("Total").tag("Total")
                        Text("Hourly").tag("Hourly")
                    }
                } label: {
                    Text(metricFilter + " ›")
                        .bodyStyle()
                }
                .accentColor(Color.brandPrimary)
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    var locationTotals: some View {
        
        VStack (spacing: 10) {
            
            let locationList = viewModel.sessions.map({ $0.location.name }).uniqued()
            
            ForEach(locationList, id: \.self) { location in
                HStack (spacing: 0) {
                    Text(location)
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Still won't grab data if Sessions are imported from a CSV
                    let filteredByYear = viewModel.sessions.filter({ $0.date.getYear() == yearFilter })
                    let total = filteredByYear.filter({ $0.location.name == location }).map({ $0.profit }).reduce(0,+)
                    let hourlyRate = filteredByYear.filter({ $0.location.name == location }).map({ $0.hourlyRate }).reduce(0,+)
                    
                    if metricFilter == "Total" {
                        Text(total, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                            .profitColor(total: total)
                            .frame(width: 80, alignment: .trailing)
                    } else {
                        Text("\(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0))) / hr")
                            .profitColor(total: hourlyRate)
                            .frame(width: 80, alignment: .trailing)
                    }
                    
                }
                .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
            }
        }
    }
    
    var yearTotal: some View {
        
        VStack (spacing: 7) {
            
            let bankrollTotalByYear = viewModel.bankrollByYear(year: yearFilter)
            
            HStack {
                Image(systemName: "trophy.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Total")
                    
                Spacer()
                
                Text(bankrollTotalByYear, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: bankrollTotalByYear)
            }
            
            HStack {
                Image(systemName: "suit.club.fill")
                    .frame(width: 20)
                    .foregroundColor(Color(.systemGray))
                
                Text("Sessions")
                
                Spacer()
                
                Text("\(viewModel.sessions.filter({ $0.date.getYear() == yearFilter }).count)")
                    .bodyStyle()
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        .padding(.top, 15)
    }
    
    var locationWinRatesChart: some View {
        
        RingCharts(viewModel: viewModel, yearFilter: $yearFilter)
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            .padding(.top, 15)
        
    }
}

struct ProfitByLocationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfitByLocationView(viewModel: SessionsListViewModel())
                .environmentObject(SubscriptionManager())
                .preferredColorScheme(.dark)
        }
    }
}
