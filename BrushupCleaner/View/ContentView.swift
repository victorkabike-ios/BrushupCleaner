//
//  ContentView.swift
//  BrushupCleaner
//
//  Created by victor kabike on 2023/07/08.
//

import SwiftUI
import Photos
import CoreImage

struct ContentView: View {
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var photoPermissionGranted = false
    @State private var contactPermissionGranted = false
    @State private var calendarPermissionGranted = false

    @State private var storageUsed: Double = 0
    @EnvironmentObject var photoViewModel: PhotoviewModel
    @EnvironmentObject  var contactsViewModel: ContactViewModel
    @EnvironmentObject  var videoViewModel: VideoViewModel
    @EnvironmentObject var  userModel: UserViewModel
        
    @State private var duplicatePhotos: [PHAsset] = []
    @State private var showingSimilarPhotoView = false
    @State private var showingSimilarVideoView = false
    
    @State private var showingDuplicateContactsView = false
    @State private var showSmartview = false
    var body: some View {
            ZStack{
                Color("backgroundColor")
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                if hasCompletedOnboarding {
                    // Your main app content here
                    NavigationStack{
                        ZStack{
                            Color("backgroundColor")
                                .opacity(0.6)
                                .edgesIgnoringSafeArea(.all)
                            VStack(spacing: 15){
                                if photoViewModel.isFetching{
                                    ProgressView {
                                        Text("Loading")
                                    }
                                    .progressViewStyle(CircularProgressViewStyle())
                                }else{
                                    LazyVStack{
                                        VStack(spacing: 25){
                                            HStack(spacing: 20){
                                                Spacer()
                                                NavigationLink {
                                                    PaywallView().navigationBarHidden(true)
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "crown.fill")
                                                            .foregroundColor(.yellow)
                                                        Text("Unlock Premium")
                                                            .foregroundColor(.white)
                                                            .bold()
                                                    }
                                                    .padding(8)
                                                }
                                                NavigationLink {
                                                    SettingsView()
                                                } label: {
                                                    Image(systemName: "gearshape.fill")
                                                        .font(.title2)
                                                        .foregroundColor(Color.white)
                                                }
                                                
                                            }.padding(.bottom,20)
                                            Section{
                                                VStack{
                                                    VStack{
                                                        StorageView()
                                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        Button(action: {
                                                            showSmartview = true
                                                        }) {
                                                            Label("Smart clean", systemImage: "paintbrush.fill")
                                                                .font(.title2)
                                                                .fontWeight(.semibold)
                                                                .foregroundColor(Color.white)
                                                                .frame(width: 350, height: 60)
                                                                .background(Color.blue)
                                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                        }
                                                        .padding(.top, 16)
                                                    }
                                                    .padding()
                                                    
                                                }
                                                
                                                
                                            }
                                        }.padding(.horizontal)
                                        
                                        
                                        NavigationLink {
                                            PhotoView(headerHeight: 100)
                                                .environmentObject(photoViewModel)
                                                .environmentObject(userModel)
                                                .navigationBarBackButtonHidden(true)
                                                .onAppear{
                                                    photoViewModel.fetchAndCategorizeLivePhotos()
                                                    photoViewModel.fetchAndCategorizePhotos()
                                                    photoViewModel.fetchAndCategorizeScreenshotPhotos()
                                                }
                                        } label: {
                                            GroupBox{
                                                ContentSectionView(icon: "photo.on.rectangle.angled", iconBackgroundColor: Color.green, title: "Photos")
                                            }.groupBoxStyle(CustomGroupBoxStyle(color: Color("backgroundColor").opacity(0.6)))
                                        }
                                        
                                        
                                        NavigationLink {
                                            VideoView().navigationBarBackButtonHidden(true)
                                        } label: {
                                            GroupBox{
                                                ContentSectionView(icon: "video.fill", iconBackgroundColor: Color.red, title: "Videos")
                                            }.groupBoxStyle(CustomGroupBoxStyle(color: Color("backgroundColor").opacity(0.6)))
                                        }
                                        NavigationLink {
                                            DuplicateContactsView().navigationBarBackButtonHidden(true)
                                        } label: {
                                            GroupBox{
                                                let similarContactsCount = contactsViewModel.duplicateContacts.reduce(0) { $0 + $1.value.count }
                                                ContentSectionView(icon: "person.fill", iconBackgroundColor: Color.purple, title: "Contacts")
                                            }.groupBoxStyle(CustomGroupBoxStyle(color: Color("backgroundColor").opacity(0.6)))
                                        }
                                    }
                                }
                            }
                        }
                        .onAppear{
                            if !(photoPermissionGranted && contactPermissionGranted && calendarPermissionGranted) {
                                requestPermissions()
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showSmartview) {
                        SmartCleanView()
                            .environmentObject(photoViewModel)
                            .environmentObject(videoViewModel)
                            .background(
                                Color("backgroundColor")
                                    .opacity(0.4)
                            )
                            .onAppear{
                                photoViewModel.fetchAndCategorizePhotos()
                                photoViewModel.fetchAndCategorizeLivePhotos()
                                photoViewModel.fetchAndCategorizeScreenshotPhotos()
                                videoViewModel.fetchLargeSizeVideos()
                                contactsViewModel.fetchContacts()
                            }
                    }
                    
                } else {
                    OnboardingView1()
                }
            }
    }
    func requestPermissions() {
            AuthorizationUtilities.requestPhotoPermission { granted in
                photoPermissionGranted = granted
            }

            AuthorizationUtilities.requestContactPermission { granted in
                contactPermissionGranted = granted
            }

            AuthorizationUtilities.requestCalendarPermission { granted in
                calendarPermissionGranted = granted
            }
        }
    }


struct ContentSectionView: View  {
    var icon: String
    var iconBackgroundColor: Color
    var title: String
    var body: some View {
            HStack(spacing: 18){
                Image(systemName: icon)
                    .foregroundColor(Color(UIColor.white))
                    .frame(width: 50, height: 50)
                    .background(iconBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading){
                    Text(title)
                        .font(.title2)
                        .foregroundColor(Color.white)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .fontWeight(.light)
            }
    }
}
