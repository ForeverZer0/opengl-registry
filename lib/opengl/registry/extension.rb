module GL
  class Registry

    ##
    # Describes an OpenGL extension.
    class Extension < FeatureProvider

      ##
      # @return [Array<Symbol>] an array of supported APIs this extension is associated with.
      attr_reader :supported

      ##
      # Creates a new instance of the {Extension} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)
        supported = node[Words::SUPPORTED]
        @supported = supported ? supported.split('|').map(&:to_sym) : Array.new
      end
    end
  end
end