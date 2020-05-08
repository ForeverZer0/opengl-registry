# frozen_string_literal: true
module GL

  class Registry

    ##
    # Describes an OpenGL enumeration (constant) value.
    class Enum < Token

      ##
      # @return [String] the name of the enumeration member.
      attr_reader :name

      ##
      # @return [String] the value of the enumeration, always numerical, typically in hexadecimal format.
      attr_reader :value

      ##
      # @return [String?] an alternative name for the value.
      attr_reader :alias_name

      ##
      # @return [Symbol] a hint for the enumeration value type (i.e. GLenum, GLuint, GLuint64, etc)
      attr_reader :type

      ##
      # @return [Symbol?] an API associated with this enumeration value.
      attr_reader :api

      ##
      # @return [Array<String>] an array of names of the groups this enumeration is defined within.
      attr_reader :groups

      ##
      # Creates a new instance of the {Enum} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        # Required
        @name = node[Words::NAME]
        @value = node[Words::VALUE]

        # Optional
        @alias_name = node[Words::ALIAS]
        @api = node[Words::API]&.to_sym
        @groups = node[Words::GROUP]&.split(',') || []

        @type = case node[Words::TYPE]
        when Words::U_LONG then :GLuint
        when Words::U_LONG_LONG then :GLuint64
        else :GLenum
        end
      end

      ##
      # @return [Integer] the enumeration's value, as an integer.
      def to_i
        @value.start_with?('0x') ? @value.hex : @value.to_i
      end
    end
  end
end