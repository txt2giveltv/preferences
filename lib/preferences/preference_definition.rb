
module HstoreAccessor
  module TypeHelpers
    class << self
      def column_type_for(attribute, data_type)
        ActiveRecord::ConnectionAdapters::Column.new(attribute.to_s, nil, TYPES[data_type].new)
      end

    end
  end
end
module Preferences
  # Represents the definition of a preference for a particular model
  class PreferenceDefinition
    TYPES = {
      boolean: ActiveRecord::Type::Boolean,
      date: ActiveRecord::Type::Date,
      datetime: ActiveRecord::Type::DateTime,
      decimal: ActiveRecord::Type::Decimal,
      float: ActiveRecord::Type::Float,
      integer: ActiveRecord::Type::Integer,
      string: ActiveRecord::Type::String
    }

    TYPES.default = ActiveRecord::Type::Value

    # The data type for the content stored in this preference type
    attr_reader :type

    def initialize(name, *args) #:nodoc:
      options = args.extract_options!
      options.assert_valid_keys(:default, :group_defaults)

      @type = args.first ? args.first.to_sym : :boolean

      cast_type = if @type == :any
        nil
      else
        ActiveRecord::Type.const_get(@type.to_s.camelize).new
      end

      # Create a column that will be responsible for typecasting
      @column = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, options[:default], cast_type)

      @group_defaults = (options[:group_defaults] || {}).inject({}) do |defaults, (group, default)|
        defaults[group.is_a?(Symbol) ? group.to_s : group] = type_cast(default)
        defaults
      end
    end

    # The name of the preference
    def name
      @column.name
    end

    # The default value to use for the preference in case none have been
    # previously defined
    def default_value(group = nil)
      @group_defaults.include?(group) ? @group_defaults[group] : @column.default
    end

    # Determines whether column backing this preference stores numberic values
    def number?
      @column.number?
    end

    # Typecasts the value based on the type of preference that was defined.
    # This uses functionality added in to ActiveRecord's attributes api in Rails 5
    # so the same rules for typecasting a model's columns apply here.
    def type_cast(value)
      @type == :any ? value : cast(@column.type, value)
    end

    def cast(type, value)
      return nil if value.nil?

      case type
      when :string, :decimal
        value
      when :integer, :float, :datetime, :date, :boolean
        TYPES[type].new.cast(value)
      else value
        # Nothing.
      end
    end

    # Typecasts the value to true/false depending on the type of preference
    def query(value)
      if !(value = type_cast(value))
        false
      elsif number?
        !value.zero?
      else
        !value.blank?
      end
    end
  end
end
