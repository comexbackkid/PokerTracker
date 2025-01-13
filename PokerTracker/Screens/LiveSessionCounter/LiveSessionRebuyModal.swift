//
//  LiveSessionRebuyModal.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/13/24.
//

import SwiftUI

struct LiveSessionRebuyModal: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: SessionsListViewModel
    @ObservedObject var timerViewModel: TimerViewModel
    
    @State private var alertItem: AlertItem?
    @Binding var rebuyConfirmationSound: Bool
    
    var body: some View {
        
        VStack {
            
            title
            
            VStack (spacing: 10) {
                
                instructions
                
                HStack {
                    
                    Image(systemName: "dollarsign.arrow.circlepath")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                        .frame(width: 30)
                    
                    Text("In the Game For")
                        .bodyStyle()
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Text("$\(timerViewModel.rebuyTotalForSession + (Int(timerViewModel.initialBuyInAmount) ?? 0))")
                        .bodyStyle()
                        .fontWeight(.black)
                        .foregroundStyle(.red)
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 6)
            }
            
            inputFields
            
            saveButton
           
            Spacer()
        }
        .onAppear(perform: {
            rebuyConfirmationSound = false
        })
        .dynamicTypeSize(.medium)
        .ignoresSafeArea()
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message, dismissButton: alert.dismissButton)
        }
        .onDisappear(perform: {
            timerViewModel.reBuyAmount = ""
        })
    }
    
    var title: some View {
        
        HStack {
            
            Text("Add Rebuy")
                .font(.custom("Asap-Black", size: 34))
                .bold()
                .padding(.bottom, 5)
                .padding(.top, 20)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    var instructions: some View {
        
        VStack (alignment: .leading) {
            
            HStack {
                Text("Enter your rebuy amount and then tap Add Rebuy. You can top off multiple times if you need to.")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var inputFields: some View {
        
        HStack {
            Text(vm.userCurrency.symbol)
                .font(.callout)
                .foregroundColor(timerViewModel.reBuyAmount.isEmpty ? .secondary.opacity(0.5) : .brandWhite)
            
            TextField("Rebuy / Top Off", text: $timerViewModel.reBuyAmount)
                .font(.custom("Asap-Regular", size: 17))
                .keyboardType(.numberPad)
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var saveButton: some View {
        
        Button {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            saveButtonPressed()
            rebuyConfirmationSound = true
            
        } label: { PrimaryButton(title: "Add Rebuy") }
    }
    
    private func saveButtonPressed() {
        timerViewModel.addRebuy()
        dismiss()
    }
}

#Preview {
    LiveSessionRebuyModal(timerViewModel: TimerViewModel(), rebuyConfirmationSound: .constant(false))
        .environmentObject(SessionsListViewModel())
}
