//
//  ChannelsListView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import BitcoinUI
import SimpleToast
import SwiftUI

struct ChannelsListView: View {
    @ObservedObject var viewModel: ChannelsListViewModel
    @State private var isSendPresented = false
    @State private var isReceivePresented = false
    @State private var isViewPeersPresented = false
    @State private var isAddChannelPresented = false
    @State private var refreshFlag = false
    @State private var isPaymentsPresented = false

    @StateObject private var eventService = EventService()
    @State private var showToast = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

                VStack {

                    VStack {
                        Button {
                            isViewPeersPresented = true
                        } label: {
                            Text("View Peers")
                        }
                        .tint(viewModel.networkColor)
                        .padding()

                        Button {
                            isAddChannelPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Channel")
                            }
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            .bold()
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.networkColor)

                    }
                    .padding(.top)

                    if viewModel.channels.isEmpty {
                        Text("No Channels")
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    } else {
                        List {
                            ForEach(
                                viewModel.channels.sorted(by: {
                                    $0.channelValueSats > $1.channelValueSats
                                }),
                                id: \.self
                            ) { channel in
                                NavigationLink {
                                    ChannelDetailView(
                                        viewModel: .init(channel: channel),
                                        refreshFlag: $refreshFlag
                                    )
                                } label: {
                                    VStack {
                                        HStack(alignment: .center, spacing: 15) {
                                            ZStack {
                                                Circle()
                                                    .frame(width: 50.0, height: 50.0)
                                                    .foregroundColor(viewModel.networkColor)
                                                Image(systemName: "person.line.dotted.person")
                                                    .font(.subheadline)
                                                    .foregroundColor(
                                                        Color(uiColor: .systemBackground)
                                                    )
                                                    .bold()
                                            }
                                            VStack(alignment: .leading, spacing: 5.0) {
                                                Text("\(channel.channelValueSats) sats ")
                                                    .font(.caption)
                                                    .bold()
                                                Text(channel.counterpartyNodeId)
                                                    .font(.caption)
                                                    .truncationMode(.middle)
                                                    .lineLimit(1)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.listChannels()
                        }
                    }

                    Button {
                        isPaymentsPresented = true
                    } label: {
                        Text("View Payments")
                    }
                    .tint(viewModel.networkColor)
                    .padding()

                    Spacer()

                    HStack {
                        Button {
                            isSendPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                Text("Send")
                            }
                            .frame(width: 100)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)

                        Spacer()
                        Button {
                            isReceivePresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down")
                                Text("Receive")
                            }
                            .frame(width: 100)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)
                    }
                    .padding()

                }
                .padding()
                .navigationTitle(
                    "\(viewModel.channels.count) \(viewModel.channels.count == 1 ? "Channel" : "Channels")"
                )
                .onAppear {
                    viewModel.listChannels()
                    viewModel.getColor()
                    if refreshFlag {
                        viewModel.listChannels()
                        refreshFlag = false
                    }
                }
                .simpleToast(
                    isPresented: $showToast,
                    options: .init(
                        hideAfter: 2.5,
                        animation: .spring,
                        modifierType: .slide
                    )
                ) {
                    Text(eventService.lastMessage ?? "")
                        .padding()
                        .background(
                            Capsule()
                                .foregroundColor(
                                    Color(
                                        uiColor:
                                            colorScheme == .dark
                                            ? .secondarySystemBackground : .systemGray6
                                    )
                                )
                        )
                        .foregroundColor(Color.primary)
                        .font(.caption2)
                }
                .onChange(
                    of: eventService.lastMessage,
                    { oldValue, newValue in
                        showToast = eventService.lastMessage != nil
                    }
                )
                .sheet(
                    isPresented: $isSendPresented,
                    onDismiss: {
                        viewModel.listChannels()
                    }
                ) {
                    SendView(viewModel: .init())
                        .presentationDetents([.medium])
                }
                .sheet(
                    isPresented: $isReceivePresented,
                    onDismiss: {
                        viewModel.listChannels()
                    }
                ) {
                    ReceiveView(viewModel: .init())
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(
                    isPresented: $isViewPeersPresented,
                    onDismiss: {
                        viewModel.listChannels()
                    }
                ) {
                    PeersListView(viewModel: .init())
                        .presentationDetents([.medium])
                }
                .sheet(
                    isPresented: $isAddChannelPresented,
                    onDismiss: {
                        viewModel.listChannels()
                    }
                ) {
                    ChannelAddView(viewModel: .init())
                        .presentationDetents([.medium])
                }
                .sheet(
                    isPresented: $isPaymentsPresented,
                    onDismiss: {
                        viewModel.listChannels()
                    }
                ) {
                    PaymentsView(viewModel: .init())
                        .presentationDetents([.medium, .large])
                }

            }

        }

    }

}

struct ChannelsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelsListView(viewModel: .init())
        ChannelsListView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
