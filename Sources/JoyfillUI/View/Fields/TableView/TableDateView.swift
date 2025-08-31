//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Vivek on 17/12/24.
//
import SwiftUI
import JoyfillModel

struct TableDateView: View {
    @State private var isDatePickerPresented = false
    @State private var selectedDate: Date = Date()
    @Binding var cellModel: TableCellModel
    private var isUsedForBulkEdit = false
    let datePickerComponent: DatePickerComponents
    @State var dateString: String = ""
    @State var eraseDate: Bool = false
    
    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false) {
        _cellModel = cellModel
        self.isUsedForBulkEdit = isUsedForBulkEdit
        if !isUsedForBulkEdit {
            if let dateValue = cellModel.wrappedValue.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.wrappedValue.data.format ?? .empty) {
                    _dateString = State(initialValue: dateString)
                    if let date = Utility.stringToDate(dateString, format: cellModel.wrappedValue.data.format ?? .empty) {
                        _selectedDate = State(initialValue: date)
                    }
                }
            }
        }
        datePickerComponent = Utility.getDateType(format: cellModel.wrappedValue.data.format ?? .empty)
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            if let dateValue = cellModel.data.date {
                if let dateString = ValueUnion.double(dateValue).dateTime(format: cellModel.data.format ?? .empty) {
                    Text(dateString)
                        .padding(.horizontal, 8)
                        .font(.system(size: 15))
                        .lineLimit(1)
                }
            } else {
                Image(systemName: "calendar")
            }
        } else {
            Group {
                HStack(spacing: 8) {
                    if !dateString.isEmpty {
                        Text(dateString)
                            .font(.system(size: 15))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.blue)
                            .onTapGesture {
                                selectedDate = Date()
                                eraseDate = true
                                dateString = ""
                            }
                    } else {
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .accessibilityIdentifier("CalendarImageIdentifier")
                            .onTapGesture {
                                eraseDate = false
                                selectedDate = Date()
                            }
                        
                        Spacer()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isDatePickerPresented = true
                }
                .padding(.all, 8)
            }
            .datePopup(
                date: $selectedDate,
                components: datePickerComponent,
                isPresented: $isDatePickerPresented,
                onCommit: { _ in }
            )
            .onChange(of: selectedDate) { newValue in
                var cellDataModel = cellModel.data
                cellDataModel.date = eraseDate ? nil : dateToTimestampMilliseconds(date: newValue)
                cellModel.data = cellDataModel
                cellModel.didChange?(cellDataModel)
                
                if let dateString = ValueUnion.double(dateToTimestampMilliseconds(date: newValue)).dateTime(format: cellModel.data.format ?? .empty) {
                    self.dateString = eraseDate ? "" : dateString
                }
            }
        }
    }
}

private final class _DatePopupViewController: UIViewController {
    enum Action { case cancel, done }
    var onClose: ((Action, Date) -> Void)?
    private let picker = UIDatePicker()
    private let dimView = UIControl()
    private let container = UIView()

    init(date: Date, mode: UIDatePicker.Mode) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        dimView.addTarget(self, action: #selector(dimTapped), for: .touchUpInside)

        picker.preferredDatePickerStyle = mode == .dateAndTime ? .inline : .wheels
        picker.datePickerMode = mode
        picker.date = date

        container.backgroundColor = UIColor.secondarySystemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.25
        container.layer.shadowRadius = 12

        let stack = UIStackView(arrangedSubviews: [picker])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dimView)
        view.addSubview(container)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let width: CGFloat = 300
        container.center = view.center
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: width)
        ])
    }

    @objc private func dimTapped() { onClose?(.cancel, picker.date) }
    @objc private func cancelTapped() { onClose?(.cancel, picker.date) }
    @objc private func doneTapped() { onClose?(.done, picker.date) }
}

private struct DatePickerPopup: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var date: Date
    var components: DatePickerComponents
    var onCommit: ((Date) -> Void)?

    final class Coordinator {
        var presented: _DatePopupViewController?
    }
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }

    func updateUIViewController(_ host: UIViewController, context: Context) {
        if isPresented, context.coordinator.presented == nil {
            let mode = mode(for: components)
            let vc = _DatePopupViewController(date: date, mode: mode)
            vc.onClose = { action, newDate in
                date = newDate
                isPresented = false
                if action == .done { onCommit?(newDate) }
            }
            context.coordinator.presented = vc
            host.present(vc, animated: true)
        } else if !isPresented, let vc = context.coordinator.presented {
            vc.dismiss(animated: true) { context.coordinator.presented = nil }
        }
    }

    private func mode(for components: DatePickerComponents) -> UIDatePicker.Mode {
        switch components {
        case [.date]: return .date
        case [.hourAndMinute]: return .time
        default: return .dateAndTime
        }
    }
}

extension View {
    func datePopup(date: Binding<Date>,
                   components: DatePickerComponents,
                   isPresented: Binding<Bool>,
                   onCommit: ((Date) -> Void)? = nil) -> some View {
        background(DatePickerPopup(isPresented: isPresented, date: date, components: components, onCommit: onCommit))
    }
}
