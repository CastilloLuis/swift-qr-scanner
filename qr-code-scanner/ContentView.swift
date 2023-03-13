//
//  ContentView.swift
//  qr-code-scanner
//
//  Created by Luis Castillo on 3/13/23.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var webViewUrl: String?
    @State private var qrTitle: String = ""
    
    @State private var showWebView: Bool = false

    @State private var showAddToFavoriteAlert: Bool = false
    @State private var showAlertQR: Bool = false
    @State private var addedToFav: Bool = false
    
    @AppStorage("favorites") var favorites: String = "[]"
    
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
        var currentFavorites = parseFavorites(from: favorites);
        var filtered = currentFavorites.filter { item in
            item.link.lowercased() == link.lowercased()
        }
        return filtered.count > 0
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                VStack(spacing: 10) {
                    CodeScannerView(codeTypes: [.qr]) { response in
                        if case let .success(result) = response {
                            openQR(result.string)
                        }
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
                Button("OK", role: .cancel) { }
            }
            .alert("Add to favorites", isPresented: $showAddToFavoriteAlert, actions: {
                TextField("Title", text: $qrTitle)
                Button("Save", action: {
                    addToFavorites(title: qrTitle, url: webViewUrl ?? DEFAULT_URL)
                })
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
