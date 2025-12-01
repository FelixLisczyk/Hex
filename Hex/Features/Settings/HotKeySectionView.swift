import ComposableArchitecture
import HexCore
import Inject
import SwiftUI

struct HotKeySectionView: View {
    @ObserveInjection var inject
    @Bindable var store: StoreOf<SettingsFeature>

    var body: some View {
        Section("Hot Key") {
            let hotKey = store.hexSettings.hotkey
            let key = store.isSettingHotKey ? nil : hotKey.key
            let modifiers = store.isSettingHotKey ? store.currentModifiers : hotKey.modifiers

            VStack(spacing: 12) {
                // Hot key view
                HStack {
                    Spacer()
                    HotKeyView(modifiers: modifiers, key: key, isActive: store.isSettingHotKey)
                        .animation(.spring(), value: key)
                        .animation(.spring(), value: modifiers)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    store.send(.startSettingHotKey)
                }

                if !store.isSettingHotKey,
                   hotKey.key == nil,
                   !hotKey.modifiers.isEmpty {
                    ModifierSideControls(
                        modifiers: hotKey.modifiers,
                        onSelect: { kind, side in
                            store.send(.setModifierSide(kind, side))
                        }
                    )
                    .transition(.opacity)
                }
            }

            // Recording Mode picker
            Label {
                Picker("Recording Mode", selection: $store.hexSettings.recordingMode) {
                    Text("Hold to Record").tag(RecordingMode.holdToRecord)
                    Text("Tap to Toggle").tag(RecordingMode.tapToToggle)
                }
                .pickerStyle(.segmented)
            } icon: {
                Image(systemName: "hand.tap")
            }

            // Minimum key time slider (available for all hotkey types in both modes)
            Label {
                Slider(
                    value: $store.hexSettings.minimumKeyTime,
                    in: 0.0 ... HexCoreConstants.maximumMinimumKeyTime,
                    step: 0.1
                ) {
                    Text("Minimum hold time: \(store.hexSettings.minimumKeyTime, specifier: "%.1f")s")
                }
            } icon: {
                Image(systemName: "clock")
            }

            // Accessibility note for modifier-only hotkeys
            if store.hexSettings.hotkey.key == nil {
                Text("Modifier-only hotkeys enforce a 0.3s minimum to avoid conflicts with system shortcuts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .enableInjection()
    }
}

private struct ModifierSideControls: View {
    @ObserveInjection var inject
    var modifiers: Modifiers
    var onSelect: (Modifier.Kind, Modifier.Side) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(modifiers.kinds, id: \.self) { kind in
                if kind.supportsSideSelection {
                    let binding = Binding<Modifier.Side>(
                        get: { modifiers.side(for: kind) ?? .either },
                        set: { onSelect(kind, $0) }
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(kind.symbol) \(kind.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Picker("Modifier side", selection: binding) {
                            ForEach(Modifier.Side.allCases, id: \.self) { side in
                                Text(side.displayName)
                                    .tag(side)
                                    .disabled(!kind.supportsSideSelection && side != .either)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
        }
        .enableInjection()
    }
}
