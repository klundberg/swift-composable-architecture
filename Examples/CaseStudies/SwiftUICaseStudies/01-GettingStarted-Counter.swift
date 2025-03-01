import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates the basics of the Composable Architecture in an archetypal counter \
  application.

  The domain of the application is modeled using simple data types that correspond to the mutable \
  state of the application and any actions that can affect that state or the outside world.
  """

@Reducer
struct Counter {
  @ObservableState
  struct State: Equatable {
    var count = 0
  }

  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
    case appeared
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        return .none
      case .incrementButtonTapped:
        state.count += 1
        return .none
      case .appeared:
        var fx: [EffectOf<Self>] = []
        for _ in 1...10000 {
          fx.append(.run { send in try await Task.sleep(for: .milliseconds(100)) })
        }
        fx.append(.run { send in
          try await Task.never()
        })
        return .merge(fx)
      }
    }
  }
}

struct CounterView: View {
  let store: StoreOf<Counter>

  var body: some View {
    HStack {
      Button {
        store.send(.decrementButtonTapped)
      } label: {
        Image(systemName: "minus")
      }

      Text("\(store.count)")
        .monospacedDigit()

      Button {
        store.send(.incrementButtonTapped)
      } label: {
        Image(systemName: "plus")
      }
    }
  }
}

struct CounterDemoView: View {
  let store: StoreOf<Counter>

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }

      Section {
        CounterView(store: store)
          .frame(maxWidth: .infinity)
      }
    }
    .task {
      await store.send(.appeared).finish()
    }
    .buttonStyle(.borderless)
    .navigationTitle("Counter demo")
  }
}

#Preview {
  NavigationStack {
    CounterDemoView(
      store: Store(initialState: Counter.State()) {
        Counter()
      }
    )
  }
}
