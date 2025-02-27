//
//  TabBarView.swift
//  SmileCheck
//
//  Created by Gabriel Haskell on 11/9/24.
//

import SwiftUI
import SuperwallKit

struct TabBarView: View {
    @Binding var selectedTab: Int
    @State private var resetUploadPicture: Bool = false
    @State private var showTabBarView: Bool = true
    @State private var userLogout: Bool = false

    @EnvironmentObject var globalContent: GlobalContent

    var body: some View {
        ZStack{
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            if showTabBarView {
                ZStack {
                    Color("BackgroundColor")
                        .edgesIgnoringSafeArea(.all)
                    TabView(selection: $selectedTab) {
                        UploadPictureView(reset: $resetUploadPicture)
                            .tabItem {
                                Image(systemName: "camera")
                                    .font(.title2)
                                Text("Scan")
                                    .font(.caption)
                            }
                            .tag(0)
                            .navigationViewStyle(.stack)
                        
                        HistoryView()
                            .tabItem {
                                Image(systemName: "chart.bar")
                                    .font(.title2)
                                Text("Progress")
                                    .font(.caption)
                            }
                            .tag(1)
                            .navigationViewStyle(.stack)

                        
                        RoutineView()
                            .tabItem {
                                Image(systemName: "list.dash")
                                    .font(.title2)
                                Text("Routine")
                                    .font(.caption)
                            }
                            .tag(2)
                            .navigationViewStyle(.stack)

                        
                        ProductsView()
                            .tabItem {
                                Image(systemName: "cart.fill")
                                    .font(.title2)
                                Text("Products")
                                    .font(.caption)
                            }
                            .tag(3)
                            .navigationViewStyle(.stack)

                    }
                    .toolbarBackground(.white, for: .tabBar)
                    .toolbarBackground(.visible, for: .tabBar)
                    .toolbarColorScheme(.light, for: .tabBar)
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                    .tabViewStyle(DefaultTabViewStyle())
                    .onChange(of: resetUploadPicture) { _ in
                        resetUploadPicture = false
                    }
                    .onChange(of: selectedTab) { newTab in
                        if newTab != 0 { // Do not trigger paywall if "Upload Picture" tab is selected
                            Superwall.shared.register(event: "tab_trigger")
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .analysisStarted)) { _ in
                        showTabBarView = false
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
                        showTabBarView = false
                        userLogout = true
                    }
                }
            } else {
                if userLogout {
                    StartPageView()
                } else {
                    if let imageData = globalContent.globalImage, let uiImage = UIImage(data: imageData) {
                        AnalysisPage(selectedImage: uiImage)
                    } else {
                        Text("No image available")
                    }
                }
            }
        }
    }
}

