module GL
  class Registry

    ##
    # @abstract Base class for OpenGL registry defined items.
    class Token

      ##
      # @return [String?] an arbitrary comment associated with this object.
      attr_reader :comment

      ##
      # Creates a new instance of the {Token} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        raise ArgumentError, 'item node cannot be nil' unless node

        @comment = node[Words::COMMENT]
      end

      ##
      # @return [String] the string representation of this object.
      def to_s
        @name || super
      end
    end
  end
end