//
//  SectionTitleView.swift
//  food
//
//  Created by Abu Anwar MD Abdullah on 25/1/21.
//

import SwiftUI

struct SectionTitleView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.leading, 4)
            Spacer()
        }
    }
}
struct SectionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        SectionTitleView(title: "根据位置进行过滤")
    }
}
