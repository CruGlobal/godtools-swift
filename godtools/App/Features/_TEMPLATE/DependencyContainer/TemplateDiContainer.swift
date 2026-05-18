import Foundation

final class TemplateDiContainer {
        
    private let dataLayer: TemplateDataLayerDependencies
    
    let domainLayer: TemplateDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        self.dataLayer = TemplateDataLayerDependencies(coreDataLayer: core.dataLayer)
        self.domainLayer = TemplateDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
