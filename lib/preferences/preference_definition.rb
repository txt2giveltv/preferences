# frozen_string_literal: true

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
      options = args.extract_options! # {} default
      options.assert_valid_keys(:default, :group_defaults) # validates all keys in a hash match
      @type = args.first ? args.first.to_sym : :boolean  # boolean by default
      cast_type = if @type == :any  # ????
                    nil
                  else
                    ActiveRecord::Type.const_get(@type.to_s.camelize).new
                  end
      puts "### 30 PFDEF name  #> #{name}, @type#> #{@type}, cast_type  #>  #{cast_type.type}, options  #>  #{options} "
      sql_type_metadata = ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(
        sql_type: cast_type.type.to_s,
        type: cast_type.type,
        limit: cast_type.limit,
        precision: cast_type.precision,
        scale: cast_type.scale)
      # Create a column that will be responsible for typecasting
      puts "### 38 PREFDEF options[:default] ###>>  #{options[:default].inspect}"
      @column = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, options[:default].to_s, sql_type_metadata)
      puts "### 40 PFDEF COLUMN  ###>>  #{@column.inspect}"

      @group_defaults = build_group_defaults(options[:group_defaults])
      puts "### 43 PREFDEF  @group_defaults ###>>  #{@group_defaults.inspect}"
    end

    # The name of the preference
    def name
      @column.name
    end

    # The default value to use for the preference in case none have been
    # previously defined
    def default_value(group = nil)
      puts "### 52 PREFDEF  group ###>>  #{group}"
      puts "### 53 PREFDEF COLUMN  ###>>  #{@column.inspect}"
      @group_defaults.include?(group) ? @group_defaults[group] : @column.default
    end

    # Determines whether column backing this preference stores numberic values
    def number?
      [:integer, :float].include?(@column.default.type)
    end

    # Typecasts the value based on the type of preference that was defined.
    # This uses functionality added in to ActiveRecord's attributes api in Rails 5
    # so the same rules for typecasting a model's columns apply here.
    def type_cast(value)
      puts "### 68 PFDEF  TYPE_cast  ###>>  #{value.inspect}"
      value ? value : cast(@column.default.type, value)
    end

    def cast(type, value)
      puts "### 73 PFDEF  CASTING type  ###>>  #{type.inspect} VALUE: >>  #{value.inspect}"

      return nil if value.nil?

      case type
      when :string, :decimal
        value
      when :integer, :float, :datetime, :date, :boolean
        puts "### 78 preference_definition.rb  ###>>  #{value.inspect}"
        TYPES[type].new.cast(value)
      else
        value
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

    private

      def build_group_defaults(group_defaults)
        return {} unless group_defaults.is_a?(Hash)

        group_defaults.reduce({}) do |defaults, (group, default)|
          defaults[group.is_a?(Symbol) ? group.to_s : group] = type_cast(default)
          defaults
        end
      end
  end
end
