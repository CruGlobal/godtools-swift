import Foundation

class TemplateDomainInterfaceDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: TemplateDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: TemplateDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
}
