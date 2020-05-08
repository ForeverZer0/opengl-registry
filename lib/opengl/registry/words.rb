# frozen_string_literal: true

module GL

  class Registry

    ##
    # Strongly-typed values for common XML element/attribute names.
    module Words

      ENUM = 'enum'
      COMMAND = 'command'
      REGISTRY = 'registry'
      COMMENT = 'comment'
      NAMESPACE = 'namespace'
      GROUP = 'group'
      NAME = 'name'
      RANGE_START = 'start'
      RANGE_END = 'end'
      API = 'api'
      ALIAS = 'alias'
      TYPE = 'type'
      VENDOR = 'vendor'
      VALUE = 'value'
      PROTO = 'proto'
      PTYPE = 'ptype'
      PARAM = 'param'
      GLX = 'glx'
      VECTOR_EQUIVALENT = 'vecequiv'
      LENGTH = 'len'
      NUMBER = 'number'
      PROFILE = 'profile'
      SUPPORTED = 'supported'
      U_LONG = 'u'
      U_LONG_LONG = 'ull'
      BITMASK = 'bitmask'
    end
  end
end