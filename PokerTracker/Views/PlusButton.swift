//
//  PlusButton.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/25/21.
//

import SwiftUI

struct PlusButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(colorScheme == .dark ? .black : .systemGray6))
//                .shadow(color: .gray.opacity(colorScheme == .dark ? 0.0 : 0.2), radius: 9, x: 0, y: 0)
            
            Image(systemName: "plus")
                .imageScale(.large)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton()
//            .preferredColorScheme(.dark)
    }
}
