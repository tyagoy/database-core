module Database::V3

  class UpdateModel

    def self.build model, params

      model = Sanitize.target(model)

      columns = build_columns(params).join(", ")

      output = ["UPDATE `#{model}` SET #{columns}"]

      WhereModel.build(output, params)

      output.join(" ")
    end

    def self.build_columns params

      params["columns"].map do |column, value|

        column = Sanitize.target(column)

        Sanitize.array(["`#{column}` = ?", value])
      end
    end

  end

end