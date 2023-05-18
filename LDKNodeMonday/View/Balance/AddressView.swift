//
//  AddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class AddressViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var errorMessage: MondayNodeError?
    @Published var networkColor = Color.gray
    @Published var isAddressFinished: Bool = false

    func newFundingAddress() async {
        do {
            let address = try await LightningNodeService.shared.newFundingAddress()
            DispatchQueue.main.async {
                self.address = address
                self.isAddressFinished = true
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

struct AddressView: View {
    @ObservedObject var viewModel: AddressViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    Spacer()
                    
                    QRCodeView(address: viewModel.address)
                    
                    HStack(alignment: .center) {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(viewModel.networkColor)
                            
                            Image(systemName: "bitcoinsign")
                                .font(.title)
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .bold()
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 5.0) {
                            
                            if viewModel.isAddressFinished {
                                
                                Text("Bitcoin Network")
                                    .font(.caption)
                                    .bold()
                                
                                Text(viewModel.address)
                                    .font(.caption)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                            } else {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                            
                        }
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = viewModel.address
                            isCopied = true
                            showCheckmark = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                                showCheckmark = false
                            }
                        } label: {
                            HStack {
                                withAnimation {
                                    Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                        .font(.subheadline)
                                }
                            }
                            .bold()
                        }
                        
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .navigationTitle("Address")
                .tint(viewModel.networkColor)
                .alert(isPresented: $showingErrorAlert) {
                    Alert(
                        title: Text(viewModel.errorMessage?.title ?? "Unknown"),
                        message: Text(viewModel.errorMessage?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
                .onReceive(viewModel.$errorMessage) { errorMessage in
                    if errorMessage != nil {
                        showingErrorAlert = true
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.newFundingAddress()
                        viewModel.getColor()
                    }
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(viewModel: .init())
        AddressView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
