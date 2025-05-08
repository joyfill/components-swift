//
//  DocumentListView.swift
//  JoyFill
//

import SwiftUI
import JoyfillAPIService
import JoyfillModel

public struct TemplateListView: View {
    @State var documents: [Document] = []
    @State var templates: [Document]
    @State var fetchSubmissions = false
    @State var createSubmission = false
    @State var showNewSubmission = false
    private var apiService: APIService
    @State var document: JoyDoc?
    @State private var currentTemplatePage: Int = 1
    @State private var isLoadingMoreTemplates: Bool = false
    @State private var hasMoreTemplates: Bool = true
    @State private var searchText: String = ""
    var isAlreadyToken: Bool
    let imagePicker = ImagePicker()
    
    init(userAccessToken: String, result: ([Document],[Document]), isAlreadyToken: Bool) {
        self.isAlreadyToken = isAlreadyToken
        if isAlreadyToken {
            self.apiService = APIService(accessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk",
                                         baseURL: "https://api-joy.joyfill.io/v1")
        } else {
            self.apiService = APIService(accessToken: userAccessToken,
                                         baseURL: "https://api-joy.joyfill.io/v1")
        }
        
        self.templates = result.0
    }
    
    private var changeManager: ChangeManager {
        return ChangeManager(
            apiService: apiService,
            showImagePicker: imagePicker.showPickerOptions
        )
    }
    
    private var filteredTemplates: [Document] {
        if searchText.isEmpty {
            return templates
        } else {
            return templates.filter { template in
                template.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    public var body: some View {
        VStack {
            TemplateSearchView(searchText: $searchText)
            
            if filteredTemplates.isEmpty {
                ProgressView()
                    .onAppear {
                        fetchData()
                    }
            } else {
                List {
                    Section(header: Text("Templates")
                        .font(.title.bold())) {
                            ForEach(filteredTemplates) { template in
                                VStack(alignment: .trailing) {
                                    NavigationLink {
                                        DocumentSubmissionsListView(apiService: apiService, identifier: template.identifier,
                                                                    title: String(template.identifier.suffix(8)))
                                    } label: {
                                        HStack {
                                            Image(systemName: "doc")
                                                .padding(5)
                                            Text(template.name)
                                        }
                                    }
                                    
                                    if showNewSubmission {
                                        NavigationLink("", destination: FormContainerView(document: document!, pageID: "", changeManager: changeManager), isActive: $showNewSubmission)
                                    }
                                    
                                    Button(action: {
                                        createDocumentSubmission(identifier: template.identifier, completion: { _ in })
                                    }, label: {
                                        Text("Fill New +")
                                    })
                                    .buttonStyle(.borderedProminent)
                                }
                                .onAppear {
                                    if template == templates.last {
                                        loadMoreTemplates()
                                    }
                                }
                            }
                            .padding(20)
                            .border(Color.gray, width: 2)
                            .cornerRadius(2)
                        }
                        .refreshable {
                            fetchSubmissions = true
                        }
                }
                
                if isLoadingMoreTemplates {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(isAlreadyToken)
    }
    
    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
    }
    
    private func loadMoreTemplates() {
        guard !isLoadingMoreTemplates, hasMoreTemplates else { return }
        isLoadingMoreTemplates = true
        let nextPage = currentTemplatePage + 1
        
        apiService.fetchTemplates(page: nextPage, limit: 10) { result in
            DispatchQueue.main.async {
                isLoadingMoreTemplates = false
                switch result {
                case .success(let newTemplates):
                    if newTemplates.isEmpty {
                        hasMoreTemplates = false
                    } else {
                        templates.append(contentsOf: newTemplates)
                        currentTemplatePage = nextPage
                    }
                case .failure(let error):
                    print("Error loading more templates: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension TemplateListView {
    func fetchData() {
        if templates.count <= 0 {
            fetchTemplates() {                 
            }
        } else {
            fetchSubmissions =  false
        }
    }
    
    private func allDocuments(for templateIdentifier: String) -> [Document] {
        let documentsWithSourceAsTemplate =  documents.filter { document in
            document.source == templateIdentifier
        }
        var documentsWithSourceAsDoc = [Document]()
        documentsWithSourceAsTemplate.forEach { document in
            documentsWithSourceAsDoc = documents.filter {  $0.source?.contains(document.id) ?? false }
        }
        return documentsWithSourceAsDoc + documentsWithSourceAsTemplate
    }
    
    private func fetchTemplates(completion:  @escaping () -> Void) {
        apiService.fetchTemplates { result in
            switch result {
            case .success(let templates):
                self.templates = templates
            case .failure(let error):
                print("Error fetching templates: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    private func createDocumentSubmission(identifier: String, completion: @escaping ((Any) -> Void)) {
        self.createSubmission = true
        apiService.createDocumentSubmission(identifier: identifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let jsonRes):
                    let dictionary = (jsonRes as! [String: Any])
                    self.document = JoyDoc(dictionary: dictionary)
                    self.createSubmission = false
                    showNewSubmission = true
                    break
                case .failure(let error):
                    print("Error creating submission: \(error.localizedDescription)")
                }
            }
        }
    }
}
