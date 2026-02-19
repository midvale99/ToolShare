Neighbour Tool Share Board – iOS App
====================================

This folder contains the SwiftUI source code for the **Neighbour Tool Share Board** iPhone app: a hyper‑local tool lending board within ~200 m.

Need it on an iPhone *today* from a Windows PC?
----------------------------------------------

Apple requires Xcode (Mac) to build a “real” native iPhone app. If you’re on Windows and want something you can use **right now**, this repo also includes a **PWA** (a website that installs like an app on iPhone).

- The PWA lives in `pwa/`
- It runs in Safari and can be installed to your Home Screen (Share → Add to Home Screen)
- It uses GPS and filters tools within ~200 m
- Data is stored locally on the phone (localStorage) so it works immediately without setup

You (or a hired iOS developer) will:

1. Create an Xcode project.
2. Add Firebase to the project.
3. Copy these Swift files into the project.
4. Hook the stubbed service methods to Firebase.
5. Build, run on an iPhone, and submit to the App Store.

High‑Level Features
-------------------

- See nearby tools (within ~200 m of your location).
- Post a tool to lend (title, category, description, photo).
- Request to borrow a tool with a short note.
- Simple chat per request.
- Basic profile (name, counts of lent/borrowed items).

Project Structure (in this folder)
----------------------------------

- `App/`
  - `NeighbourToolShareBoardApp.swift` – app entry point, sets up root view.
  - `RootView.swift` – main tab navigation.
  - `LocationManager.swift` – handles location permissions and current location.
- `Models/`
  - `ToolListing.swift` – data model for tools.
  - `BorrowRequest.swift` – data model for borrow requests.
  - `ChatMessage.swift` – data model for chat messages.
  - `AppUser.swift` – data model for users.
- `Views/`
  - `BoardView.swift` – list of nearby tools.
  - `ListingRow.swift` – individual listing cell.
  - `ListingDetailView.swift` – details + borrow request.
  - `NewListingView.swift` – create a new listing.
  - `MessagesView.swift` – list of conversations.
  - `ChatView.swift` – chat for a single request.
  - `ProfileView.swift` – user profile screen.
- `Services/`
  - `GeoUtils.swift` – distance calculations (200 m radius).
  - `BackendService.swift` – protocol + stub FirebaseService implementation.

How To Use This Code
--------------------

1. On a Mac, install **Xcode** from the Mac App Store.
2. Create a new Xcode project:
   - Template: *iOS > App*
   - Interface: **SwiftUI**
   - Language: **Swift**
3. In Finder, drag the `App`, `Models`, `Views`, and `Services` folders from this directory into your Xcode project’s file list (choose “Copy items if needed”).
4. Make sure the app’s main entry point is `NeighbourToolShareBoardApp` (Xcode will usually detect it; if not, set it in the app target’s settings).
5. Follow Firebase’s iOS setup guide to:
   - Add Firebase via Swift Package Manager or CocoaPods.
   - Configure Firestore, Authentication, and Storage.
   - Replace the `TODO` comments in `BackendService.swift` with real Firebase calls.

Once this is done, you can run the app on an iPhone or simulator from Xcode.

PWA (works from Windows + iPhone)
--------------------------------

1. Host the `pwa/` folder on **any HTTPS website** (HTTPS is required for GPS in browsers).
   - Easy options: Netlify Drop, Cloudflare Pages, GitHub Pages, or any web host you already use.
2. Open the site on your iPhone in Safari.
3. When prompted, allow Location.
4. Install it: Share → **Add to Home Screen**.


