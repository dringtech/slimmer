module Slimmer
  module TestHelpers
    module SharedTemplates
      def shared_component_should_be_loaded(name)
        page.should have_css("div[class='govuk_component-#{name}']")
      end
    end
  end
end
