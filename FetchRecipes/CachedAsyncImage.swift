//
//  CachedAsyncImage.swift
//  CachedAsyncImage
//
//  Created by Ryan Davis on 1/10/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    @State private var phase: AsyncImagePhase = .empty
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        Group {
            if let url = url {
                content(phase)
                    .task {
                        await loadImage(url: url)
                    }
            } else {
                content(.empty)
            }
        }
    }
    
    private func loadImage(url: URL) async {
        // Check cache first
        let urlString = url.absoluteString
        if let cachedImage = await ImageCache.shared.object(forKey: urlString) {
            withAnimation(transaction.animation) {
                phase = .success(Image(uiImage: cachedImage))
            }
            return
        }
        
        // If not in cache, load from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }
            
            // Cache the image
            await ImageCache.shared.set(uiImage, forKey: urlString)
            
            withAnimation(transaction.animation) {
                phase = .success(Image(uiImage: uiImage))
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }
}

extension CachedAsyncImage {
    init<I: View, P: View>(
        url: URL?,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == AnyView {
        self.init(url: url, scale: scale) { phase in
            AnyView(
                Group {
                    if case .success(let image) = phase {
                        content(image)
                    } else {
                        placeholder()
                    }
                }
            )
        }
    }
} 
