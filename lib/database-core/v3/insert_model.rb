module DatabaseCore::V3

  class InsertModel

    def self.build model, params

      model = Sanitize.target(model)

      datetime = Time.current.utc.strftime("%Y-%m-%d %H:%M:%S")

      params["columns"]["created_at"] = datetime
      params["columns"]["updated_at"] = datetime

      columns = build_columns(params).join(", ")

      values = build_values(params).join(", ")

      "INSERT INTO `#{model}` (#{columns}) VALUES (#{values})"
    end

    def self.build_columns params

      params["columns"].keys.map{ |column| "`#{Sanitize.target(column)}`" }
    end

    def self.build_values params

      params["columns"].values.map{ |value| Sanitize.array(["?", value]) }
    end

  end

end