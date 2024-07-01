//
//  ShareButton.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/24.
//

import SwiftUI

struct ShareButton: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 38, height: 38)
                .foregroundColor(.white)
                .opacity(0.6)
            
            Image(systemName: "square.and.arrow.down")
//                .imageScale(.large)
                .fontWeight(.medium)
                .frame(width: 40, height: 40)
                .foregroundColor(.black)
                .offset(y: -2)
        }
    }
}

#Preview {
    ShareButton()
        .preferredColorScheme(.dark)
}
