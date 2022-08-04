//
//  StudyDetailView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/3/22.
//

import SwiftUI

struct StudyDetailView: View {
    
    @Binding var selectedArticle: Article
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            ScrollView {
                VStack {
                    Image(selectedArticle.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 240)
                        .padding(.bottom)
                    
                    VStack (alignment: .leading) {
                        Text(selectedArticle.title)
                            .font(.title)
                            .bold()
                        
                        Text(selectedArticle.story)
                            .font(.body)
                            .padding(.vertical, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    DismissButton()
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                        .onTapGesture {
                            dismiss()
                        }
                }
                Spacer()
            }
        }
    }
}

struct StudyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StudyDetailView(selectedArticle: .constant(MockData.sampleArticle))
            .preferredColorScheme(.dark)
    }
}
