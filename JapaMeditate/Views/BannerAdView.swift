//
//  BannerAdView.swift
//  Japa108App
//
//  Created by Anilkumar Devisetty on 11/17/25.
//
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {

    func makeUIView(context: Context) -> BannerView {
        let view = BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width - 40))
        
        view.adUnitID = "ca-app-pub-7815543279664023/2810774434"
        view.rootViewController = UIApplication.shared.windows.first?.rootViewController
        view.load(Request())
        
        return view
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
    
}


struct StyledBanner: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    
    var body: some View {
        BannerAdView()
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTheme.background)
                    .shadow(radius: 4)
            )
            .padding(.horizontal)
    }
}
