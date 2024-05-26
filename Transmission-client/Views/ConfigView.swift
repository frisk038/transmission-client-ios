//
//  ConfigView.swift
//  Transmission-client
//
//  Created by Olivier on 18/05/2024.
//

import SwiftUI
import SwiftData

struct ConfigView: View {
    var api:TransmissionRPC
    
    @State var showAlert:Bool = false
    @State var editPass: String
    @State var editUrl: String
    @State var editUser: String
    @State var editSpeed: FetchSpeed

    
    var body: some View {
        VStack {
            Form{
                Section("server") {
                    TextField("Host", text: $editUrl)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    TextField("User", text: $editUser)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    TextField("Password", text: $editPass)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    Button("Save", systemImage: "square.and.arrow.down") {
                        guard let url = URL(string: editUrl) else { return }
                        api.config.url = url
                        api.config.user = editUser
                        api.config.password = editPass
                        showAlert = true
                    }.alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Your configuration has been saved"),
                            message: Text("You can now see the torrent list in Torrents section")
                            
                        )
                    }
                }
                Section("client") {
                    HStack{
                        Image(systemName: "tortoise")
                        Picker("Speed", selection: $editSpeed) {
                            Text("slow").tag(FetchSpeed.slow)
                            Text("normal").tag(FetchSpeed.normal)
                            Text("fast").tag(FetchSpeed.fast)
                        }.pickerStyle(.segmented)
                        Image(systemName: "hare")
                    }
                    Button("Save", systemImage: "square.and.arrow.down") {
                        api.config.speed = editSpeed
                        api.startFetchingTorrentList()
                        showAlert = true
                    }.alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Your configuration has been saved"),
                            message: Text("You can now see the torrent list in Torrents section")
                            
                        )
                    }
                }
            }
        }
    }
    
    init(api: TransmissionRPC) {
        self.api = api
        editUrl = api.config.url.absoluteString
        editPass = api.config.password
        editUser = api.config.user
        editSpeed = api.config.speed
    }
}

#Preview {
    ConfigView(api: TransmissionRPC(mct: try! ModelContainer(for: Item.self, configurations: ModelConfiguration())))
}
