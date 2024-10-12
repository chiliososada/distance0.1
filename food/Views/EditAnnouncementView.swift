//
//  EditAnnouncementView.swift
//  food
//
//  Created by toyousoft on 2024/10/12.
//

import SwiftUI

struct EditAnnouncementView: View {
    @State private var announcementText: String = ""

    var body: some View {
        VStack {
            Text("修改公告")
                .font(.headline)
                .padding()

            TextEditor(text: $announcementText)
                .padding()
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

            Spacer()

            Button(action: {
                // 保存公告的逻辑
                print("公告保存: \(announcementText)")
            }) {
                Text("保存")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

// Preview for the EditAnnouncementView
struct EditAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        EditAnnouncementView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
