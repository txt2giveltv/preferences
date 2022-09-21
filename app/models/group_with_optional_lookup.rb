# frozen_string_literal: true

module GroupWithOptionalLookup
  def group
    group_id ? group_without_optional_lookup : group_type
  end
end
