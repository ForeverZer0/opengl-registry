module GL
  class Registry

    ##
    # Describes a logical grouping of features for an OpenGL API.
    class FeatureGroup < FeatureProvider

      ##
      # @return [String] the OpenGL version this feature is associated with.
      attr_reader :version

      ##
      # @return [Array<Feature>] an array of features that this instance removes.
      attr_reader :removals

      ##
      # Creates a new instance of the {Feature} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        @version = node[Words::NUMBER]
        @removals = []
        node.locate('remove').each do |child|

          api = child[Words::API]&.to_sym || @api
          profile = child[Words::PROFILE]&.to_sym

          child.nodes.each do |item|
            next unless item.is_a?(Ox::Element)
            @removals << Feature.new(item, api, profile)
          end
        end
      end
    end
  end
end