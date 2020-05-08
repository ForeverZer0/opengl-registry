module GL
  class Registry

    ##
    # @abstract Base class for objects that add definitions to the API.
    class FeatureProvider < Token

      ##
      # @return [Symbol] the name of the API this feature is defined within.
      attr_reader :api

      ##
      # @return [String] the name of the feature set.
      attr_reader :name

      ##
      # @return [Array<Feature>] an array of features that this instance provides.
      attr_reader :additions

      ##
      # Creates a new instance of the {FeatureProvider} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        @api = node[Words::API]&.to_sym || :none
        @name = node[Words::NAME]

        @additions = []
        node.locate('require').each do |child|

          api = child[Words::API]&.to_sym || @api
          profile = child[Words::PROFILE]&.to_sym

          child.nodes.each do |item|
            next unless item.is_a?(Ox::Element)
            @additions << Feature.new(item, api, profile)
          end
        end
      end

    end
  end
end