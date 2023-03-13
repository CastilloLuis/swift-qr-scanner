//
//  FavoritesView.swift
//  qr-code-scanner
//
//  Created by Luis Castillo on 3/13/23.
//

import SwiftUI

struct FavoritesView: View {
    @AppStorage("favorites") var favorites: String = "[]"
    @State var favList: [FavoritesQR] = []
    
    var openQR: (_ output: String) -> Void
    
    func removeFromFavorites(id: UUID) {
        let currentFavorites = parseFavorites(from: favorites);
        let filteredFavorites = currentFavorites.filter { fav in
            return fav.id != id
        }
        favorites = stringifyFavorites(favorites: filteredFavorites)
        favList = parseFavorites(from: favorites)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Favorites").font(.title).bold()
                Spacer()
                if (favList.count > 0) {
                    Button {
                        favorites = "[]"
                        favList = []
                    } label: {
                        Text("Remove all")
                    }
                }
            }
            Divider()
            if (favList.count > 0) {
                List {
                    ForEach(favList, id: \.id) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Image(systemName: "chevron.forward")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            openQR(item.link)
                        }
                        .listRowInsets(EdgeInsets())
                        .swipeActions {
                            Button(role: .destructive) {
                                removeFromFavorites(id: item.id)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                Text("Empty List")
                    .bold()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            print(favList)
            favList = parseFavorites(from: favorites)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView { output in
            print("Preview")
        }
    }
}
