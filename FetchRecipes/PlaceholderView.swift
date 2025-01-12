import SwiftUI

struct PlaceholderView: View {
    let iconView: AnyView
    let title: String
    let message: String
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 200)
                
                ZStack {
                    Color.clear
                        .frame(width: 60, height: 60)
                    iconView
                }
                .frame(height: 60)
                
                Color.clear
                    .frame(height: 30)
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
} 
