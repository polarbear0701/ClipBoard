//
//  ClipBoardRowView.swift
//  ClipBoard
//
//  Created by Phan Trong Nguyen on 24/6/26.
//

import SwiftUI

struct ClipBoardRowView: View {
    let item: ClipBoardItem
    let onSelect: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // content type icon
            Image(systemName: iconName)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 16)
                .padding(.top, 2)

            // clip content preview
            VStack(alignment: .leading, spacing: 2) {
                Text(previewText)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)

                Text(item.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // action buttons — show on hover
            if isHovered {
                HStack(spacing: 6) {
                    actionButton(
                        icon: item.isPinned ? "pin.fill" : "pin",
                        color: item.isPinned ? .orange : .secondary,
                        action: onPin
                    )
                    actionButton(icon: "trash", color: .red, action: onDelete)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.primary.opacity(0.06) : .clear)
        )
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .onTapGesture { onSelect() }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    private var previewText: String {
        switch item.contentType {
        case .text: return item.content
        case .image: return "[Image]"
        case .file: return item.content
        }
    }

    private var iconName: String {
        switch item.contentType {
        case .text: return "doc.text"
        case .image: return "photo"
        case .file: return "folder"
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
        }
        .buttonStyle(.plain)
    }
}
