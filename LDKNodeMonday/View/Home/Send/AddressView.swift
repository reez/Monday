//
//  AddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 8/31/24.
//

import AVFoundation
import BitcoinUI
import CodeScanner
import SwiftUI

struct AddressView: View {
    @State private var address: String = ""
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @Binding var amount: UInt64
    @Binding var paymentAddress: PaymentAddress?
    @Binding var sendViewState: SendViewState
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

extension AddressView {

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
                address = scanString
                amount = extractedAmount
                paymentAddress = extractedPaymentAddress

                if amount == 0 {
                    sendViewState = .manual
                } else {
                    sendViewState = .review
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
                address = extractedPaymentAddress?.address ?? ""
                amount = extractedAmount
                paymentAddress = extractedPaymentAddress

                sendViewState = .review
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
        AddressView(
            amount: .constant(0),
            paymentAddress: .constant(nil),
            sendViewState: .constant(.camera),
            spendableBalance: 21
        )
    }
#endif
