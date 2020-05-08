module GL
  class Registry

    ##
    # Describes a logical grouping of enumerated values.
    class Group < Token

      ##
      # @return [String] the namespace this group belongs within.
      attr_reader :namespace

      ##
      # @return [Array<Enum>] an array of enum values that are associated with this group.
      attr_reader :members

      ##
      # @return [String?] the name of this grouping.
      # @note Not all groups are named, and this value may be `nil`.
      attr_reader :name

      ##
      # @return [String?] the name of the vendor that defines this value.
      attr_reader :vendor

      ##
      # @return [Range?] an end-inclusive range of values this group covers.
      attr_reader :range

      ##
      # Creates a new instance of the {Group} class.
      #
      # @param node [Ox::Element] The XML element defining the instance.
      def initialize(node)
        super(node)

        @namespace = node[Words::NAMESPACE]
        @name = node[Words::GROUP]
        type = node[Words::TYPE]
        @bitmask = type && type == Words::BITMASK
        @vendor = node[Words::VENDOR]

        first = node[Words::RANGE_START]
        if first
          last = node[Words::RANGE_END]
          @range = Range.new(first.hex, last.hex, false) if last
        end

        @members = []
        node.locate('enum').each do |enum|
          next unless enum.is_a?(Ox::Element)
          @members << Enum.new(enum)
        end
      end

      ##
      # @return [Boolean] `true` if group members are flags that can be bitwise OR'ed together, otherwise `false`.
      def bitmask?
        @bitmask
      end
    end
  end
end