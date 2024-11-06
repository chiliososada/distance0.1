//
//  DraftActionSheet.swift
//  food
//
//  Created by toyousoft on 2024/11/06.
//

import SwiftUI

struct DraftActionSheet: ViewModifier {
    @Binding var isPresented: Bool
    let onSave: () -> Void
    let onDelete: () -> Void
    
    func body(content: Content) -> some View {
        content.actionSheet(isPresented: $isPresented) {
            ActionSheet(
                title: Text("是否保存草稿？"),
                message: Text("你可以保存当前内容为草稿，以便稍后继续编辑"),
                buttons: [
                    .default(Text("保存草稿"), action: onSave),
                    .destructive(Text("删除"), action: onDelete),
                    .cancel(Text("取消"))
                ]
            )
        }
    }
}
