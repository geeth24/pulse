//
//  PulseWidget.swift
//  PulseWidget
//
//  Created by Geeth Gunnampalli on 6/9/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @AppStorage("ipAddress", store: UserDefaults(suiteName: "group.com.radsoftinc.Pulse")) var ipAddress: String = ""
    @MainActor
    func getItems() -> [ItemURL]{
        guard let modelContainer = try? ModelContainer(for: ItemURL.self) else{
            return []
        }
        let descriptor = FetchDescriptor<ItemURL>()
        let items = try? modelContainer.mainContext.fetch(descriptor)
        return items ?? []
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), item: [Item(name: "", price: "", availability: "", url: "")])
    }
    
    
    
    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let items = getItems()
        let urls = items.compactMap { $0.url }
        

        
        Task {
            do {
                guard let url = URL(string: "http://\(ipAddress):8000/canon/multiple") else {
                    fatalError("Missing URL")
                }
                
                let requestBody = MultipleURLRequestBody(urls: urls)
                
                let encoder = JSONEncoder()
                guard let encoded = try? encoder.encode(requestBody) else {
                    
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = encoded
                
                let urlRequest = request
                
                Task {
                    do {
                        let (data, response) = try await URLSession.shared.data(for: urlRequest)
                        let decoder = JSONDecoder()
                        let jsonData = try decoder.decode([Item].self, from: data)
                        let entry = SimpleEntry(date: Date(), item: jsonData)
                        completion(entry)
                        
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                            return
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let items = getItems()
        let urls = items.compactMap { $0.url }
        Task {
            do {
                guard let url = URL(string: "http://\(ipAddress):8000/canon/multiple") else {
                    fatalError("Missing URL")
                }
                print(urls)
                let requestBody = MultipleURLRequestBody(urls: urls)
                
                let encoder = JSONEncoder()
                guard let encoded = try? encoder.encode(requestBody) else {
                    
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = encoded
                
                let urlRequest = request
                
                Task {
                    do {
                        let (data, response) = try await URLSession.shared.data(for: urlRequest)
                        let decoder = JSONDecoder()
                        let jsonData = try decoder.decode([Item].self, from: data)
                        let entry = SimpleEntry(date: Date(), item: jsonData)
                       
                        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 14400)))
                        
                        completion(timeline)
                        
                        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                            return
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var item: [Item]
}

struct PulseWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ItemURL]
    
    
    var body: some View {
        let count = entry.item.filter { $0.availability.contains("In") }.count
        
        switch family {
        case .accessoryCircular:
            Circle()
                .stroke(lineWidth: 6.0)
                .overlay {
                    Text("\(count)")
                        .font(.system(size: 35))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            
        case .systemLarge:
            
            VStack(spacing: 10.0) {
                HStack{
                    Spacer()
                    Text("\(entry.date, style: .date) @ \(entry.date, style: .time)")
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundStyle(Color("PulseGreen"))
                }
                ForEach(entry.item, id: \.self) { item in
                    VStack{
                        HStack{
                            
                            VStack(alignment: .leading){
                                
                                Text(item.name)
                                    .font(.headline)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                
                                HStack{
                                    Text(item.price)
                                        .font(.subheadline)
                                    Text(item.availability)
                                        .font(.callout)
                                }
                            }
                            Spacer()
                        }
                        .foregroundStyle(item.availability.contains("In") ? Color("PulseGreen") : Color("PulseRed"))
                        .padding()
                        
                    } .background(content: {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.black)
                    })
                    
                    
                    
                }
                
                
               
            }
            
            
            
            
            
            
        default:
            Text("Some other WidgetFamily in the future.")
            
        }
        
    }
}

struct PulseWidget: Widget {
    let kind: String = "PulseWidget"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ItemURL.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PulseWidgetEntryView(entry: entry)
                    .containerBackground(Color("WidgetBackground"), for: .widget)
                    .modelContainer(sharedModelContainer)
                    .preferredColorScheme(.dark)
                
            } else {
                PulseWidgetEntryView(entry: entry)
                    .padding()
                    .background()
                    .modelContainer(sharedModelContainer)
                    .preferredColorScheme(.dark)
                
                
            }
        }
        .configurationDisplayName("Pulse Widget")
        .description("Shows Tracking At A Glance")
        .supportedFamilies([.systemLarge, .accessoryCircular])
        
        
    }
}

#Preview(as: .systemLarge) {
    PulseWidget()
} timeline: {
    SimpleEntry(date: .now, item: [Item(name: "Refurbished EOS R6 Mark II Body", price: "$1,759.00", availability: "In Stock", url: "https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body"), Item(name: "Refurbished EOS R6 Mark II Body", price: "$1,759.00", availability: "Out of Stock", url: "https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body"), Item(name: "Refurbished EOS R6 Mark II Body", price: "$1,759.00", availability: "In Stock", url: "https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body"), Item(name: "Refurbished EOS R6 Mark II Body", price: "$1,759.00", availability: "Out of Stock", url: "https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body")])
}

#Preview(as: .accessoryCircular) {
    PulseWidget()
} timeline: {
    SimpleEntry(date: .now, item: [Item(name: "Refurbished EOS R6 Mark II Body", price: "$1,759.00", availability: "In Stock", url: "https://www.usa.canon.com/shop/p/refurbished-eos-r6-mark-ii-body")])
}
