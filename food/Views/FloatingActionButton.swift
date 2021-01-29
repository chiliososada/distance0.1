//
//  FloatingActionButton.swift
//  food
//
//  Created by toyousoft on 2024/10/10.
//
import SwiftUI

struct FloatingActionButton: View {
    @Binding var isShowingPostInputView: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Button(action: {
                    isShowingPostInputView = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .opacity(0.7)
                        )
                        .shadow(radius: 10)
                        .padding(20)
                        .scaleEffect(isShowingPostInputView ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isShowingPostInputView)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height - 80)
            }
        }
        .fullScreenCover(isPresented: $isShowingPostInputView) {
            PostInputView(isPresented: $isShowingPostInputView)
        }
    }
}
