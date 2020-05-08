module GL
  class Registry

    ##
    # Describes an individual argument of an OpenGL function.
    class Argument < Token

      ##
      # @return [String] the name of the argument
      attr_reader :name

      ##
      # @return [NativeType] the type of the argument.
      attr_reader :type

      ##
      # @return [String?] a hint for any length constraints of an argument, such as a C-style array,
      # @note This may be a numerical value, reference to another "count" argument, etc.
      attr_reader :length

      ##
      # Creates a new instance of the {Argument} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        base = nil
        buffer = ''
        node.nodes.each do |child|

          # Don't care about comments
          next if child.is_a?(Ox::Comment)

          # Raw text
          if child.is_a?(String)
            buffer << child
            next
          end

          # Child node
          case child.name
          when Words::PTYPE
            base = child.text
            buffer << base
          when Words::NAME
            @name = child.text
          else
            next
          end
        end

        @length = node[Words::LENGTH]
        group = node[Words::GROUP]
        @type = NativeType.new(buffer, base, group)

      end
    end
  end
end