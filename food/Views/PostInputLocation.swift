import SwiftUI
import MapKit
import CoreLocation
import Combine

struct NearbyLocationData: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    var distance: Double?
}

struct PostInputLocation: View {
    var onLocationSelected: (NearbyLocationData) -> Void // 回调，用于返回选中的位置信息
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    @State private var locations: [NearbyLocationData] = []
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var searchResults: [SearchResultWithDistance] = []
    @State private var searchCompleterDelegate = SearchCompleterDelegate()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.7434, longitude: 139.8477), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var userLocation: CLLocation? = nil
    @State private var searchError: String? = nil
    @State private var calculatedDistancesCache = NSCache<MKLocalSearchCompletion, NSNumber>()
    @State private var searchTextPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationView {
            VStack {
                // 搜索框
                TextField("搜索位置", text: $searchText, onCommit: {
                    performSearch()
                })
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: searchText) {
                    searchTextPublisher.send(searchText)
                }

                // 搜索建议列表
                List {
                    if !searchResults.isEmpty {
                        Section(header: Text("搜索建议")) {
                            ForEach(searchResults, id: \.self) { result in
                                VStack(alignment: .leading) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red.opacity(0.2))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundColor(.red)
                                                .font(.system(size: 18, weight: .medium))
                                        }
                                        VStack(alignment: .leading) {
                                            Text(result.completion.title)
                                                .font(.headline)
                                            Text(result.completion.subtitle)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            if let distance = result.distance {
                                                Text(String(format: "距离 %.2f M", distance))
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .onTapGesture {
                                    searchText = result.completion.title
                                    performSearchFromCompletion(result: result.completion)
                                }
                            }
                        }
                    }

                    // 附近地点列表
                    Section(header: Text("附近地点")) {
                        ForEach(locations) { location in
                            VStack(alignment: .leading) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.2))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.red)
                                            .font(.system(size: 18, weight: .medium))
                                    }
                                    VStack(alignment: .leading) {
                                        Text(location.name)
                                            .font(.headline)
                                        Text(location.address)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        if let distance = location.distance {
                                            Text(String(format: "距离 %.2f M", distance))
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .onTapGesture {
                                    onLocationSelected(location) // 返回选中的位置
                                    isPresented = false // 关闭视图
                                    print("Selected Location: \(location.name), Latitude: \(location.latitude), Longitude: \(location.longitude)")
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    setupSearchCompleter()
                    getUserLocation()
                    setupSearchTextPublisher()
                }
//                .alert(isPresented: .constant(searchError != nil)) {
//                    Alert(title: Text("Error"), message: Text(searchError ?? "An unknown error occurred"), dismissButton: .default(Text("OK")) {
//                        searchError = nil
//                    })
//                }
                Spacer()
            }
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            )
        }
    }

    // 设置搜索补全器
    private func setupSearchCompleter() {
        searchCompleter.delegate = searchCompleterDelegate
        searchCompleter.resultTypes = .address
        searchCompleterDelegate.didUpdateResults = { results in
            self.searchResults = []
            self.calculateDistancesForSearchResults(results: results)
        }
        searchCompleterDelegate.didFailWithError = { error in
            handleSearchError(error)
        }
    }

    // 执行自定义搜索
    private func performSearch() {
        guard !searchText.isEmpty else {
            return
        }

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                handleSearchError(error)
                return
            }

            guard let mapItems = response?.mapItems else {
                searchError = "No results found"
                return
            }

            self.locations = mapItems.map { mapItem in
                let name = mapItem.name ?? "No Name Found"
                let address = formatAddress(from: mapItem.placemark)
                let coordinate = mapItem.placemark.coordinate
                let distance = calculateDistance(from: coordinate)

                return NearbyLocationData(name: name, address: address, latitude: coordinate.latitude, longitude: coordinate.longitude, distance: distance)
            }
        }
    }

    // 从搜索建议中执行搜索
    private func performSearchFromCompletion(result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            if let error = error {
                handleSearchError(error)
                return
            }

            guard let mapItems = response?.mapItems else {
                searchError = "No results found"
                return
            }

            if let userLocation = self.userLocation {
                self.locations = mapItems.map { mapItem in
                    let name = mapItem.name ?? "No Name Found"
                    let address = formatAddress(from: mapItem.placemark)
                    let coordinate = mapItem.placemark.coordinate
                    let distance = userLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))

                    return NearbyLocationData(name: name, address: address, latitude: coordinate.latitude, longitude: coordinate.longitude, distance: distance)
                }
            }
        }
    }

    // 计算距离
    private func calculateDistance(from coordinate: CLLocationCoordinate2D) -> Double? {
        guard let userLocation = self.userLocation else { return nil }
        let locationCoordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: locationCoordinate)
    }

    // 计算搜索建议的距离
    private func calculateDistancesForSearchResults(results: [MKLocalSearchCompletion]) {
       

        self.searchResults = []
        let group = DispatchGroup()

        for result in results {
            group.enter()

            if let cachedDistance = calculatedDistancesCache.object(forKey: result) {
                self.searchResults.append(SearchResultWithDistance(completion: result, distance: cachedDistance.doubleValue))
                group.leave()
            } else {
                let searchRequest = MKLocalSearch.Request(completion: result)
                let search = MKLocalSearch(request: searchRequest)

                search.start { response, error in
                    if let error = error {
                        handleSearchError(error)
                        group.leave()
                        return
                    }

                    guard let mapItem = response?.mapItems.first else {
                        group.leave()
                        return
                    }

                    let distance = self.calculateDistance(from: mapItem.placemark.coordinate)

                    if let distance = distance {
                        self.calculatedDistancesCache.setObject(NSNumber(value: distance), forKey: result)
                    }

                    DispatchQueue.main.async {
                        self.searchResults.append(SearchResultWithDistance(completion: result, distance: distance))
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            // 全部计算完毕后更新 UI
            self.searchResults = self.searchResults.sorted(by: { ($0.distance ?? 0) < ($1.distance ?? 0) })
        }
    }

    // 处理搜索错误
    private func handleSearchError(_ error: Error) {
        DispatchQueue.main.async {
            self.searchError = "Search failed: \(error.localizedDescription)"
        }
    }

    // 获取用户位置
    private func getUserLocation() {
        LocationService.shared.locationUpdated = { location in
            self.userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            Task {
                await self.fetchPlaces(location: location)
            }
        }
    }

    // 从搜索中获取附近地点
    private func fetchPlaces(location: CLLocationCoordinate2D) async {
        let poiSearch = MKLocalPointsOfInterestRequest(center: location, radius: 200)
        let search = MKLocalSearch(request: poiSearch)

        do {
            let response = try await search.start()
            let mapItems = response.mapItems

            if let userLocation = self.userLocation {
                self.locations = mapItems.map { mapItem in
                    let name = mapItem.name ?? "No Name Found"
                    let address = formatAddress(from: mapItem.placemark)
                    let coordinate = mapItem.placemark.coordinate
                    let distance = userLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))

                    return NearbyLocationData(name: name, address: address, latitude: coordinate.latitude, longitude: coordinate.longitude, distance: distance)
                }
            }
        } catch {
            searchError = "Search failed: \(error.localizedDescription)"
        }
    }

    // 格式化地址
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var address = ""
        if let subThoroughfare = placemark.subThoroughfare { address += subThoroughfare + " " }
        if let thoroughfare = placemark.thoroughfare { address += thoroughfare + ", " }
        if let locality = placemark.locality { address += locality + ", " }
        if let administrativeArea = placemark.administrativeArea { address += administrativeArea + " " }
        if let postalCode = placemark.postalCode { address += postalCode + " " }
        if let country = placemark.country { address += country }
        return address
    }

    // 设置搜索输入的延迟处理
    private func setupSearchTextPublisher() {
        searchTextPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { searchText in
                self.searchCompleter.queryFragment = searchText
            }
            .store(in: &cancellables)
    }
}

// 搜索建议和距离的数据结构
struct SearchResultWithDistance: Hashable {
    let completion: MKLocalSearchCompletion
    let distance: Double?
}

// 预览
struct PostInputLocation_Previews: PreviewProvider {
    static var previews: some View {
        PostInputLocation(onLocationSelected: { location in
            // 占位闭包，预览时不会执行实际逻辑
            print("Selected location: \(location.name)")
        }, isPresented: .constant(true))
    }
}
