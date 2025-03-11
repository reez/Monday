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
    @State private var numpadAmount = "0"
    @State private var payment: PaymentAddress?
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
            let (_, extractedAmount, extractedPayment) =
                scanString.extractPaymentInfo(spendableBalance: spendableBalance)
            address = scanString
            numpadAmount = extractedAmount
            payment = extractedPayment

            if extractedPayment == .none {
                alertMessage = "Unsupported scan format"
                isShowingAlert = true
            } else {
                sendViewState = .manual
//                navigationPath.append(
//                    NavigationDestination.amount(
//                        address: address,
//                        amount: numpadAmount,
//                        payment: payment
//                    )
//                )
            }

        case .failure(let scanError):
            alertMessage = "Scan Error: \(scanError.localizedDescription)"
            isShowingAlert = true
        }
    }

    private func pasteAddress() {
        if pasteboard.hasStrings, let string = pasteboard.string {
            let (extractedAddress, extractedAmount, extractedPayment) =
                string.extractPaymentInfo(spendableBalance: spendableBalance)
            address = extractedAddress
            numpadAmount = extractedAmount
            payment = extractedPayment

            if extractedPayment == .none {
                alertMessage = "Unsupported paste format"
                isShowingAlert = true
            } else {
                sendViewState = .manual
//                navigationPath.append(
//                    NavigationDestination.amount(
//                        address: address,
//                        amount: numpadAmount,
//                        payment: payment
//                    )
//                )
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
                    }.buttonStyle(BitcoinFilled(width: 150, tintColor: .white, textColor: .black, isCapsule: true))
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 60)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        AddressView(
            sendViewState: .constant(.camera),
            spendableBalance: UInt64(21)
        )
    }
#endif
