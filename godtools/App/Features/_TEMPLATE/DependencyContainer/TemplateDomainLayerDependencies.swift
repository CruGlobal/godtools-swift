import Foundation

final class TemplateDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: TemplateDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: TemplateDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
}
