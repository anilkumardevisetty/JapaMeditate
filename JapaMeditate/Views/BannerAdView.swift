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
        
        view.adUnitID = Self.adUnitID
        view.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
        view.load(Request())
        
        return view
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static var adUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"
        #else
        return "ca-app-pub-7815543279664023/2810774434"
        #endif
    }
    
}


struct StyledBanner: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    
    var body: some View {
        BannerAdView()
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTheme.background)
                    .shadow(radius: 4)
            )
    }
}
