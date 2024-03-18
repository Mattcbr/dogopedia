//
//  breedsViewController.swift
//  dogopedia
//
//  Created by Matheus Queiroz on 26/01/2024.
//

import SwiftUI

struct breedsViewController: View {

    @EnvironmentObject var viewModel: breedsViewModel
    private var circle = Circle()
    private var rectangle = Rectangle()
    @State private var isSorting = false
    @State private var layoutFormat: LayoutFormat = .grid
    var gridItems: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        switch viewModel.state {

        case .success, .loading:
            NavigationView {
                VStack(alignment: .leading, spacing: .zero) {
                    formatChooser()
                        .padding()
                    updatedLayout(items: getBreedsArray())
                }
                .toolbar(content: {
                    ToolbarItem {
                        sortButton
                    }
                })
                .navigationTitle("Dogopedia 🐶")
            }

        case .initialLoading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }

        case .error:
            errorView
        }
    }

    private var errorView: some View {
        Text("To see breeds here you need to add them to your favorites when you're online")
            .multilineTextAlignment(.center)

    }

    @ViewBuilder private func gridView(items: [Breed]) -> some View {
        ScrollView {
            LazyVGrid(columns: gridItems, spacing: 10) {
                ForEach(items, id: \.id) { breed in
                    NavigationLink {
                        detailsViewController(breed: breed)
                    } label: {
                        VStack(spacing: 12) {
                            if let URL = breed.imageURL {
                                gridDogPicture(url: URL)
                            }
                            dogName(breed.name)
                            Spacer()
                        }
                        .onAppear() {
                            viewModel.requestMoreIfNeeded(breed: breed)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private func listView(items: [Breed]) -> some View {
        List {
            ForEach(items, id: \.id) { breed in
                NavigationLink {
                    //DogsDetailsView(dog: item)
                } label: {
                    dogRow(dog: breed)
                        .padding()
                        .onAppear {
                            viewModel.requestMoreIfNeeded(breed: breed)
                        }
                }
            }
        }
    }

    @ViewBuilder private func dogRow(dog: Breed) -> some View {
        HStack(spacing: 12) {
            if let URL = dog.imageURL {
                listdogPicture(url: URL)
            }
            dogName(dog.name)
            Spacer()
        }
    }

    @ViewBuilder private func listdogPicture(url: URL) -> some View {
        AsyncImage(
            url: url,
            content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(circle
                        .stroke(.gray, lineWidth: 1)
                    )
            },
            placeholder: {
                Image("notfound").resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(circle
                        .stroke(.gray, lineWidth: 1)
                    )
            }
        )
    }

    @ViewBuilder private func gridDogPicture(url: URL) -> some View {

        AsyncImage(
            url: url,
            content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Rectangle())
                    .overlay(rectangle
                        .stroke(.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
            },
            placeholder: {
                Image("notfound").resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Rectangle())
                    .overlay(rectangle
                        .stroke(.gray, lineWidth: 1)
                    )
                    .cornerRadius(8)
            }
        )
        .padding()
    }

    @ViewBuilder private func dogName(_ name: String) -> some View {
        Text(name)
            .font(.subheadline)
            .padding(.horizontal, 8)
    }

    @ViewBuilder private func formatChooser() -> some View {
        Picker("", selection: $layoutFormat) {
            ForEach(LayoutFormat.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }.pickerStyle(.segmented)
    }

    @ViewBuilder private func updatedLayout(items: [Breed]) -> some View {
        switch layoutFormat {
        case .list:
            listView(items: items)
        case .grid:
            gridView(items: items)
        }
    }

    private var sortButton: some View {
        let buttonTitle = self.isSorting ? "Unsort" : "Sort"
        return Button(buttonTitle) {
            isSorting.toggle()
        }
    }

    private enum LayoutFormat:  String, CaseIterable {
        case grid = "Grid"
        case list = "List"
    }

    // MARK: Helper functions

    /**
     This function gets the array of breeds and sorts it if needed

     - Returns: An array of breeds
     */
    func getBreedsArray() -> [Breed] {

        var breedsArray = viewModel.breeds

        if self.isSorting {
            breedsArray.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }

        return breedsArray
    }
}

struct breedsViewController_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = breedsViewModel(requestManager: RequestManager.shared,
                                        databaseManager: dbManager.shared)
        breedsViewController()
            .environmentObject(viewModel)
    }
}
