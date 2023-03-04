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

    # name - String
    # args - Hash
    def initialize(name, *args) #:nodoc:
      options = args.extract_options! # {} Removes and returns the last element in the array if it’s a hash
      options.assert_valid_keys(:default, :group_defaults) # validates all keys in a hash match
      @type = args.first ? args.first.to_sym : :boolean  # boolean by default

      #Cast type to an AR type
      cast_type = if @type == :any  # ????
                    nil
                  else
                    ActiveRecord::Type.const_get(@type.to_s.camelize).new
                  end
      # puts "### 30 PFDEF name  #> #{name}, @type#> #{@type}, cast_type  #>  #{cast_type.type}, options  #>  #{options} "
      sql_type_metadata = ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(
        sql_type: cast_type.type.to_s,
        type: cast_type.type,
        limit: cast_type.limit,
        precision: cast_type.precision,
        scale: cast_type.scale)
      # Create a column that will be responsible for typecasting
      # puts "### 38 PREFDEF options[:default] ###>>  #{options[:default].inspect}"
      @column = ActiveRecord::ConnectionAdapters::Column.new(name.to_s, options[:default].to_s, sql_type_metadata)
      # puts "### 40 PFDEF COLUMN  ###>>  #{@column.inspect}"

      @group_defaults = build_group_defaults(options[:group_defaults])
      # puts "### 43 PREFDEF  @group_defaults ###>>  #{@group_defaults.inspect}"
    end

    # The name of the preference
    def name
      @column.name
    end

    # The default value to use for the preference in case none have been
    # previously defined
    def default_value(group = nil)
      #puts "### 53 PREFDEF COLUMN  ###>>  #{@column.inspect}"
      @group_defaults.include?(group) ? @group_defaults[group] : @column.default
    end

    # Determines whether column backing this preference stores numberic values
    def number?
      [:integer, :float].include? @column.type
    end

    # Public. Cast boolean or string.
    #
    # text  - The String to be duplicated.
    #
    # Return. Bollean | String.
    def type_cast(value)
      case value
      when 'false', 'f'
        false
      when 'true', 't'
        true
      else
        value
      end
    end

    # Typecasts the value to true/false depending on the type of preference
    def query(value)
      if !(value = type_cast(value))  # no assignedm, then false
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
