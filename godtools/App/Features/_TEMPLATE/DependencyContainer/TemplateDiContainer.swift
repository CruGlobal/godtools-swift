import Foundation

class TemplateDiContainer {
        
    private let dataLayer: TemplateDataLayerDependencies
    
    let domainLayer: TemplateDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = TemplateDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = TemplateDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
