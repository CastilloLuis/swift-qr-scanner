//
//  ContentView.swift
//  qr-code-scanner
//
//  Created by Luis Castillo on 3/13/23.
//

import SwiftUI
import CodeScanner
import AVFoundation

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var webViewUrl: String?
    @State private var qrTitle: String = ""
    
    @State private var showWebView: Bool = false

    @State private var showAddToFavoriteAlert: Bool = false
    @State private var showAlertQR: Bool = false
    @State private var addedToFav: Bool = false
    @State private var cameraAuthorized: Bool = false
    
    @AppStorage("favorites") var favorites: String = "[]"
    
    func checkPermissions() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Determine if the user previously authorized camera access.
        var isAuthorized = status == .authorized
        
        // If the system hasn't determined the user's authorization status,
        // explicitly prompt them for approval.
        if status == .notDetermined {
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        }
        
        print("isAuthorized", isAuthorized)
        
        cameraAuthorized = isAuthorized
    }
    
    func openQR(_ output: String) {
        addedToFav = false
        showAddToFavoriteAlert = false
        showAlertQR = false
        
        if (output.contains("https://") || output.contains("http://") || output.contains("www.")) {
            webViewUrl = output
            showWebView = true
        } else {
            scannedCode = output
            showAlertQR = true
        }
    }
    
    func addToFavorites(title: String, url: String) {
        var currentFavorites = parseFavorites(from: favorites);
            currentFavorites.append(FavoritesQR(title: title, link: url))
        favorites = stringifyFavorites(favorites: currentFavorites)
        qrTitle = ""
        addedToFav = true
    }
    
    func includedInFavorites(_ link: String) -> Bool {
        let currentFavorites = parseFavorites(from: favorites);
        let filtered = currentFavorites.filter { item in
            item.link.lowercased() == link.lowercased()
        }
        return filtered.count > 0
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                VStack(spacing: 10) {
                    if (cameraAuthorized) {
                        CodeScannerView(codeTypes: [.qr]) { response in
                            if case let .success(result) = response {
                                openQR(result.string)
                            }
                        }
                    } else {
                        VStack {
                            Text("Camera Permission was denied 😔").bold()
                            Text("Settings > Privacy & Security > Camera and enable QR Code Scanner")
                                .multilineTextAlignment(.center)
                                .padding(10)
                            Divider()
                            Button {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            } label: {
                                Text("Go to Settings")
                            }
                        }
                        .padding()
                    }
                }
                .tabItem {
                    Label("Scan", systemImage: "qrcode")
                }
                .edgesIgnoringSafeArea(.top)

                FavoritesView(openQR: openQR(_:))
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }
            }
            .navigationDestination(isPresented: $showWebView) {
                WebView(url: webViewUrl ?? DEFAULT_URL)
                    .toolbar {
                        ToolbarItemGroup(placement: .primaryAction) {
                            if (!includedInFavorites(webViewUrl ?? DEFAULT_URL)) {
                                Button {
                                    showAddToFavoriteAlert  = true
                                } label: {
                                    if (!addedToFav) {
                                        Text("Add to")
                                    }
                                    Image(systemName: "star")
                                }
                            } else {
                                Button {} label: {
                                    Image(systemName: "star.fill")
                                }
                            }
                        }
                    }
                    .ignoresSafeArea()
            }
            .alert(scannedCode ?? "Empty QR", isPresented: $showAlertQR) {
                Button("OK", role: .cancel) {
                    scannedCode = ""
                }
            }
            .alert("Add to favorites", isPresented: $showAddToFavoriteAlert, actions: {
                TextField("Title", text: $qrTitle)
                Button("Save", action: {
                    addToFavorites(title: qrTitle, url: webViewUrl ?? DEFAULT_URL)
                })
            })
            .task {
                await checkPermissions()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
