import Foundation
import SwiftUI
import WidgetKit


@MainActor
class ViewModel: NSObject, ObservableObject {
    @Published var item: [Item] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @AppStorage("ipAddress", store: UserDefaults(suiteName: "group.com.radsoftinc.Pulse")) var ipAddress: String = ""

    func fetchMultipleURLs(urls: [String]) {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://\(ipAddress):8000/canon/multiple") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        let requestBody = MultipleURLRequestBody(urls: urls)

        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(requestBody) else {
            errorMessage = "Failed to encode request body"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = encoded

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoder = JSONDecoder()
                self.item = try decoder.decode([Item].self, from: data)
                WidgetCenter.shared.reloadAllTimelines()

            } catch {
                errorMessage = "Failed to fetch data: \(error)"
            }
            isLoading = false
        }
    }
}
