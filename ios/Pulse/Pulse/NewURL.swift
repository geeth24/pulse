//
//  NewURLView.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct NewURLView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemURL]
    
    @State var newURL: String = ""
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Text("Item URL")
                TextField("https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body", text: $newURL)
                     // Then apply
                    .keyboardType(.webSearch)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                   
                   
            }
            .padding()
            
                .toolbar(content: {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                })
        }
    }

    
    private func addItem() {
        print(newURL)
        withAnimation {
            let newItem = ItemURL(url: newURL
            )
            modelContext.insert(newItem)
            let urls = items.compactMap { $0.url }
            viewModel.fetchMultipleURLs(urls: urls)
            WidgetCenter.shared.reloadAllTimelines()
            presentationMode.wrappedValue.dismiss()

        }
    }

  
}

#Preview {
    NewURLView()
        .modelContainer(for: ItemURL.self, inMemory: true)
}
