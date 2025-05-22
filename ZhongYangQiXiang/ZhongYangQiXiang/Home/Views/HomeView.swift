//
//  Untitled.swift
//  ZhongYangQiXiang
//
//  Created by 王杰 on 2025/3/21.
//

/*
 •    在编写 SwiftUI 视图时，始终注意 body 属性只返回一个单一视图。
 •    在涉及多个子视图的情况下一律使用合适的容器来包裹它们。

这样记录下来后，可以有效避免将来因返回多个视图导致 Tab 重复显示的问题。
 */
import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        VStack {
            ZStack(alignment: .top) {
                
                // 背景图
                Image(.homeBg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                
                // 自定义导航条
                
                HomeNav()
                    .frame(width: UIScreen.main.bounds.width, height: 44)
                    .padding(.top, 44)   // 顶部内边距 20
                
            }
            // 如果希望直接顶到屏幕最上方（包括刘海 / 灵动岛），可以忽略顶部安全区
            .ignoresSafeArea(edges: .top)
            Spacer()
            
        }
        
        
    }
}
#Preview {
    HomeView()
}


struct HomeNav: View {
    var body: some View {
        ZStack {
            Color.clear
            HStack {
                Button(action: {
                    print("左侧按钮被点击")
                }) {
                    Image(.homeLogo)
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 40, height: 40).background(.yellow)
                Spacer()
                Button(action: {
                    print("右侧按钮被点击")
                    pushTestView()
                }) {
                    Image(.navMy)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    /// 查找当前所在的 UINavigationController，并 push TestView
    private func pushTestView() {
        if let nav = findNavigationController() {
            let testVC = UIHostingController(rootView: TestView())
            testVC.hidesBottomBarWhenPushed = true
            nav.pushViewController(testVC, animated: true)
        }
    }
    
    /// 递归查找当前窗口的 UINavigationController
    private func findNavigationController() -> UINavigationController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else { return nil }
        return traverseForNavigationController(from: rootVC)
    }
    
    private func traverseForNavigationController(from vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController {
            return nav
        } else if let tab = vc as? UITabBarController,
                  let selected = tab.selectedViewController {
            return traverseForNavigationController(from: selected)
        } else {
            for child in vc.children {
                if let nav = traverseForNavigationController(from: child) {
                    return nav
                }
            }
        }
        return nil
    }
}

struct TestView: View {
    var body: some View {
        Text("这是测试页面")
            .font(.title)
            .padding()
        
    }
}

#Preview {
    HomeNav()
}
