//
//  SendScanAddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 8/31/24.
//

import AVFoundation
import BitcoinUI
import CodeScanner
import SwiftUI

struct SendScanAddressView: View {
    @ObservedObject var viewModel: SendViewModel
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    let pasteboard = UIPasteboard.general
    var spendableBalance: UInt64

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .edgesIgnoringSafeArea(.all)

            CustomScannerView(
                completion: handleScan,
                pasteAction: pasteAddress
            )
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
        .edgesIgnoringSafeArea(.all)
        .background(
            GeometryReader { geometry in
                Color.clear
            }
        )

    }
}

extension SendScanAddressView {

    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let scanResult):
            let scanString = scanResult.string
            let (extractedAmount, extractedPaymentAddress) =
                scanString.extractPaymentInfo(spendableBalance: spendableBalance)

            if extractedPaymentAddress == nil {
                alertMessage = "Unsupported scan format"
                isShowingAlert = true
            } else {
                viewModel.address = scanString
                viewModel.amountSat = extractedAmount
                viewModel.paymentAddress = extractedPaymentAddress

                if viewModel.amountSat == 0 {
                    withAnimation {
                        viewModel.sendViewState = .manualEntry
                    }
                } else {
                    withAnimation {
                        viewModel.sendViewState = .reviewPayment
                    }
                }
            }

        case .failure(let scanError):
            alertMessage = "Scan Error: \(scanError.localizedDescription)"
            isShowingAlert = true
        }
    }

    private func pasteAddress() {
        if pasteboard.hasStrings, let string = pasteboard.string {
            let (extractedAmount, extractedPaymentAddress) =
                string.extractPaymentInfo(spendableBalance: spendableBalance)

            if extractedPaymentAddress == nil {
                alertMessage = "Unsupported paste format"
                isShowingAlert = true
            } else {
                viewModel.address = extractedPaymentAddress?.address ?? ""
                viewModel.amountSat = extractedAmount
                viewModel.paymentAddress = extractedPaymentAddress

                withAnimation {
                    viewModel.sendViewState = .reviewPayment
                }
            }
        } else {
            alertMessage = "No address found in pasteboard"
            isShowingAlert = true
        }
    }
}

struct CustomScannerView: View {
    let completion: (Result<ScanResult, ScanError>) -> Void
    let pasteAction: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in

            ZStack(alignment: .top) {
                CodeScannerView(
                    codeTypes: [.qr],
                    shouldVibrateOnSuccess: true,
                    completion: completion
                )

                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.black.opacity(0.1))
                        .stroke(.white, lineWidth: 4)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    Spacer()

                    Button(action: pasteAction) {
                        Text("Paste Address")
                    }.buttonStyle(
                        BitcoinFilled(
                            width: 150,
                            tintColor: .white,
                            textColor: .black,
                            isCapsule: true
                        )
                    )
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 60)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        SendScanAddressView(
            viewModel: SendViewModel.init(
                lightningClient: .mock,
                sendViewState: .manualEntry,
                price: 19000.00
            ),
            spendableBalance: 21
        )
    }
#endif
