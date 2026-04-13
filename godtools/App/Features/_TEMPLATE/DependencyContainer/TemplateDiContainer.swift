import Foundation

class TemplateDiContainer {
        
    private let dataLayer: TemplateDataLayerDependencies
    
    let domainLayer: TemplateDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.dataLayer = TemplateDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = TemplateDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
