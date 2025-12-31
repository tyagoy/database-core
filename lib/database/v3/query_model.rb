module Database::V3

  class QueryModel

    def self.build model, query

      model = Sanitize.target(model)

      columns = build_columns(query)

      output = ["SELECT #{columns} FROM `#{model}`"]

      WhereModel.build(output, query)

      build_order(output, query)
      build_limit(output, query)
      build_offset(output, query)

      output.join(" ")
    end

    def self.build_count model, query

      model = Sanitize.target(model)

      output = ["SELECT COUNT(id) AS `#{model}` FROM `#{model}`"]

      WhereModel.build(output, query)

      output.join(" ")
    end

    def self.build_children model, query

      children = query["children"]

      return unless children.present?

      children.each do |_model, value|

        value["key"] = "#{model.singularize}_id" if value["key"].nil?

        value["keys"] = [] if value["keys"].nil?

        value["keys"] << value["key"] unless value["keys"].include? value["key"]
      end

      query["keys"] = [] if query["keys"].nil?

      query["keys"] << "id" unless query["keys"].include? "id"
    end

    def self.build_parents _model, query

      parents = query["parents"]

      return unless parents.present?

      parents.each do |model, value|

        value["key"] = "#{model.singularize}_id" if value["key"].nil?

        query["keys"] = [] if query["keys"].nil?

        query["keys"] << value["key"] unless query["keys"].include? value["key"]

        value["keys"] = [] if value["keys"].nil?

        value["keys"] << "id" unless value["keys"].include? "id"
      end
    end

    def self.build_columns query

      columns = query["columns"].to_a + query["keys"].to_a

      columns = columns.uniq.map{ |column| column.is_a?(Hash) ? build_function(column) : "`#{column}`" }.join(",")

      columns.present? ? columns : "*"
    end

    def self.build_function function

      function_name = function["function"].upcase

      params = function["params"].map{ |param| param.is_a?(Hash) ? build_function(param) : "`#{param}`" }.join(", ")

      function_call = "#{function_name}(#{params})"

      function["alias"] ? "#{function_call} AS `#{function['alias']}`" : function_call
    end

    def self.build_order output, query

      order = query["order"]

      return unless order.present?

      order = order.map{ |key, value| "`#{key}` #{value}" }.join(",")

      return unless order.present?

      output << "ORDER BY #{order}"
    end

    def self.build_limit output, query

      limit = query["limit"].to_i

      return if limit.zero?

      output << "LIMIT #{limit}"
    end

    def self.build_offset output, query

      offset = query["offset"].to_i

      return if offset.zero?

      output << "OFFSET #{offset}"
    end

  end

end