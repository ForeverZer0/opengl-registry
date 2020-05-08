module GL
  class Registry

    ##
    # Describes an OpenGL function.
    class Function < Token

      ##
      # @return [String] the name of the function.
      attr_reader :name

      ##
      # @return [NativeType] the return type of function.
      attr_reader :type

      ##
      # @return [Array<Argument>] an array of arguments for this function.
      attr_reader :arguments

      ##
      # @return [String?] an alternative name associated with this function.
      attr_reader :alias_name

      ##
      # @return [String?] a "vector equivalent" version of this function that does not use separate parameters.
      attr_reader :vec_equiv

      ##
      # Creates a new instance of the {Function} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        @arguments = []
        node.nodes.each do |child|

          case child.name
          when Words::PROTO
            parse_prototype(child)
          when Words::PARAM
            @arguments << Argument.new(child)
          when Words::ALIAS
            @alias_name = child[Words::NAME]
          when Words::VECTOR_EQUIVALENT
            @vec_equiv = child[Words::NAME]
          else
            next
          end
        end
      end

      private

      def parse_prototype(node)
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

        group = node[Words::GROUP]
        @type = NativeType.new(buffer, base, group)
      end
    end
  end
end