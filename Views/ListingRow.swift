import SwiftUI

struct ListingRow: View {
    let listing: ToolListing

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: iconName(for: listing.category))
                        .foregroundColor(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                Text(listing.category.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            if listing.status != "available" {
                Text(listing.status.capitalized)
                    .font(.caption)
                    .padding(6)
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }

    private func iconName(for category: String) -> String {
        let lower = category.lowercased()
        if lower.contains("drill") { return "hammer" }
        if lower.contains("ladder") { return "ladder" }
        if lower.contains("saw") { return "wand.and.stars.inverse" }
        return "wrench.and.screwdriver"
    }
}

