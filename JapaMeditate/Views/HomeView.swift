import SwiftUI
import Combine

struct HomeView: View {
    @AppStorage("selectedTheme") private var selectedTheme: AppTheme = .saffron
    @State private var stats: JapaStats = JapaStatsManager.shared.load()
    
    let motivationQuotes = [
        "“Chant with devotion and the mind becomes light.”",
        "“One mantra can transform your entire day.”",
        "“Every breath is a chance to return to peace.”",
        "“Stillness begins with a single chant.”",
        "“Meditation is food for the soul.”",
        "“A calm mind is the greatest spiritual gift.”",
        "“Repeat softly, feel deeply, awaken gently.”",
        "“Consistency brings spiritual strength.”",
        "“Your practice today shapes your peace tomorrow.”"
    ]


    var body: some View {
        NavigationStack {
            ZStack {
                selectedTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 30) {

                        // MARK: Header
                        VStack(spacing: 4) {
                            Text("Japa & Meditation")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            Text("Daily Mantra Japa & Meditation")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        
                        // MARK: Greeting + Motivation
                        VStack(spacing: 6) {
                            ClockView()
                            
                            Text(greetingMessage())
                                .font(.title.bold())
                                .foregroundColor(.white)

                            Text(randomMotivation)
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)

                        }
                        .padding(.top, 10)

                        
                        // MARK: Main Actions
                        VStack(spacing: 16) {
                            NavigationLink(destination: CounterView()) {
                                LargeActionButton(icon: "hands.clap", title: "Start Japa")
                            }

                            NavigationLink(destination: MeditationView()) {
                                LargeActionButton(icon: "figure.mind.and.body", title: "Start Meditation")
                            }
                        }
                        .padding(.horizontal)
                        
//                        VStack {
//                            StyledBanner() // 👈 looks like part of the UI
//                                .padding(.bottom, 1)
//                        }

                        // MARK: Japa Stats Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Japa Stats")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))

                            HStack {
                                StatBox(title: "Rounds", value: "\(todayRounds())")
                                StatBox(title: "Streak", value: "\(stats.currentStreak)")
                                StatBox(title: "Best", value: "\(stats.bestStreak)")
                            }

                            NavigationLink(destination: StatsView()) {
                                HStack {
                                    Text("View Japa Stats")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // MARK: Meditation Stats Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meditation Stats")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))

                            HStack {
                                StatBox(title: "Sessions", value: "\(stats.lifetimeMeditationSessions)")
                                StatBox(title: "Minutes", value: "\(stats.lifetimeMeditationMinutes)")
                                StatBox(title: "Avg", value: averageMinutes())
                            }

                            NavigationLink(destination: MeditationStatsView()) {
                                HStack {
                                    Text("View Meditation Stats")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                        .padding(.horizontal)

                        // MARK: Tools Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {

                            NavigationLink(destination: ThemeView()) {
                                SmallCard(icon: "paintpalette.fill", title: "Themes")
                            }

                            NavigationLink(destination: SettingsView()) {
                                SmallCard(icon: "gearshape.fill", title: "Settings")
                            }

//                            NavigationLink(destination: StatsView()) {
//                                SmallCard(icon: "chart.bar.fill", title: "Japa Stats")
//                            }
                        }
                        .padding(.horizontal)

                        // MARK: Quote
                        Text("“Chanting purifies the mind & uplifts the soul.”")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            stats = JapaStatsManager.shared.load()
        }
    }

    // MARK: Helpers
    
    func todayRounds() -> Int {
        let today = formattedDate(Date())
        return stats.dailyRounds[today, default: 0]
    }

    func averageMinutes() -> String {
        if stats.lifetimeMeditationSessions == 0 { return "0" }
        let avg = stats.lifetimeMeditationMinutes / stats.lifetimeMeditationSessions
        return "\(avg)"
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    
    func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning 🌞"
        case 12..<17:
            return "Good Afternoon 🌤"
        case 17..<22:
            return "Good Evening 🌙"
        default:
            return "Welcome 🙏"
        }
    }
    
    var randomMotivation: String {
        motivationQuotes.randomElement() ?? ""
    }
}
