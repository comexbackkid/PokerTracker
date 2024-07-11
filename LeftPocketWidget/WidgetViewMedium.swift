//
//  WidgetViewMedium.swift
//  LeftPocketWidgetExtension
//
//  Created by Christian Nachtrieb on 8/11/22.
//

import SwiftUI
import WidgetKit
import Charts

struct WidgetViewMedium: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var entry: SimpleEntry
    
    var body: some View {
        
        ZStack (alignment: .bottom) {
            
            backgroundGradient
            
            numbers
            
            swiftChart
            
            logo
            
        }
        .widgetBackground(Color.clear)
    }
    
    var backgroundGradient: some View {
        Color("WidgetBackground")
            .overlay(LinearGradient(colors: [Color("WidgetBackround"), .black.opacity(colorScheme == .dark ? 0.8 : 0.1)],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading))
    }
    
    var numbers: some View {
        
        VStack {
            
            HStack(spacing: 40) {
                
                VStack(alignment: .leading) {
                    
                    Text("Hourly Rate")
                        .foregroundColor(.secondary)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                    
                    Text(entry.hourlyRate, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                        .foregroundColor(.widgetForegroundText)
                        .font(.custom("Asap-Medium", size: 18, relativeTo: .caption2))
                }
                
                VStack (alignment: .leading) {
                    
                    Text("Sessions")
                        .foregroundColor(.secondary)
                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                    
                    Text("\(entry.totalSessions)")
                        .foregroundColor(.widgetForegroundText)
                        .font(.custom("Asap-Medium", size: 18, relativeTo: .caption2))
                }
                
                Spacer()
            }
            .padding(.top, 12)
            
            Spacer()

            HStack {
                Text("My Bankroll")
                    .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                    .foregroundColor(.secondary)

                Spacer()
            }
            HStack {
                Text(entry.bankroll, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(.widgetForegroundText)
                    .font(.custom("Asap-Bold", size: 28, relativeTo: .title3))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Spacer()
            }
            
            HStack {
                
                if entry.recentSessionAmount != 0 {
                    Image(systemName: "arrow.up.right")
                        .resizable()
                        .frame(width: 11, height: 11)
                        .foregroundColor(entry.recentSessionAmount > 0 ? .green : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                        .rotationEffect(entry.recentSessionAmount >= 0 ? .degrees(0) : .degrees(90))
                }
                
                Text(entry.recentSessionAmount, format: .currency(code: entry.currency).precision(.fractionLength(0)))
                    .foregroundColor(entry.recentSessionAmount > 0 ? .green : entry.recentSessionAmount < 0 ? .red : Color(.systemGray))
                    .font(.custom("Asap-Medium", size: 18, relativeTo: .caption2))
                
                Spacer()
            }
            .padding(.top, -18)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    var swiftChart: some View {
        
        HStack {
            Spacer()
            Chart {
                ForEach(Array(entry.swiftChartData.enumerated()), id: \.offset) { index, total in
                    
                    LineMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [.chartAccent, .chartBase], startPoint: .topTrailing, endPoint: .bottomLeading))
                        
                    
                    AreaMark(x: .value("Time", index), y: .value("Profit", total))
                        .foregroundStyle(LinearGradient(colors: [Color("lightBlue").opacity(0.4), .clear], startPoint: .top, endPoint: .bottom))
                }
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(maxWidth: 165, maxHeight: 75)
            .padding(.trailing, 15)
            .padding(.bottom, 15)
        }
    }
    
    var logo: some View {
        
        VStack {
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "suit.club.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .foregroundColor(.brandPrimary)
                                .frame(width: 34, height: 34, alignment: .center)
                    )
                }
            }
            .padding(20)
            Spacer()
        }
    }
}

struct WidgetViewMedium_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewMedium(entry: SimpleEntry(date: Date(),
                                            bankroll: 63351,
                                            recentSessionAmount: 150,
                                            swiftChartData: [0,350,220,457,900,719,333,1211,1400,1765,1500,1828,1721],
                                            hourlyRate: 32,
                                            totalSessions: 14,
                                            currency: "USD"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
        
    }
}
