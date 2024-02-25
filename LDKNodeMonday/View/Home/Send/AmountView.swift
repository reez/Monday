//
//  AmountView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/24/24.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct AmountView: View {
    @Bindable var viewModel: AmountViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var address: String = ""
    @State var numpadAmount = "0"
    @State var parseError: MondayError?
    @State var payment: Payment = .isNone
    @State private var showingAmountViewErrorAlert = false
    let pasteboard = UIPasteboard.general
    var spendableBalance: UInt64

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: .systemBackground)

                VStack(spacing: 20) {

                    HStack {

                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .minimumScaleFactor(0.5)
                        }

                        Spacer()

                        //                        Button {
                        //                            if pasteboard.hasStrings {
                        //                                if let string = pasteboard.string {
                        //
                        //                                    let scanString = string.lowercased()
                        //
                        //                                    if scanString.starts(with: "ln") {
                        //                                        if let amount = scanString.bolt11amount() {
                        //                                            numpadAmount = amount
                        //                                        }
                        //                                        address = scanString
                        //                                        payment = .isLightning
                        //                                    } else if scanString.hasPrefix("lightning:") {
                        //                                        address = ""
                        //                                        numpadAmount = ""
                        //
                        //                                        let invoiceScanned = scanString.replacingOccurrences(
                        //                                            of: "lightning:",
                        //                                            with: ""
                        //                                        )
                        //
                        //                                        let a = extractInvoiceAndAmount(from: invoiceScanned)
                        //                                        let invoice = a.invoice
                        //
                        //                                        if let unwrappedInvoice = invoice {
                        //                                            address = unwrappedInvoice
                        //                                            payment = .isLightning
                        //                                        }
                        //
                        //                                        if let a = invoiceScanned.bolt11amount() {
                        //                                            numpadAmount = a
                        //                                            payment = .isLightning
                        //                                        }
                        //
                        //                                    } else if scanString.hasPrefix("bitcoin:") {
                        //                                        address = ""
                        //                                        numpadAmount = ""
                        //
                        //                                        if let invoice = extractInvoiceFromBIP21(scanString) {
                        //
                        //                                            if let amount = invoice.bolt11amount() {
                        //                                                address = invoice
                        //                                                numpadAmount = amount
                        //                                                payment = .isBitcoin
                        //                                            } else {
                        //                                                // TODO: handle this
                        //                                            }
                        //
                        //                                        } else {
                        //                                            // not a bip21
                        //                                            let addressScanned = scanString.replacingOccurrences(
                        //                                                of: "bitcoin:",
                        //                                                with: ""
                        //                                            )
                        //                                            address = addressScanned
                        //                                            numpadAmount = String(spendableBalance)
                        //                                            payment = .isBitcoin
                        //                                        }
                        //
                        //                                    } else if isValidBitcoinAddress(scanString) {
                        //                                        address = scanString
                        //                                        numpadAmount = String(spendableBalance)
                        //                                        payment = .isBitcoin
                        //                                    } else {
                        //                                        self.parseError = .init(
                        //                                            title: "Scan Error",
                        //                                            detail: "Unsupported paste format"
                        //                                        )
                        //                                    }
                        //
                        //                                } else {
                        //                                    // TODO: handle error no string
                        //                                }
                        //                            } else {
                        //                                // TODO: handle error no strings
                        //                            }
                        //                        } label: {
                        //                            HStack {
                        //                                Image(systemName: "doc.on.doc")
                        //                                    .minimumScaleFactor(0.5)
                        //                            }
                        //                        }

                        Button {
                            if pasteboard.hasStrings, let string = pasteboard.string {
                                let (extractedAddress, extractedAmount, extractedPayment) =
                                    string.extractPaymentInfo(spendableBalance: spendableBalance)
                                address = extractedAddress
                                numpadAmount = extractedAmount
                                payment = extractedPayment
                                if extractedPayment == .isNone {
                                    self.parseError = .init(
                                        title: "Scan Error",
                                        detail: "Unsupported paste format"
                                    )
                                }
                            } else {
                                self.parseError = .init(
                                    title: "Pasteboard Error",
                                    detail: "No address found in pasteboard"
                                )
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .minimumScaleFactor(0.5)
                            }
                        }

                    }
                    .padding(.top, 40.0)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))
                    .sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(
                            codeTypes: [.qr],
                            simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                            completion: handleScan
                        )
                    }

                    Spacer()

                    VStack {
                        Text("\(numpadAmount.formattedAmountZero()) sats")
                            .textStyle(BitcoinTitle1())
                        Text(address)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .fontWeight(.semibold)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    GeometryReader { geometry in
                        let buttonSize = geometry.size.width / 4
                        VStack(spacing: buttonSize / 10) {
                            numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                            numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                            numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                            numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 300)

                    Spacer()

                    Button {
                        Task {
                            switch payment {
                            case .isLightning:

                                if address.bolt11amount() == "0" {
                                    if let amountSats = UInt64(numpadAmount) {
                                        let amountMsat = amountSats * 1000
                                        await viewModel.sendPaymentUsingAmount(
                                            invoice: address,
                                            amountMsat: amountMsat
                                        )

                                    } else {
                                        viewModel.amountConfirmationViewError = .init(
                                            title: "Unexpected error",
                                            detail: "Invalid amount entered"
                                        )
                                    }
                                } else {
                                    await viewModel.sendPayment(invoice: address)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }

                            case .isBitcoin:
                                await viewModel.sendAllToOnchain(address: address)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            case .isLightningURL:
                                viewModel.amountConfirmationViewError = .init(
                                    title: "LNURL Error",
                                    detail: "LNURL not supported yet"
                                )
                            case .isNone:
                                print("not sure")
                            }
                        }

                    } label: {
                        Text("Send")
                            .bold()
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            .frame(maxWidth: .infinity)
                            .padding(.all, 8)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.networkColor)
                    .frame(width: 300, height: 25)
                    .padding()
                    .padding(.bottom, 20.0)

                }
                .padding()
                .onAppear {
                    viewModel.getColor()
                }
                .alert(isPresented: $showingAmountViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.amountConfirmationViewError?.title ?? "Unknown"),
                        message: Text(viewModel.amountConfirmationViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.amountConfirmationViewError = nil
                        }
                    )
                }

            }

        }

    }

}

//extension AmountView {
//    func handleScan(result: Result<ScanResult, ScanError>) {
//        isShowingScanner = false
//        switch result {
//        case .success(let result):
//
//            let scanString = result.string.lowercased()
//
//            if scanString.starts(with: "ln") {
//                if let amount = scanString.bolt11amount() {
//                    numpadAmount = amount
//                }
//                address = scanString
//                payment = .isLightning
//            } else if scanString.hasPrefix("lightning:") {
//                address = ""
//                numpadAmount = ""
//
//                let invoiceScanned = scanString.replacingOccurrences(of: "lightning:", with: "")
//
//                let a = extractInvoiceAndAmount(from: invoiceScanned)
//                let invoice = a.invoice
//
//                if let unwrappedInvoice = invoice {
//                    address = unwrappedInvoice
//                    payment = .isLightning
//                }
//
//                if let a = invoiceScanned.bolt11amount() {
//                    numpadAmount = a
//                    payment = .isLightning
//                }
//
//            } else if scanString.hasPrefix("bitcoin:") {
//                address = ""
//                numpadAmount = ""
//
//                if let invoice = extractInvoiceFromBIP21(scanString) {
//
//                    if let amount = invoice.bolt11amount() {
//                        address = invoice
//                        numpadAmount = amount
//                        payment = .isBitcoin
//                    } else {
//                        // TODO: handle this
//                    }
//
//                } else {
//                    let addressScanned = scanString.replacingOccurrences(of: "bitcoin:", with: "")
//                    address = addressScanned
//                    numpadAmount = String(spendableBalance)
//                    payment = .isBitcoin
//                }
//
//            } else if isValidBitcoinAddress(scanString) {
//                address = scanString
//                numpadAmount = String(spendableBalance)
//                payment = .isBitcoin
//            } else {
//                self.parseError = .init(
//                    title: "Scan Error",
//                    detail: "Unsupported scan format"
//                )
//            }
//
//        case .failure(_):
//            print("TODO: handle error")
//        }
//    }
//
//    private func processLightningInvoice(_ invoice: String) {
//        let result = extractInvoiceAndAmount(from: invoice)
//        address = result.invoice ?? "No address found"
//        if let amount = result.amount {
//            numpadAmount = String(amount)
//        }
//    }
//
//    private func processBitcoinUri(_ uri: String) {
//        if let invoice = extractInvoiceFromBIP21(uri) {
//            address = invoice
//        } else {
//            address = uri.replacingOccurrences(of: "bitcoin:", with: "")
//        }
//    }
//
//    private func extractInvoiceFromBIP21(_ scanString: String) -> String? {
//        if let url = URL(string: scanString),
//            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
//            let queryItems = components.queryItems
//        {
//            for queryItem in queryItems {
//                if queryItem.name.lowercased() == "lightning" {
//                    return queryItem.value
//                }
//            }
//        }
//        return nil
//    }
//
//    private func extractInvoiceFromScan(_ scanString: String) -> String? {
//        // testnet (lntb, lntbrt, lntbs), regtest (lnbcrt, lntbrt), and signet (lnbcs, lntbs)
//        let prefixOptions = ["lnbc", "lntb", "lnbcrt", "lntbrt", "lnbcs", "lntbs"]
//        for prefix in prefixOptions {
//            if scanString.hasPrefix(prefix) {
//                return scanString
//            }
//        }
//        return nil
//    }
//
//    private func extractInvoiceAndAmount(from scanString: String) -> (
//        invoice: String?, amount: Int?
//    ) {
//        let prefixOptions = ["lnbc", "lntb", "lnbcrt", "lntbrt", "lnbcs", "lntbs"]
//        var amount: Int? = nil
//        var matchedPrefix: String? = nil
//
//        for prefix in prefixOptions {
//            if scanString.hasPrefix(prefix) {
//                matchedPrefix = prefix
//                break
//            }
//        }
//
//        guard let prefix = matchedPrefix else { return (nil, nil) }
//
//        let noPrefixString = String(scanString.dropFirst(prefix.count))
//
//        if let rangeOf1 = noPrefixString.firstIndex(of: "1") {
//            let potentialAmount = noPrefixString[..<rangeOf1]
//            if let numericAmount = Int(potentialAmount) {
//                amount = numericAmount
//            }
//        }
//
//        return (scanString, amount)
//    }
//
//    func isValidBitcoinAddress(_ address: String) -> Bool {
//        let patterns = [
//            "^1[a-km-zA-HJ-NP-Z1-9]{25,34}$",  // P2PKH Mainnet
//            "^[mn2][a-km-zA-HJ-NP-Z1-9]{33}$",  // P2PKH or P2SH Testnet
//            "^bc1[qzp][a-z0-9]{38,}$",  // Bech32 Mainnet
//            "^tb1[qzp][a-z0-9]{38,}$",  // Bech32 Testnet
//        ]
//
//        for pattern in patterns {
//            if address.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil {
//                return true
//            } else {
//                // TODO: handle
//            }
//        }
//
//        return false
//    }
//
//}

extension AmountView {
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let scanResult):
            let scanString = scanResult.string
            let (extractedAddress, extractedAmount, extractedPayment) =
                scanString.extractPaymentInfo(spendableBalance: spendableBalance)
            address = extractedAddress
            numpadAmount = extractedAmount
            payment = extractedPayment

            if extractedPayment == .isNone {
                self.parseError = .init(title: "Scan Error", detail: "Unsupported scan format")
            }

        case .failure(let scanError):
            self.parseError = .init(title: "Scan Error", detail: scanError.localizedDescription)
        }
    }
}

extension AmountView {
    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize / 1.5)
            }
        }
    }
}

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    var body: some View {
        Button {
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            Text(character).textStyle(BitcoinTitle3())
        }
    }
}

#Preview {
    AmountView(viewModel: .init(), spendableBalance: UInt64(21000))
}
