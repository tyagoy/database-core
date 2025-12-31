module Database::V3

  class DeleteModel

    def self.build model, params

      model = Sanitize.target(model)

      output = ["DELETE FROM `#{model}`"]

      WhereModel.build(output, params)

      output.join(" ")
    end

  end

end