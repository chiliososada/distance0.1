import SwiftUI

struct LoginView: View {
    var velocity: CGFloat = 50
    @State private var drawLeftLine: Bool = false
    @State private var drawRightLine: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Lines section taking a smaller portion of the screen
            GeometryReader { geometry in
                HStack(spacing: geometry.size.width * 0.2) { // Adjusting the line spacing based on screen width
                    // Left Line
                    Capsule()
                        .frame(width: 8, height: drawLeftLine ? geometry.size.height * 0.4 * 0.6 : 0) // Adjusted thickness and height
                        .animation(.easeInOut(duration: 2).delay(0.5), value: drawLeftLine)
                    
                    // Right Line
                    Capsule()
                        .frame(width: 8, height: drawRightLine ? geometry.size.height * 0.4 : 0) // Adjusted thickness and height
                        .animation(.easeInOut(duration: 2).delay(1), value: drawRightLine)
                }
                .frame(height: geometry.size.height * 0.4) // Smaller height for GeometryReader
                .padding(.top, 40) // Move the lines section upwards
                .onAppear {
                    // Trigger animations
                    drawLeftLine = true
                    drawRightLine = true
                }
            }
            .frame(height: 200) // Explicitly set a fixed height for GeometryReader
            .padding(.top, 50)  // Adjust top padding to move it upwards
          
            Spacer()
            
            // Buttons section in the bottom half
            HStack(spacing: 20) {
                Button(action: {
                    print("Register button tapped")
                }) {
                    Text("注册")
                        .frame(width: 100, height: 40) // Adjusted button size
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20) // Rounded corners
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1) // Border styling
                        )
                }
                
                Button(action: {
                    print("Login button tapped")
                }) {
                    Text("登陆")
                        .frame(width: 100, height: 40) // Adjusted button size
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10) // Rounded corners
                }
            }
            .padding(.bottom, 10) // Adjusted padding for spacing below buttons
            
            // Marquee section (wrapped inside the same VStack)
            Marquee(targetVelocity: 30) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        // First row: Profile Image and Name
                        HStack(alignment: .top) {
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
                        }
                        Text("一起去唱歌🎤吧！")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
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
                VStack(alignment: .leading, spacing: 10) {
                    // First row: Profile Image and Name
                    HStack(alignment: .top) {
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
                    }
                    Text("一起去跳舞💃吧！")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
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
                
            }.mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.2),
                        .init(color: .black, location: 0.8),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            } .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white) // Set the background color
            .padding(.bottom, 80) // Adjusted to move the marquee higher
        }
       
    }


struct ImageModel: Identifiable {
    var id: UUID = UUID()
    var imageString: String?
    var color: Color?
}

#Preview {
    LoginView()
}
