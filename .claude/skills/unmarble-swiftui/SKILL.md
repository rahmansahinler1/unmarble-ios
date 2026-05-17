---
name: unmarble-swiftui
description: Write SwiftUI views, stores, API client code, and models for the Unmarble iOS app in the same lean, explicit style Rahman uses in the Vue 3 Options API web client. Use this skill whenever the user asks for SwiftUI code, iOS components, Swift API client functions, an @Observable store, or anything that will live in the unmarble-ios repository. Use this even when the user does not explicitly say "in my style" — assume it. Do not introduce MVVM ViewModels, Combine publishers, fancy property wrappers, or generic abstractions unless explicitly requested. Mirror the Vue patterns. The goal is code Rahman can read, debug, and modify himself within a week of learning SwiftUI.
---

# Unmarble SwiftUI Skill

This skill encodes the coding patterns from Rahman's Vue 3 frontend (the `unmarble-client` repo) and translates them into idiomatic SwiftUI for the iOS app (the `unmarble-ios` repo). Follow it whenever writing Swift code for Unmarble.

## Core Philosophy

Lean, explicit, predictable. The same person who wrote the Vue frontend should be able to open any Swift file and read top-to-bottom without confusion. AI agents (Claude Code, this Claude) should also be able to reason about each file in isolation.

**Non-goals:** Architectural elegance, future-proofing, generic abstractions, "best practices" for their own sake. If a pattern adds a layer without solving a current problem, don't use it.

**Always:**
- One file = one View struct (mirrors Vue's single-file components)
- Predictable section order inside every View struct
- Throwing async functions for API calls, handled with `do/try/catch` in views
- State lives in either local `@State` or the global `UserStore`. Nowhere else.
- Props down via `let`, callbacks up via closure parameters
- No `ViewModel` per view. State in the view or the store. Full stop.

**Never (unless the user explicitly asks):**
- MVVM with one ViewModel per view
- Combine publishers (use async/await)
- Generic protocol-oriented abstractions (`AnyView`, type erasure, custom property wrappers)
- Third-party state libraries (TCA, etc.)
- `ObservableObject` / `@StateObject` / `@Published` (old API — we're on iOS 17+, use `@Observable`)
- CoreData, SwiftData (unless a feature genuinely needs local persistence — flag it and ask)
- CocoaPods (use Swift Package Manager only)

## Target Stack

- iOS 17+ minimum deployment target
- Swift 5.9+ / Swift 6
- SwiftUI only (no UIKit unless wrapping a specific component, and only when asked)
- Swift Package Manager for dependencies
- Backend: existing FastAPI at `api.unmarble.com`, JWT auth via Bearer token in `Authorization` header (the web uses cookies, but iOS will use Keychain-stored JWT)

## Folder Structure

The repo layout mirrors the Vue folder structure:

```
Unmarble/                       # source root (inside Unmarble.xcodeproj)
├── UnmarbleApp.swift            # entry point (equivalent to main.js)
├── Assets.xcassets              # images, colors
├── API/
│   ├── APIClient.swift          # equivalent to src/api/api.js
│   └── APIError.swift           # error types
├── Models/                      # equivalent to data shapes in Pinia state
│   ├── User.swift
│   ├── PreviewImage.swift
│   └── DesignResult.swift
├── Stores/
│   └── UserStore.swift          # equivalent to src/stores/user.js
├── Views/                       # full-screen views, equivalent to src/views/
│   ├── GalleryView.swift
│   ├── DesignView.swift
│   ├── ProfileView.swift
│   └── OnboardingView.swift
├── Components/                  # reusable components, equivalent to src/components/
│   ├── UploadModal.swift
│   ├── SelectionModal.swift
│   ├── UpgradeModal.swift
│   └── ...
└── Utils/
    ├── ImageProcessor.swift     # HEIC conversion, compression (equivalent to imageProcessor.js)
    ├── Keychain.swift           # token storage
    └── Analytics.swift          # PostHog wrapper
```

Naming: PascalCase files, descriptive names matching what they contain (`UploadModal.swift` not `Upload.swift`).

## View Struct Anatomy (the most important pattern)

Every SwiftUI view must follow this section order, with comment markers. This mirrors the Vue Options API's `data / computed / methods` order Rahman uses consistently.

```swift
import SwiftUI

struct UploadModal: View {
    // MARK: - Props (equivalent to Vue `props`)
    let isOpen: Bool
    let onClose: () -> Void
    let onUploaded: (String) -> Void  // category string passed back

    // MARK: - Local state (equivalent to Vue `data()`)
    @State private var selectedFile: Data? = nil
    @State private var previewImage: UIImage? = nil
    @State private var selectedCategory: String? = nil
    @State private var isUploading = false
    @State private var uploadStatus: UploadStatus = .idle
    @State private var uploadMessage = ""
    @State private var uploadProgress: Double = 0
    @State private var showLimitModal = false

    // MARK: - Stores (equivalent to Vue `mapStores`)
    @Environment(UserStore.self) private var userStore

    // MARK: - Computed (equivalent to Vue `computed`)
    var hasSelection: Bool {
        selectedFile != nil
    }

    var canSelectCategory: Bool {
        selectedFile != nil && !isUploading
    }

    var canUpload: Bool {
        selectedFile != nil && selectedCategory != nil && !isUploading
    }

    var userType: String {
        userStore.userCred.type
    }

    // MARK: - Body (equivalent to Vue `<template>`)
    var body: some View {
        if isOpen {
            ZStack {
                // ... view content
            }
            .onAppear { resetUploadState() }
        }
    }

    // MARK: - Methods (equivalent to Vue `methods`)
    func resetUploadState() {
        selectedFile = nil
        previewImage = nil
        selectedCategory = nil
        isUploading = false
        uploadStatus = .idle
        uploadMessage = ""
        uploadProgress = 0
    }

    func uploadFile() async {
        guard let file = selectedFile, let category = selectedCategory else { return }

        if userStore.userLimits.storageLeft ?? 0 <= 0 {
            showLimitModal = true
            return
        }

        isUploading = true
        uploadStatus = .uploading
        uploadProgress = 0
        defer { isUploading = false }

        do {
            let processed = try await ImageProcessor.processForUpload(file)
            let result = try await APIClient.shared.uploadImage(
                category: category,
                file: processed
            ) { progress in
                uploadProgress = progress
            }

            uploadStatus = .success
            uploadMessage = "Upload Successful"
            userStore.addPreviewImage(category: category, image: result)
            userStore.updateStorageLeft(result.storageLeft)
            onUploaded(category)
            onClose()
        } catch APIError.insufficientStorage {
            showLimitModal = true
            uploadStatus = .error
            uploadMessage = "No storage space remaining. Please upgrade to premium."
        } catch {
            uploadStatus = .error
            uploadMessage = error.localizedDescription
        }
    }
}

// MARK: - Local types
enum UploadStatus {
    case idle
    case uploading
    case success
    case error
}

// MARK: - Preview
#Preview {
    UploadModal(
        isOpen: true,
        onClose: {},
        onUploaded: { _ in }
    )
    .environment(UserStore.preview)
}
```

### Section order rules — never violate

1. Props (`let` properties — no default values, set by parent)
2. Local state (`@State` private vars, all with default values)
3. Injected stores (`@Environment`)
4. Computed properties (`var foo: Type { ... }`)
5. `var body: some View { ... }`
6. Methods (`func ...`)
7. (Below the struct) local types (enums for status strings, etc.)
8. (Bottom of file) `#Preview { ... }`

### Why this order

It's the order Rahman scans Vue files in. Props at top (the contract), state below (what changes), computed (what's derived), body (what renders), methods (what acts). No surprises.

## State Rules

- **`@State`**: local to this view. Mirrors Vue `data()`. Private, default value required.
- **`@Binding`**: this view mutates a parent's state. Equivalent to Vue `v-model`. Use only when child genuinely needs to write to parent state.
- **`@Environment(SomeStore.self)`**: read/write a global store. Equivalent to Vue `mapStores(useUserStore)`.
- **Plain `let`**: an immutable prop passed by parent. Equivalent to Vue `props` without two-way binding.
- **Closure props** (`let onClose: () -> Void`): callbacks. Equivalent to Vue `emits` + `$emit`.

Do NOT use:
- `@StateObject`, `@ObservedObject`, `@Published` — these are the pre-iOS-17 API. Use `@Observable` + `@Environment` instead.
- `@AppStorage`, `@SceneStorage` — only if user explicitly wants UserDefaults persistence
- `@FocusState`, `@FocusedValue` — only when implementing focus logic (rare)

## The UserStore Pattern

Mirrors `src/stores/user.js` (Pinia) almost field-for-field.

```swift
import SwiftUI
import Observation

@Observable
final class UserStore {
    // MARK: - State (equivalent to Pinia `state`)
    var userId: String? = nil
    var userLoggedIn: Bool = false
    var userCred: UserCred = .empty
    var userLimits: UserLimits = UserLimits(storageLeft: nil, designsLeft: nil)
    var previewImages: PreviewImages = PreviewImages(yourself: [], clothing: [], design: [])
    var gallerySelections: GallerySelections = GallerySelections(yourself: nil, clothing: nil)
    var onboardingData: OnboardingData = OnboardingData(gender: nil, selectedClothingId: nil)

    // MARK: - Computed (equivalent to Pinia `getters`)
    var imageCounts: ImageCounts {
        ImageCounts(
            yourself: previewImages.yourself.count,
            clothing: previewImages.clothing.count,
            design: previewImages.design.count
        )
    }

    var isPremium: Bool {
        userCred.type == "premium"
    }

    // MARK: - Actions (equivalent to Pinia `actions`)
    func initialize(userId: String) async {
        self.userId = userId
        do {
            let user = try await APIClient.shared.getUser()
            self.userLoggedIn = true
            self.userCred = user

            let previews = try await APIClient.shared.getPreviews()
            self.previewImages = previews
        } catch {
            print("UserStore initialize failed: \(error)")
            self.userLoggedIn = false
        }
    }

    func addPreviewImage(category: String, image: PreviewImage) {
        switch category {
        case "yourself": previewImages.yourself.append(image)
        case "clothing": previewImages.clothing.append(image)
        case "design": previewImages.design.append(image)
        default: break
        }
    }

    func updateStorageLeft(_ newValue: Int) {
        userLimits.storageLeft = newValue
    }

    func logout() {
        userId = nil
        userLoggedIn = false
        userCred = .empty
        userLimits = UserLimits(storageLeft: nil, designsLeft: nil)
        previewImages = PreviewImages(yourself: [], clothing: [], design: [])
        Keychain.deleteToken()
    }

    // MARK: - Preview helper (for SwiftUI Previews)
    static var preview: UserStore {
        let store = UserStore()
        store.userLoggedIn = true
        store.userCred = UserCred(
            name: "Test", surname: "User", email: "test@example.com",
            type: "premium", pictureUrl: "", nextRenewalDate: nil,
            subscriptionStatus: "active", subscriptionEndsAt: nil,
            daysUntilExpiry: nil, daysSinceExpiry: nil, userStatus: "active"
        )
        return store
    }
}
```

### Store rules

- Single global `UserStore` instance, injected at app root via `.environment(userStore)`
- State fields are plain `var` properties (the `@Observable` macro makes them reactive)
- Actions are `func` methods, async when they hit the API
- Always include a `static var preview` for SwiftUI Previews
- Don't split into multiple stores prematurely. The Vue app has one Pinia store; the iOS app will have one too unless a second store solves a genuine problem.

## The APIClient Pattern

Mirrors `src/api/api.js`. One file, all endpoints, each returning typed data and throwing on failure.

```swift
import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://api.unmarble.com")!
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Auth helper
    private func authorizedRequest(path: String, method: String, body: Data? = nil) throws -> URLRequest {
        guard let token = Keychain.getToken() else {
            throw APIError.unauthorized
        }
        var req = URLRequest(url: baseURL.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body { req.httpBody = body }
        return req
    }

    // MARK: - Endpoints

    func getUser() async throws -> UserCred {
        let req = try authorizedRequest(path: "/get_user", method: "POST")
        let (data, response) = try await session.data(for: req)
        try Self.checkResponse(response, data: data)
        let wrapper = try JSONDecoder.unmarble.decode(GetUserResponse.self, from: data)
        return wrapper.userInfo
    }

    func getPreviews() async throws -> PreviewImages {
        let req = try authorizedRequest(path: "/get_previews", method: "POST")
        let (data, response) = try await session.data(for: req)
        try Self.checkResponse(response, data: data)
        return try JSONDecoder.unmarble.decode(PreviewImages.self, from: data)
    }

    func uploadImage(
        category: String,
        file: Data,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> PreviewImage {
        // multipart/form-data upload — see Utils/MultipartFormData.swift
        // ... (full implementation in real file)
        fatalError("implement when building upload screen")
    }

    func designImage(
        yourselfImageId: String,
        clothingImageId: String,
        category: String
    ) async throws -> DesignResult {
        let body = try JSONEncoder().encode([
            "yourself_image_id": yourselfImageId,
            "clothing_image_id": clothingImageId,
            "category": category
        ])
        let req = try authorizedRequest(path: "/design_image", method: "POST", body: body)
        let (data, response) = try await session.data(for: req)
        try Self.checkResponse(response, data: data)
        return try JSONDecoder.unmarble.decode(DesignResult.self, from: data)
    }

    // MARK: - Response checking
    private static func checkResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        switch http.statusCode {
        case 200..<300:
            return
        case 401:
            throw APIError.unauthorized
        case 402:
            // Match FastAPI's status code for storage/design limits
            let detail = (try? JSONDecoder().decode(ErrorDetail.self, from: data))?.detail ?? ""
            if detail.contains("storage") { throw APIError.insufficientStorage }
            if detail.contains("design") { throw APIError.insufficientDesigns }
            throw APIError.serverError(http.statusCode, detail)
        default:
            let detail = (try? JSONDecoder().decode(ErrorDetail.self, from: data))?.detail ?? ""
            throw APIError.serverError(http.statusCode, detail)
        }
    }
}

struct ErrorDetail: Decodable {
    let detail: String
}
```

### API rules

- `APIClient` is an `actor` (Swift's thread-safe singleton concept) accessed via `APIClient.shared`
- Every endpoint is a separate `async throws` method
- Every method returns a typed model (`UserCred`, `PreviewImage`, etc.), never raw `Data` or `[String: Any]`
- 401 responses always throw `APIError.unauthorized` — the view layer catches this and routes to login
- Each Vue API function maps 1:1 to a Swift method. Same name (camelCase) where possible.

## APIError pattern

```swift
enum APIError: LocalizedError {
    case unauthorized
    case invalidResponse
    case insufficientStorage
    case insufficientDesigns
    case serverError(Int, String)
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Authentication required"
        case .invalidResponse: return "Invalid server response"
        case .insufficientStorage: return "No storage space remaining"
        case .insufficientDesigns: return "No design credits remaining"
        case .serverError(let code, let detail): return detail.isEmpty ? "Server error \(code)" : detail
        case .networkError(let err): return err.localizedDescription
        case .decodingError(let err): return "Failed to parse response: \(err.localizedDescription)"
        }
    }
}
```

## Model Pattern (Codable structs)

One struct per model, in `Models/`. Use `CodingKeys` to map FastAPI's snake_case to Swift's camelCase.

```swift
struct UserCred: Codable, Equatable {
    var name: String
    var surname: String
    var email: String
    var type: String  // "trial" or "premium"
    var pictureUrl: String
    var nextRenewalDate: String?
    var subscriptionStatus: String
    var subscriptionEndsAt: String?
    var daysUntilExpiry: Int?
    var daysSinceExpiry: Int?
    var userStatus: String

    static let empty = UserCred(
        name: "", surname: "", email: "", type: "trial",
        pictureUrl: "", nextRenewalDate: nil, subscriptionStatus: "none",
        subscriptionEndsAt: nil, daysUntilExpiry: nil, daysSinceExpiry: nil,
        userStatus: "active"
    )

    enum CodingKeys: String, CodingKey {
        case name, surname, email, type
        case pictureUrl = "picture_url"
        case nextRenewalDate = "next_renewal_date"
        case subscriptionStatus = "subscription_status"
        case subscriptionEndsAt = "subscription_ends_at"
        case daysUntilExpiry = "days_until_expiry"
        case daysSinceExpiry = "days_since_expiry"
        case userStatus = "user_status"
    }
}
```

### Model rules

- All models are `struct` with `Codable, Equatable`
- Use `var` (not `let`) for fields that change — the store mutates them
- Provide a `.empty` (or `.preview`) static factory for tests and previews
- `CodingKeys` explicit when names differ from JSON

## Loading & error UI pattern

Mirrors the Vue pattern of `isLoading` + `errorMessage` + status strings.

```swift
// In a view:
@State private var isDesigning = false
@State private var designError: String? = nil

var body: some View {
    VStack {
        Button("Design") { Task { await design() } }
            .disabled(!canDesign || isDesigning)

        if isDesigning {
            ProgressView("Designing...")
        }

        if let error = designError {
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}

func design() async {
    isDesigning = true
    designError = nil
    defer { isDesigning = false }

    do {
        let result = try await APIClient.shared.designImage(...)
        userStore.addPreviewImage(category: "design", image: result.preview)
    } catch APIError.insufficientDesigns {
        showLimitModal = true
    } catch {
        designError = error.localizedDescription
    }
}
```

### Loading/error rules

- `isXxx: Bool` for loading flags
- `xxxError: String?` for error messages (nil = no error)
- `defer { isLoading = false }` to guarantee the flag resets even on throw
- Specific error types caught before generic `catch`

## Parent-child communication

### Props down

```swift
ChildView(title: "Hello", count: 42)
```

### Two-way binding (rare — only when child mutates parent state)

```swift
// Parent
@State private var name = ""
NameField(name: $name)  // pass the binding

// Child
struct NameField: View {
    @Binding var name: String
    var body: some View {
        TextField("Name", text: $name)
    }
}
```

### Callbacks up (replaces Vue `emits`)

```swift
// Parent
ChildView(onClose: { showModal = false })

// Child
struct ChildView: View {
    let onClose: () -> Void
    var body: some View {
        Button("X", action: onClose)
    }
}
```

Naming convention: `onSomething` for callbacks (matches `@close` / `onClose` from Vue).

## What to do when uncertain

- If you're tempted to add a ViewModel, a Coordinator, a Router, or any other architectural pattern — DON'T. Ask the user first.
- If a piece of state could live in either the view or the store, ask. Default: view, unless multiple views need it.
- If you're about to introduce a third-party library — STOP. Ask. Default: write it yourself if it's under 100 lines.
- If a Vue pattern doesn't have a clean SwiftUI equivalent (e.g., `Teleport`, `nextTick`), describe the situation and ask for direction rather than picking a fancy abstraction.

## What "good" looks like

A new view file should be:
- Under 250 lines total (including preview)
- Readable top-to-bottom without jumping around
- Free of acronyms or jargon that aren't in the Vue codebase
- Buildable in isolation via `#Preview { ... }`

If a file is growing past 250 lines, the answer is usually to extract a child component (a separate View struct), not to add a ViewModel.

## When asked to "convert this Vue component"

1. Identify the props, data, computed, methods, watch, mounted blocks
2. Map them 1:1 to the SwiftUI sections (Props, @State, computed, body, methods, .onAppear)
3. Replace API calls with `try await APIClient.shared.xxx()` inside `do/catch`
4. Replace Pinia access with `userStore.xxx`
5. Keep the same field names where possible (snake_case → camelCase only for Swift conventions)
6. Add a `#Preview` at the bottom

Output a single Swift file. Don't create a ViewModel. Don't split into "view + logic" files.
