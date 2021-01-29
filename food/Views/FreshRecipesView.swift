import SwiftUI

struct FreshRecipesView: View {
    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    LocationCard(distance: "最近")
                    LocationCard(distance: "<200m")
                    LocationCard(distance: "<300m")
       
                    
                }.padding()
        }
       //Add padding to the entire VStack for spacing
    }
}

struct LocationCard: View {
    var distance: String
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Text(distance)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("TextColor"))
                    .padding(.bottom, 4)
            }
            .frame(width: 50, height: 50) // Adjusted height to give more vertical space
            .background(
                LinearGradient(gradient: Gradient(colors: [Color("LightGrayColor"), Color.white]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4) // Subtle shadow for depth
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("BorderColor").opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.vertical, 1) // Add vertical padding to avoid cutoff
        .padding(.trailing, 1) // Horizontal padding
    }
}

// Preview for FreshRecipesView
struct FreshRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        FreshRecipesView()
    }
}

// Preview for LocationCard
struct LocationCard_Previews: PreviewProvider {
    static var previews: some View {
        LocationCard(distance: "<100m")
            .previewLayout(.sizeThatFits) // Fit content in preview
            .padding() // Add padding for preview
    }
}
