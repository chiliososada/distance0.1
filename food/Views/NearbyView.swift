import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 35.765, longitude: 139.8485)  // 替换为你的坐标
}

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.360256,
            longitude: -71.057279
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
    )

    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5
        )
    )
}


struct NearbyView: View {
    @State private var position : MapCameraPosition = .automatic
    
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var seletedResult: MKMapItem?
    
    @State private var searchResult : [MKMapItem]=[]
    
    @State private var showBottomSheet = false // 控制底部彩带的显示
    var body: some View {
        ZStack {
            Map(position: $position, selection: $seletedResult) {
                Annotation("Parking", coordinate: .parking) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.background)
                        //                    RoundedRectangle(cornerRadius: 5)
                        //                        .stroke(.secondary, lineWidth: 5)
                        Image(systemName: "message.fill")
                            .padding(5)
                    }
                }
                .annotationTitles(.hidden) // 隐藏标题
                ForEach(searchResult, id: \.self) { result in
                    Marker(result.name ?? "Location", systemImage: "message", coordinate: result.placemark.coordinate)
                }
                .annotationTitles(.hidden)
                UserAnnotation()
                
                
            }
            .mapStyle(.standard(elevation: .realistic)) // 设置地图样式为 realistic
            .safeAreaInset(edge: .top){
                HStack{
                    Spacer()
                    VStack(spacing:0)
                    {
                        MapButtonsView(position: $position , searchResults: $searchResult,visibleRegin: visibleRegion).padding(.top)
                    }
                    
                    Spacer()
                }
                .background(Color.clear)
               
                   
            }
            .onChange(of: searchResult) {
                position = .automatic
            }
            .onChange(of: seletedResult) {
                showBottomSheet = seletedResult != nil
            }
            .onMapCameraChange{newValue in
                visibleRegion = newValue.region
            }
            .mapControls{
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            if let result = seletedResult {
                BottomMenuView(selectedResult: result) .presentationDetents([.fraction(0.35), .large])   // 将 seletedResult 传递给 BottomMenuView
               }
        }
        
    }}



struct BottomMenuView: View {
    var selectedResult: MKMapItem // 接受 seletedResult 参数

    var body: some View {        
        RecommendedRecipeCardView(
            image: UIImage(named: "fresh_recipe_1") ?? UIImage(),
            title: "French Toast with Berries",
            onTap: {},
            busynessLevel: Color.red
        )}
}


struct NearbyView_Previews: PreviewProvider {
    static var previews: some View {
        NearbyView()
    }
}
