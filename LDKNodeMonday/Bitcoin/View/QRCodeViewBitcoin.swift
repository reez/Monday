//
//  QRCodeView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/26/23.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeViewBitcoin: View {
    var address: String

    var body: some View {
        Image(uiImage: generateQRCode(from: "bitcoin:\(address)"))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .padding()
    }
}

extension QRCodeViewBitcoin {
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct FidgetQRCodeViewBitcoin: View {
    @State private var viewState = CGSize.zero
    let screenBounds = UIScreen.main.bounds
    var address: String

    var body: some View {
        QRCodeViewBitcoin(address: address)
            .applyFidgetEffect(viewState: $viewState)
            .gesture(dragGesture())
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged(handleDragChanged(_:))
            .onEnded(handleDragEnded(_:))
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation
        let multiplier: CGFloat = 0.05
        viewState.width = -translation.width * multiplier
        viewState.height = -translation.height * multiplier
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        withAnimation {
            self.viewState = .zero
        }
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeViewBitcoin(address: "tb1qz9hhk2qlsmdanrzgl38uv86hqnqe5vyszrld7s")
    }
}
