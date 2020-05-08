module GL
  class Registry

    ##
    # Describes a single definition of a item to add/remove from an OpenGL API.
    #
    # @note This is a reference for the item only, and is only used to look up the corresponding item's definition.
    class Feature < Token

      ##
      # @return [String] the name of the entity.
      attr_reader :name

      ##
      # @return [Symbol] the OpenGL API this item is associated with.
      attr_reader :api

      ##
      # @return [Symbol] the OpenGL profile this item is associated with.
      attr_reader :profile

      ##
      # @return [:enum,:function,:type] a symbol specifying the feature type.
      attr_reader :type

      ##
      # Creates a new instance of the {Feature} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      # @param api [Symbol?] The OpenGL API this item is associated with.
      # @param profile [Symbol?] The OpenGL profile this item is associated with.
      def initialize(node, api, profile)
        super(node)

        @name = node[Words::NAME]
        @api = api || :none
        @profile = profile || :none

        @type = case node.name
        when Words::ENUM then :enum
        when Words::COMMAND then :function
        when Words::TYPE then :type
        else :unknown
        end
      end
    end
  end
end