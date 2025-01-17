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
    @State private var payment: Payment = .isNone
    @Binding var navigationPath: NavigationPath
    let pasteboard = UIPasteboard.general
    var spendableBalance: UInt64

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .edgesIgnoringSafeArea(.all)

            CustomScannerView(
                codeTypes: [.qr],
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

            if extractedPayment == .isNone {
                alertMessage = "Unsupported scan format"
                isShowingAlert = true
            } else {
                navigationPath.append(
                    NavigationDestination.amount(
                        address: address,
                        amount: numpadAmount,
                        payment: payment
                    )
                )
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

            if extractedPayment == .isNone {
                alertMessage = "Unsupported paste format"
                isShowingAlert = true
            } else {
                navigationPath.append(
                    NavigationDestination.amount(
                        address: address,
                        amount: numpadAmount,
                        payment: payment
                    )
                )
            }
        } else {
            alertMessage = "No address found in pasteboard"
            isShowingAlert = true
        }
    }
}

struct CustomScannerView: View {
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<ScanResult, ScanError>) -> Void
    let pasteAction: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                CodeScannerView(
                    codeTypes: codeTypes,
                    shouldVibrateOnSuccess: true,
                    completion: completion
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)

                        Spacer()
                    }

                    Spacer()

                    Button(action: pasteAction) {
                        Text("Paste Payment")
                            .padding()
                            .foregroundColor(Color(uiColor: .label))
                            .background(Color(uiColor: .systemBackground).opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
    #Preview {
        AddressView(
            navigationPath: .constant(NavigationPath()),
            spendableBalance: UInt64(21)
        )
    }
#endif
