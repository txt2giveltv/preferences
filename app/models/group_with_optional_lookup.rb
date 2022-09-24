# frozen_string_literal: true

module GroupWithOptionalLookup
  def group
    group_id ? group_id : group_type
  end
end
