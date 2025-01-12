import SwiftUI

struct NoRecipesView: View {
    var body: some View {
        PlaceholderView(
            iconView: AnyView(
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            ),
            title: "No Recipes Found",
            message: "Please try again at a later time"
        )
    }
} 
