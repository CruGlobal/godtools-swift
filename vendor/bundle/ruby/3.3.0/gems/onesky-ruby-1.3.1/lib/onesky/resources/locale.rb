module Resources
  module Locale

    def list_locale
      get('/locales')
    end

  end
end
