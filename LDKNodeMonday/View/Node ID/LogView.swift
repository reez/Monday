//
//  LogView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/9/23.
//

import SwiftUI

struct LogView: View {
    @State private var logFileContents = ""
    @State private var isLoading = false
    
    var logFilePath: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: documentsPath).appendingPathComponent("ldk_node.log").path
    }
    
    var body: some View {
        
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            
            VStack {
                
                Text("ldk_node.log")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gray)
                
                Text("Note: Log file deleted before each app start atm (because log file can get big and take a while to load here.)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                if isLoading {
                    
                    ProgressView()
                    
                } else {
                    
                    ScrollView {
                        Text(logFileContents)
                            .font(.system(.caption, design: .monospaced))
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.top, 10)
                    
                }
            }
            .padding()
            .background(Color.white)
            .onAppear {
                
                isLoading = true
                DispatchQueue.global(qos: .background).async {
                    if let contents = try? String(contentsOfFile: self.logFilePath, encoding: .utf8) {
                        DispatchQueue.main.async {
                            logFileContents = contents
                            isLoading = false
                        }
                    }
                }
                
            }
        }
        
    }
    
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
        LogView()
            .environment(\.colorScheme, .dark)
    }
}
