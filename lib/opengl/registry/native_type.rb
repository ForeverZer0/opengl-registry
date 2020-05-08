
module GL
  class Registry

    ##
    # Describes the native type for a return or parameter value.
    class NativeType

      ##
      # @return [String] the full native type, including constant constraints, pointer symbols, etc.
      # @note This is essentially the "raw" and fully-qualified type as it would appear in the C language.
      attr_reader :type

      ##
      # @return [Symbol] the basic type, excluding any constant constraints, pointer symbols, etc. as a Symbol.
      attr_reader :base

      ##
      # @return [String?] a group that is associated with this type.
      attr_reader :group

      ##
      # Creates a new instance fo the {NativeType} class.
      #
      # @param type [String] The full native type, including constant constraints, pointer symbols, etc.
      # @param base [String?] The basic type, excluding any constant constraints, pointer symbols, etc.
      # @param group [String?] A group that is associated with this type.
      def initialize(type, base, group)
        @type = type.strip
        @base = base ? base.to_sym : :GLvoid
        @group = group
      end

      ##
      # @return [Boolean] `true` if this a C-style pointer type, otherwise `false`.
      def pointer?
        @type.include?('*')
      end

      ##
      # @return [Boolean] `true` if value is a C-style pointer that can not be modified, otherwise `false`.
      def const?
        /^const /.match?(@type)
      end

      ##
      # @return [Boolean] `true` if value is a C-style pointer that may be modified, otherwise `false`.
      def out?
        @type.include?('*') && !/\bconst\b/.match?(@type)
      end

      ##
      # @return [String] the string representation of this object.
      def to_s
        @type
      end
    end
  end
end