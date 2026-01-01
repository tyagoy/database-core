module DatabaseCore::V3

  class PolicyRunner

    def initialize permissions, overrides

      @policy_model = PolicyModel.new(permissions, overrides)
    end

    def permit? input, permission

      input.all? do |model, payload|

        Array.wrap(payload).all? do |item|

          @policy_model.permit?(model, item, permission)
        end
      end
    end

  end

end