//
//  ItemURLSView.swift
//  Pulse
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import SwiftUI
import SwiftData

struct ItemURLSView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemURL]


    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    Text(item.url ?? "")
                } label: {
                    Text(item.url ?? "")
                }
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
           
        }
        .navigationTitle("Items")
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ItemURLSView()
        .modelContainer(for: ItemURL.self, inMemory: true)
}
