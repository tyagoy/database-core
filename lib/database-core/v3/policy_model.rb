module DatabaseCore::V3

  class PolicyModel

    def initialize permissions, overrides

      @permissions = permissions

      @overrides = overrides
    end

    def permit? model, params, permission

      override = @overrides.dig(model)

      return @permissions.dig(permission) unless override

      params_columns = params.dig("columns").to_a

      override_columns = override.dig("columns").to_a

      return @permissions.dig(permission) unless (params_columns - override_columns).empty?

      override.dig("permissions", permission)
    end

  end

end