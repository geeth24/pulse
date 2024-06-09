//
//  ContentView.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import SwiftUI
import SwiftData
struct ContentView: View {
   
    @StateObject var viewModel = ViewModel()
    @Query private var items: [ItemURL]
    @State var showNewURLSheet: Bool = false
    
    @State var showIpField: Bool = false
    var body: some View {
        NavigationStack{
            List{
                Section(header: Text("URL Items")) {
                    
                    
                        NavigationLink {
                            ItemURLSView()
                        } label: {
                            Text("Items")
                        }
                        
                    
                }
                Section(header: Text("Items")) {

                        ForEach(viewModel.item, id: \.self) { item in
                            VStack(alignment: .leading, spacing: 0.0){
                                Text(item.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.bottom, 8)
                                
                                Divider()
                                
                                HStack {
                                    
                                    HStack{
                                        Text(item.price)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(item.availability)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    Link(destination: URL(string: "\(item.url)")!, label: {
                                        Image(systemName: "arrow.up.right.square")
                                    })
                                    
                                    
                                    
                                    
                                }
                                .padding(.top, 8)
                            }
                            .foregroundStyle(item.availability.contains("In") ? Color("PulseGreen") : Color("PulseRed"))
                           
                        }
                    }
                
             
            }
            .listStyle(.inset)
            .toolbar(content: {
                Button{
                    showNewURLSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                
            })
            .sheet(isPresented: $showNewURLSheet, content: {
                NewURLView()
                    .presentationDetents([.height(200)])
            })
            .onAppear(){
                let urls = items.compactMap { $0.url }
                viewModel.fetchMultipleURLs(urls: urls)
                

            }
            .refreshable {
                let urls = items.compactMap { $0.url }
                viewModel.fetchMultipleURLs(urls: urls)
            }
            .navigationTitle("Pulse Tracker")
            .alert("Enter IP", isPresented: $showIpField){
                TextField("192.168.1.1", text: $viewModel.ipAddress)
                    .foregroundStyle(Color("PulseGreen"))
                Button("Ok"){
                    
                }
            }
            .onAppear(){
                if viewModel.ipAddress == ""{
                    showIpField = true
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ItemURL.self, inMemory: true)
}
