//
//  RecipesView.swift
//  RecipesView
//
//  Created by Ryan Davis on 1/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct RecipeGridContent: View {
    let recipes: [Recipe]
    let selectedRecipe: Recipe?
    let namespace: Namespace.ID
    @Binding var scrolledID: String?
    @Binding var selectedRecipeBinding: Recipe?
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16,
            pinnedViews: []
        ) {
            ForEach(recipes) { recipe in
                if selectedRecipe?.id == recipe.id {
                    // For right-side items, push content to next row
                    if let index = recipes.firstIndex(where: { $0.id == recipe.id }), index % 2 == 1 {
                        Color.clear
                        Color.clear
                    }
                    
                    // Expanded panel that moves left or right
                    ExpandedRecipePanel(
                        recipe: recipe,
                        namespace: namespace,
                        isPresented: $selectedRecipeBinding
                    )
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .offset(x: getExpandedOffset(recipe))
                    .gridCellColumns(2)
                    .id("expanded-\(recipe.id)")
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedRecipeBinding = recipe
                            scrolledID = "expanded-\(recipe.id)"
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.98).combined(with: .opacity),
                        removal: .scale(scale: 0.98).combined(with: .opacity)
                    ))
                    
                    // Add a full-width spacer to force next items to new row
                    Color.clear
                        .gridCellColumns(2)
                        .frame(height: 16)
                } else {
                    // Regular recipe card
                    RecipeCard(
                        recipe: recipe,
                        namespace: namespace,
                        selectedRecipe: $selectedRecipeBinding
                    )
                    .id(recipe.id)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedRecipeBinding = recipe
                            scrolledID = "expanded-\(recipe.id)"
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .scrollTargetLayout()
    }
    
    private func getExpandedOffset(_ recipe: Recipe) -> CGFloat {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return 0 }
        let gridSpacing: CGFloat = 16
        let screenWidth = UIScreen.main.bounds.width
        let expandedWidth = screenWidth - (gridSpacing * 2)
        let cardWidth = (screenWidth - (gridSpacing * 3)) / 2
        return index % 2 == 0 ? (expandedWidth - cardWidth)/2 : -(expandedWidth - cardWidth)/2
    }
}

struct RecipesView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedRecipe: Recipe?
    @State private var scrolledID: Recipe.ID?
    @State private var sortOrder: SortOption = .nameAsc
    @State private var selectedType: String? = nil
    @State private var selectedCountry: String? = nil
    
    // Sort and filter options
    enum SortOption {
        case nameAsc, nameDesc
        
        var description: String {
            switch self {
            case .nameAsc: "🔤 Name (A-Z)"
            case .nameDesc: "🔤 Name (Z-A)"
            }
        }
    }
    
    // Computed property for filtered and sorted recipes
    private var filteredAndSortedRecipes: [Recipe] {
        var result = recipes
        
        // Type filter
        if let type = selectedType {
            result = result.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(type)
            }
        }
        
        // Country filter
        if let country = selectedCountry {
            result = result.filter { recipe in
                recipe.cuisine.localizedCaseInsensitiveContains(country)
            }
        }
        
        // Sort
        switch sortOrder {
        case .nameAsc:
            result.sort { $0.name < $1.name }
        case .nameDesc:
            result.sort { $0.name > $1.name }
        }
        
        return result
    }
    
    private var availableCountries: [(String, String)] {
        let countries = Set(recipes.map { $0.cuisine })
        return countries.map { country in
            let emoji: String
            switch country.lowercased() {
            case let c where c.contains("british"): emoji = "🇬🇧"
            case let c where c.contains("french"): emoji = "🇫🇷"
            case let c where c.contains("italian"): emoji = "🇮🇹"
            case let c where c.contains("german"): emoji = "🇩🇪"
            case let c where c.contains("spanish"): emoji = "🇪🇸"
            case let c where c.contains("greek"): emoji = "🇬🇷"
            case let c where c.contains("japanese"): emoji = "🇯🇵"
            case let c where c.contains("chinese"): emoji = "🇨🇳"
            case let c where c.contains("indian"): emoji = "🇮🇳"
            case let c where c.contains("thai"): emoji = "🇹🇭"
            case let c where c.contains("vietnamese"): emoji = "🇻🇳"
            case let c where c.contains("korean"): emoji = "🇰🇷"
            case let c where c.contains("mexican"): emoji = "🇲🇽"
            case let c where c.contains("american"): emoji = "🇺🇸"
            case let c where c.contains("canadian"): emoji = "🇨🇦"
            case let c where c.contains("croatian"): emoji = "🇭🇷"
            case let c where c.contains("malaysian"): emoji = "🇲🇾"
            case let c where c.contains("polish"): emoji = "🇵🇱"
            case let c where c.contains("australian"): emoji = "🇦🇺"
            case let c where c.contains("irish"): emoji = "🇮🇪"
            case let c where c.contains("scottish"): emoji = "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
            case let c where c.contains("welsh"): emoji = "🏴󠁧󠁢󠁷󠁬󠁳󠁿"
            case let c where c.contains("portuguese"): emoji = "🇵🇹"
            case let c where c.contains("brazilian"): emoji = "🇧🇷"
            case let c where c.contains("russian"): emoji = "🇷🇺"
            case let c where c.contains("turkish"): emoji = "🇹🇷"
            case let c where c.contains("moroccan"): emoji = "🇲🇦"
            case let c where c.contains("lebanese"): emoji = "🇱🇧"
            case let c where c.contains("egyptian"): emoji = "🇪🇬"
            case let c where c.contains("indonesian"): emoji = "🇮🇩"
            case let c where c.contains("filipino"): emoji = "🇵🇭"
            case let c where c.contains("singaporean"): emoji = "🇸🇬"
            default: emoji = "🌍"
            }
            return (country, emoji)
        }.sorted(by: { $0.0 < $1.0 })
    }
    
    // Define grid layout with 2 columns for 2x2 layout
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // Function to determine offset for expanded recipe
    private func getExpandedOffset(_ recipe: Recipe) -> CGFloat {
        guard let index = filteredAndSortedRecipes.firstIndex(where: { $0.id == recipe.id }) else { return 0 }
        let gridSpacing: CGFloat = 16
        let screenWidth = UIScreen.main.bounds.width
        let expandedWidth = screenWidth - (gridSpacing * 2)
        let cardWidth = (screenWidth - (gridSpacing * 3)) / 2
        return index % 2 == 0 ? (expandedWidth - cardWidth)/2 : -(expandedWidth - cardWidth)/2
    }
    
    private let recipeService: RecipeService
    
    init(recipeService: RecipeService = RecipeService()) {
        self.recipeService = recipeService
    }
    
    var loadingView: some View {
        PlaceholderView(
            iconView: AnyView(
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
            ),
            title: "Loading Recipes...",
            message: "Please wait while we fetch the recipes"
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 0) {
                        // Simplified header
                        Text("Discover delightful desserts from around the world")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGroupedBackground))
                            .zIndex(1)
                        
                        // Main content
                        Group {
                            if isLoading && recipes.isEmpty {
                                loadingView
                                    .transition(.opacity)
                            } else {
                                if recipes.isEmpty {
                                    NoRecipesView()
                                        .frame(minHeight: UIScreen.main.bounds.height - 100)
                                        .transition(.opacity)
                                } else {
                                    RecipeGridContent(
                                        recipes: filteredAndSortedRecipes,
                                        selectedRecipe: selectedRecipe,
                                        namespace: namespace,
                                        scrolledID: $scrolledID,
                                        selectedRecipeBinding: $selectedRecipe
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Dessert Recipes")
            .scrollPosition(id: $scrolledID, anchor: .top)
            .scrollIndicators(.hidden)
            .background(
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            )
            .refreshable {
                await loadRecipes()
            }
            .animation(.easeInOut(duration: 0.3), value: isLoading)
            .animation(.easeInOut(duration: 0.3), value: recipes.isEmpty)
            .task {
                await loadRecipes()
            }
            .alert("Unable to Load Recipes", isPresented: $showError) {
                Button("Try Again") {
                    Task {
                        await loadRecipes()
                    }
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort options
                        ForEach([SortOption.nameAsc, .nameDesc], id: \.self) { option in
                            Button {
                                sortOrder = option
                            } label: {
                                HStack {
                                    Text(option.description)
                                    if sortOrder == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Dessert type submenu
                        Menu {
                            Button {
                                selectedType = nil
                            } label: {
                                HStack {
                                    Text("🍽️ All Desserts (\(recipes.count))")
                                    if selectedType == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            ForEach([
                                ("Cake", "🎂"),
                                ("Tart", "🥧"),
                                ("Cookie", "🍪"),
                                ("Pie", "🥮"),
                                ("Pudding", "🍮")
                            ], id: \.0) { type, emoji in
                                let count = recipes.filter { $0.name.localizedCaseInsensitiveContains(type) }.count
                                if count > 0 {
                                    Button {
                                        selectedType = type
                                    } label: {
                                        HStack {
                                            Text("\(emoji) \(type)s (\(count))")
                                            if selectedType == type {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Filter by Type", systemImage: "fork.knife")
                        }
                        
                        // Country submenu
                        Menu {
                            Button {
                                selectedCountry = nil
                            } label: {
                                HStack {
                                    Text("🌍 All Countries (\(recipes.count))")
                                    if selectedCountry == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            ForEach(availableCountries, id: \.0) { country, emoji in
                                let count = recipes.filter { $0.cuisine == country }.count
                                Button {
                                    selectedCountry = country
                                } label: {
                                    HStack {
                                        Text("\(emoji) \(country) (\(count))")
                                        if selectedCountry == country {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Filter by Country", systemImage: "globe")
                        }
                    } label: {
                        Label("Sort & Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(selectedType != nil || selectedCountry != nil ? .blue : .primary)
                    }
                }
            }
        }
        .frame(minWidth: 350, maxWidth: .infinity)
    }
    
    func loadRecipes() async {
        if recipes.isEmpty {
            isLoading = true
        }
        
        await MainActor.run {
            showError = false
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        do {
            let fetchedRecipes = try await recipeService.fetchRecipes()
            await MainActor.run {
                recipes = fetchedRecipes
                isLoading = false
            }
        } catch DecodingError.keyNotFound {
            await MainActor.run {
                errorMessage = "We encountered an issue with the data format. Please try again later."
                showError = true
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "An unexpected error occurred. Please try again later."
                showError = true
                isLoading = false
            }
        }
    }
    
    @Namespace private var namespace
}

struct RecipeCardImage: View {
    let recipe: Recipe
    let namespace: Namespace.ID
    let selectedRecipeID: String?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CachedAsyncImage(url: URL(string: recipe.photo_url_small)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .black.opacity(0.2),
                                .black.opacity(0.4)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .if(selectedRecipeID != recipe.id) { view in
                        view.matchedGeometryEffect(id: "image-\(recipe.id)", in: namespace)
                    }
            } placeholder: {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.1))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.7)
                    )
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(recipe.cuisine)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .foregroundStyle(.primary)
                .clipShape(Capsule())
                .padding(12)
        }
    }
}

struct RecipeCardContent: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.system(.title3, design: .serif))
                .fontWeight(.semibold)
                .lineLimit(3)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                if let source = recipe.source_url, let url = URL(string: source) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "book.closed.fill")
                                .font(.caption)
                            Text("Recipe")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.blue)
                    }
                }
                
                if let youtube = recipe.youtube_url, let url = URL(string: youtube) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                                .font(.caption)
                            Text("Watch")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .padding(.top, 4)
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    var namespace: Namespace.ID
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedRecipe: Recipe?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RecipeCardImage(
                recipe: recipe,
                namespace: namespace,
                selectedRecipeID: selectedRecipe?.id
            )
            
            RecipeCardContent(recipe: recipe)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.03),
                    lineWidth: 0.5
                )
        )
        .frame(maxWidth: .infinity)
        .aspectRatio(0.8, contentMode: .fit)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ExpandedRecipeView: View {
    let recipe: Recipe
    var namespace: Namespace.ID
    @Binding var isPresented: Recipe?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                CachedAsyncImage(url: URL(string: recipe.photo_url_large)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: "image-\(recipe.id)", in: namespace)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.1))
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 0))
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title and cuisine
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                        
                        Text(recipe.cuisine)
                            .font(.system(.subheadline, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    
                    // Ingredients Section
                    if let ingredients = recipe.ingredients {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(zip(ingredients.main.indices, ingredients.main)), id: \.0) { index, ingredient in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .padding(.top, 8)
                                        Text(ingredient)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .id("\(recipe.id)-main-\(index)")
                                }
                                
                                if !ingredients.garnishes.isEmpty {
                                    Text("Garnishes")
                                        .font(.headline)
                                        .padding(.top, 8)
                                    
                                    ForEach(Array(zip(ingredients.garnishes.indices, ingredients.garnishes)), id: \.0) { index, garnish in
                                        HStack(alignment: .top) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .padding(.top, 8)
                                            Text(garnish)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .id("\(recipe.id)-garnish-\(index)")
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Method Section
                    if let method = recipe.method {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Method")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(Array(method.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 16) {
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color(.systemGray6))
                                            .clipShape(Circle())
                                        
                                        Text(step)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Nutrition Section
                    if let nutrition = recipe.nutrition {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Nutrition")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 24),
                                GridItem(.flexible(), spacing: 24)
                            ], spacing: 20) {
                                ForEach(Array(nutrition.sorted(by: { $0.key < $1.key }).enumerated()), id: \.element.key) { index, item in
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.key.capitalized)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                            Text(item.value)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Links
                    VStack(spacing: 12) {
                        if let source = recipe.source_url, let url = URL(string: source) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "book.closed.fill")
                                    Text("View Full Recipe")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        if let youtube = recipe.youtube_url, let url = URL(string: youtube) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Watch Video Tutorial")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        }
        .edgesIgnoringSafeArea(.top)
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = nil
                    }
                }
        )
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isPresented = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}

struct ExpandedRecipePanel: View {
    let recipe: Recipe
    var namespace: Namespace.ID
    @Binding var isPresented: Recipe?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header image and close button
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: URL(string: recipe.photo_url_large)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .matchedGeometryEffect(id: "image-\(recipe.id)", in: namespace)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.1))
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPresented = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title and cuisine
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                        
                        Text(recipe.cuisine)
                            .font(.system(.subheadline, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    
                    // Ingredients Section
                    if let ingredients = recipe.ingredients {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(zip(ingredients.main.indices, ingredients.main)), id: \.0) { index, ingredient in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .padding(.top, 8)
                                        Text(ingredient)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .id("\(recipe.id)-main-\(index)")
                                }
                                
                                if !ingredients.garnishes.isEmpty {
                                    Text("Garnishes")
                                        .font(.headline)
                                        .padding(.top, 8)
                                    
                                    ForEach(Array(zip(ingredients.garnishes.indices, ingredients.garnishes)), id: \.0) { index, garnish in
                                        HStack(alignment: .top) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .padding(.top, 8)
                                            Text(garnish)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .id("\(recipe.id)-garnish-\(index)")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Method Section
                    if let method = recipe.method {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Method")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(Array(method.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 16) {
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 28, height: 28)
                                            .background(Color(.systemGray6))
                                            .clipShape(Circle())
                                        
                                        Text(step)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Nutrition Section
                    if let nutrition = recipe.nutrition {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Nutrition")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 24),
                                GridItem(.flexible(), spacing: 24)
                            ], spacing: 20) {
                                ForEach(Array(nutrition.sorted(by: { $0.key < $1.key }).enumerated()), id: \.element.key) { index, item in
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.key.capitalized)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                            Text(item.value)
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6).opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Links
                    VStack(spacing: 12) {
                        if let source = recipe.source_url, let url = URL(string: source) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "book.closed.fill")
                                    Text("View Full Recipe")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        if let youtube = recipe.youtube_url, let url = URL(string: youtube) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Watch Video Tutorial")
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding()
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.03),
                        lineWidth: 0.5
                    )
            )
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark ? .white.opacity(0.05) : .black.opacity(0.03),
                    lineWidth: 0.5
                )
        )
    }
}
