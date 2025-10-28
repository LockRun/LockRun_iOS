//
//  CalendarView.swift
//  LockRun
//
//  Created by 전준영 on 10/23/25.
//

import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    
    @ObservedObject var viewStore: ViewStoreOf<CalendarRe>
    @State private var swipeDirection: SwipeDirection = .none
    private enum SwipeDirection { case left, right, none }
    
    init(store: StoreOf<CalendarRe>) {
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            WeekdayHeaderView()
            
            DatesGridView(viewStore: viewStore)
                .id(viewStore.currentDate)
                .transition(swipeDirection == .left
                            ? .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity))
                            : .asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity))
                )
                .animation(.easeInOut(duration: 0.3), value: viewStore.currentDate)
        }
        .padding(.top, 20)
        .onChange(of: viewStore.currentDate) { oldDate, newDate in
            let offset = Calendar.current.dateComponents([.month], from: Date(), to: newDate).month ?? 0
            viewStore.send(.updateMonth(offset))
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width < -20 {
                        swipeDirection = .left
                        viewStore.send(.didSwipeLeft)
                    } else if gesture.translation.width > 20 {
                        swipeDirection = .right
                        viewStore.send(.didSwipeRight)
                    }
                }
        )
    }
}

#Preview {
    CalendarView(
        store: Store(initialState: CalendarRe.State()) {
            CalendarRe()
        }
    )
}
