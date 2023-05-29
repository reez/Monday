//
//  SendConfirmationView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 4/23/23.
//

import SwiftUI
import LightningDevKitNode

class SendConfirmationViewModel: ObservableObject {
    @Published var errorMessage: MondayNodeError?
    @Published var invoice: String = ""
    @Published var networkColor = Color.gray
    @Published var paymentHash: PaymentHash?
    
    init(invoice: String) {
        self.invoice = invoice
    }
    
    func sendPayment(invoice: Invoice) async  {
        do {
            let paymentHash = try await LightningNodeService.shared.sendPayment(invoice: invoice)
            DispatchQueue.main.async {
                self.paymentHash = paymentHash
            }
        } catch let error as NodeError {
            let errorString = handleNodeError(error)
            DispatchQueue.main.async {
                self.errorMessage = .init(title: errorString.title, detail: errorString.detail)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = .init(title: "Unexpected error", detail: error.localizedDescription)
            }
        }
    }
    
    func getColor() {
        let color = LightningNodeService.shared.networkColor
        DispatchQueue.main.async {
            self.networkColor = color
        }
    }
    
}

struct SendConfirmationView: View {
    @ObservedObject var viewModel: SendConfirmationViewModel
    @State private var showingErrorAlert = false
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                Spacer()
                
                VStack(spacing: 10) {
                    
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(viewModel.networkColor)
                    
                    Text("Sats paid")
                        .bold()
                    
                    Text("\(viewModel.invoice)")
                        .truncationMode(.middle)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                }
                .padding(.horizontal, 50.0)
                
                if let amount = viewModel.invoice.bolt11amount() {
                    Text(amount.formattedAmount())
                } else {
                    Text("Unable to Parse Formatted Amount")
                }
                
//                Text(viewModel.invoice.bolt11amount().formattedAmount())
                
                Text(viewModel.paymentHash?.description ?? "No Payment Hash")
                    .font(.caption)
                
                Spacer()
                
                VStack(spacing: 10) {
                    if let amount = viewModel.invoice.bolt11amount() {
                        Text("\(amount.formattedAmount()) sats")
                            .font(.largeTitle)
                            .bold()
                    }
//                    Text("\(viewModel.invoice.bolt11amount().formattedAmount()) sats")
//                        .font(.largeTitle)
//                        .bold()
                    
                    Text(Date.now.formattedDate())
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
            }
            .padding()
            .onAppear {
                Task {
                    await viewModel.sendPayment(invoice: viewModel.invoice)
                    viewModel.getColor()
                }
            }
            
        }
        .ignoresSafeArea()
        
    }
}

struct SendConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        SendConfirmationView(
            viewModel: .init(
                invoice: "lnbcrt500120n1pjyda0cpp5trnsfsxu96ucq6x4zgwyy9va2gr0ezuljtr8n26a8hs0anry0hmqdq62pshjmt9de6zqar0yp3kzun0dssp5quqw63ueftrzyku8zxcgcyyy972z0t2vqnj89vr22qu06f2fd6dsmqz9gxqrrsscqp79q2sqqqqqysgq8uc7st2lhhnjsmn8lrt4axjshg5xmy7v47p4hnmp0mhpsmzv346q8hjlql3sadl272f7er48gm7k3hzgmc4d3q4v2he2h3dykft0sxgppeqrtj"
            )
        )
        SendConfirmationView(
            viewModel: .init(
                invoice: "lnbcrt500120n1pjyda0cpp5trnsfsxu96ucq6x4zgwyy9va2gr0ezuljtr8n26a8hs0anry0hmqdq62pshjmt9de6zqar0yp3kzun0dssp5quqw63ueftrzyku8zxcgcyyy972z0t2vqnj89vr22qu06f2fd6dsmqz9gxqrrsscqp79q2sqqqqqysgq8uc7st2lhhnjsmn8lrt4axjshg5xmy7v47p4hnmp0mhpsmzv346q8hjlql3sadl272f7er48gm7k3hzgmc4d3q4v2he2h3dykft0sxgppeqrtj"
            )
        )
        .environment(\.colorScheme, .dark)
    }
}
