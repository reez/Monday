//
//  AddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import BitcoinUI
import SwiftUI

struct AddressView: View {
    @StateObject var viewModel: AddressViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingAddressViewErrorAlert = false

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

                VStack {

                    Spacer()

                    if viewModel.address != "" {
                        QRCodeView(qrCodeType: .bitcoin(viewModel.address))
                            .animation(.default, value: viewModel.address)
                    } else {
                        QRCodeView(qrCodeType: .lightning(viewModel.address))
                            .blur(radius: 15)
                    }

                    HStack(alignment: .center) {

                        VStack(alignment: .leading, spacing: 5.0) {
                            if viewModel.isAddressFinished {
                                HStack {
                                    Text("Bitcoin Network")
                                        .font(.caption)
                                        .bold()
                                }
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
                                        .font(.title2)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                            .bold()
                        }

                    }
                    .padding(.bottom, 40.0)

                }
                .padding(.all, 40.0)
                .tint(viewModel.networkColor)
                .alert(isPresented: $showingAddressViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.addressViewError?.title ?? "Unknown"),
                        message: Text(viewModel.addressViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.addressViewError = nil
                        }
                    )
                }
                .onReceive(viewModel.$addressViewError) { errorMessage in
                    if errorMessage != nil {
                        showingAddressViewErrorAlert = true
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
