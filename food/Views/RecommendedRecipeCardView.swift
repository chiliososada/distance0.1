import SwiftUI

struct RecommendedRecipeCardView: View {
    let image: UIImage
    let title: String
    let onTap: () -> Void
    let busynessLevel: Color // Represent busyness level with a color
    
    var body: some View {
        HStack(spacing: 10) { // Use HStack to add the vertical strip and the content
            // Left vertical bar representing busyness level
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [busynessLevel.opacity(0.7), busynessLevel]), // Subtle gradient effect
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .frame(width: 5) // Width of the vertical bar
//                .cornerRadius(2.5) // Half of the width to make it fully rounded
//                .shadow(color: busynessLevel.opacity(0.5), radius: 2, x: 0, y: 2) // Subtle shadow
            
            VStack(alignment: .leading, spacing: 10) {
                // First row: Profile Image and Name
                HStack(alignment: .top) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50) // Profile image size
                        .clipShape(Circle()) // Circular profile image
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1) // Border for the image
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("liu ziyuan")
                            .font(.caption)
                            .foregroundColor(.black)
                            .bold()
                        
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.gray)
                            
                            Text("東京都 葛飾区 立石")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail) // Truncate text if too long
                        }
                    }
                    Spacer()
                    
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                }
                
                // Second row: Title, starts under the profile image
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                // Image Gallery
                ImageGalleryView(images: [
                    "fresh_recipe_2","fresh_recipe_2","fresh_recipe_2","fresh_recipe_2","fresh_recipe_2"
                ])
                
                // Tags section
                HStack(spacing: 4) {
                    Text("#中古")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                    Text("#兼职")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                    Text("#手机")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                
                // Footer with info (people, time, distance)
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.gray)
                        
                        Text("99人")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.gray)
                        
                        Text("10 mins")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("距离我 300m")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.12), radius: 7, x: 0, y: 4)
        }
    }
}

// Image gallery
struct ImageGalleryView: View {
    let images: [String] // Array of image names or URLs
    
    var body: some View {
        HStack(spacing: 5) {
            // Loop through up to 4 images
            ForEach(0..<min(4, images.count), id: \.self) { index in
                ZStack {
                    // Ensure the image retains its aspect ratio and adjusts the height based on the width
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Maintain aspect ratio
                        .frame(width: imageWidth(for: images.count), height: imageHeight(for: images.count)) // Dynamic width and height
                        .clipped() // Ensure the image doesn't overflow
                    
                    // Overlay for "+N" if there are more than 4 images
                    if index == 3 && images.count > 4 {
                        Color.black.opacity(0.4) // Semi-transparent overlay
                        
                        Text("+\(images.count - 4)")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                    }
                }
                .frame(width: imageWidth(for: images.count), height: imageHeight(for: images.count)) // Ensure size is consistent
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Clip the image with rounded corners
            }
        }
        .clipped() // Ensure that the content inside the gallery does not affect layout size
    }
    
    // Function to calculate the dynamic width based on the number of images
    private func imageWidth(for count: Int) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 30 // Total width minus padding
        switch count {
        case 1:
            return min(screenWidth, 400) // Cap the width to 300 for one image
        case 2:
            return (screenWidth - 5) / 2 // Half width minus spacing
        case 3:
            return (screenWidth - 10) / 3 // One-third width minus spacing
        case 4:
            return (screenWidth - 15) / 4 // Quarter width for 4 images
        default:
            return 80 // Fallback width
        }
    }

    // Function to calculate the dynamic height based on the width, with a max height for 1 image
    private func imageHeight(for count: Int) -> CGFloat {
        switch count {
        case 1:
            return min(imageWidth(for: count) * 0.75, 225) // Cap the height to 225 for one image
        default:
            return imageWidth(for: count) * 0.75 // Maintain a 4:3 aspect ratio (height grows proportionally)
        }
    }
}



struct RecommendedRecipeCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendedRecipeCardView(
            image: UIImage(named: "fresh_recipe_1") ?? UIImage(),
            title: "French Toast with Berries",
            onTap: {},
            busynessLevel: Color.red 
        )
        .previewLayout(.sizeThatFits) // Adjusts preview to fit the content
        .padding() // Adds padding for better visibility in the preview
    }
}
