//
//  PokerTrackerTabView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

import SwiftUI

struct PokerTrackerTabView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("systemThemeEnabled") private var systemThemeEnabled = false
    @State var shouldShowOnboarding: Bool = true

    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SessionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Sessions")
                }
            
            MetricsView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Metrics")
                }
            
            SettingsView(isDarkMode: $isDarkMode, systemThemeEnabled: $systemThemeEnabled)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear {
            SystemThemeManager
                .shared
                .handleTheme(darkMode: isDarkMode, system: systemThemeEnabled)
        }
        .accentColor(Color("brandPrimary"))
//        .preferredColorScheme(systemColorScheme == .dark ? .dark : .light)
//        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: {
            OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)
        })

    }
}

struct PokerTrackerTabView_Previews: PreviewProvider {
    static var previews: some View {
        PokerTrackerTabView().environmentObject(SessionsListViewModel())
    }
}
