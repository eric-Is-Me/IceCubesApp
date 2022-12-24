import SwiftUI
import Timeline
import Network
import KeychainSwift
import Env

@main
struct IceCubesApp: App {
  enum Tab: Int {
    case timeline, notifications, explore, account, settings, other
  }
  
  public static let defaultServer = "mastodon.social"
  
  @StateObject private var appAccountsManager = AppAccountsManager()
  @StateObject private var currentAccount = CurrentAccount()
  @StateObject private var quickLook = QuickLook()
  @State private var selectedTab: Tab = .timeline
  @State private var popToRootTab: Tab = .other
  
  var body: some Scene {
    WindowGroup {
      TabView(selection: .init(get: {
        selectedTab
      }, set: { newTab in
        if newTab == selectedTab {
          /// Stupid hack to trigger onChange binding in tab views.
          popToRootTab = .other
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            popToRootTab = selectedTab
          }
        }
        selectedTab = newTab
      })) {
        TimelineTab(popToRootTab: $popToRootTab)
          .tabItem {
            Label("Timeline", systemImage: "rectangle.on.rectangle")
          }
          .tag(Tab.timeline)
        if appAccountsManager.currentClient.isAuth {
          NotificationsTab(popToRootTab: $popToRootTab)
            .tabItem {
              Label("Notifications", systemImage: "bell")
            }
            .tag(Tab.notifications)
          ExploreTab(popToRootTab: $popToRootTab)
            .tabItem {
              Label("Explore", systemImage: "magnifyingglass")
            }
            .tag(Tab.explore)
          AccountTab(popToRootTab: $popToRootTab)
            .tabItem {
              Label("Profile", systemImage: "person.circle")
            }
            .tag(Tab.account)
        }
        SettingsTabs()
          .tabItem {
            Label("Settings", systemImage: "gear")
          }
          .tag(Tab.settings)
      }
      .tint(.brand)
      .onChange(of: appAccountsManager.currentClient) { newClient in
        currentAccount.setClient(client: newClient)
      }
      .onAppear {
        currentAccount.setClient(client: appAccountsManager.currentClient)
      }
      .environmentObject(appAccountsManager)
      .environmentObject(appAccountsManager.currentClient)
      .environmentObject(quickLook)
      .environmentObject(currentAccount)
      .quickLookPreview($quickLook.url, in: quickLook.urls)
    }
  }
}