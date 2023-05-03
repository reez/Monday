//
//  EventsView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/2/23.
//

import SwiftUI
import WalletUI

class EventsViewModel: ObservableObject {
    @Published var myEvent: LDKNodeMondayEvent = .none
    
    // TODO: pass in Event? So I can mock out with each event
    
    func getEvents() {
        LightningNodeService.shared.nextEvent()
        let ldkNodeMondayEvent = LightningNodeService.shared.ldkNodeMondayEvent
        print("getEvents called... event: \(ldkNodeMondayEvent)")
        self.myEvent = ldkNodeMondayEvent
    }
    
    func eventHandled() {
        LightningNodeService.shared.eventHandled()
        print("eventHandled called")
    }
    
}

struct EventsView: View {
    @ObservedObject var viewModel: EventsViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack(spacing: 20) {
                    
                    switch viewModel.myEvent {
                        
                    case .paymentSuccessful(let paymentSuccessful):
                        PaymentSuccessfulView(paymentSuccessful: paymentSuccessful)
                        
                    case .paymentFailed(let paymentFailed):
                        PaymentFailedView(paymentFailed: paymentFailed)
                        
                    case .paymentReceived(let paymentReceived):
                        PaymentReceivedView(paymentReceived: paymentReceived)
                        
                    case .channelReady(let channelReady):
                        ChannelReadyView(channelReady: channelReady)
                        
                    case .channelClosed(let channelClosed):
                        ChannelClosedView(channelClosed: channelClosed)
                        
                    case .none:
                        Text("Tap Next Event Button")
                            .italic()
                        
                    }
                    
                    Button("Next Event") {
                        viewModel.getEvents()
                    }
                    .buttonStyle(BitcoinOutlined())
                    
                    Button("Event Handled") {
                        viewModel.eventHandled()
                    }
                    .buttonStyle(BitcoinOutlined())
                    
                }
                .padding()
                .navigationTitle("Events")

            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(viewModel: .init())
        EventsView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
