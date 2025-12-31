module Database::V3

  class QueryRunner

    def self.query models_query

      models_values = setup_query(models_query)

      remove_keys(models_query, models_values)

      models_values = setup_values(models_values)

      models_values
    end

    def self.setup_query models_query

      models_values = { "rows" => {} }

      models_query.each do |model, query|

        QueryModel.build_parents(model, query)
        QueryModel.build_children(model, query)

        sql = QueryModel.build(model, query)

        values = ActiveRecord::Base.connection.exec_query(sql).map(&:as_json)

        if query["rows"]

          sql = QueryModel.build_count(model, query)

          rows = ActiveRecord::Base.connection.exec_query(sql).first.as_json

          models_values["rows"].merge!(rows)
        end

        if values.present?

          setup_relation values, query["parents"], true
          setup_relation values, query["children"], false
        end

        models_values[model] = values
      end

      models_values
    end

    def self.setup_relation parents, models_query, relation

      return unless models_query.present?

      setup_relation_query(parents, models_query, relation)
      setup_relation_value(parents, models_query, relation)
    end

    def self.setup_relation_query parents, models_query, relation

      models_query.each do |model, query|

        next if query["key"].nil?

        foreign_key = relation ? "id" : query["key"]
        primary_key = relation ? query["key"] : "id"

        keys = parents.map{ |parent| parent[primary_key] }.uniq.compact

        next if keys.empty?

        query["and"] = {} if query["and"].nil?

        if query["and"][foreign_key]
          query["and"][foreign_key]["in"] ?
            query["and"][foreign_key]["in"] << keys :
            query["and"][foreign_key]["in"] = keys
        else
          query["and"][foreign_key] = { "in" => keys }
        end
      end
    end

    def self.setup_relation_value parents, models_query, relation

      models_values = setup_query(models_query)

      parents.each do |parent|

        models_query.each do |model, query|

          next if query["key"].nil?

          foreign_key = relation ? "id" : query["key"]
          primary_key = relation ? query["key"] : "id"

          values = models_values[model].select{ |value| value[foreign_key] == parent[primary_key] }

          parent[model] = relation ? values.first : values
        end
      end
    end

    def self.setup_values target

      if target.is_a?(Integer)
        return target > 2**32 ? target.to_s : target
      end

      if target.is_a?(Array)
        return target.map { |value| setup_values(value) }
      end

      if target.is_a?(Hash)
        return target.transform_values { |value| setup_values(value) }
      end

      if target.is_a?(String)
        unless [Encoding::US_ASCII, Encoding::UTF_8].include?(target.encoding)
          return target.bytes.to_a
        end
      end

      target
    end

    def self.remove_keys models_query, models_values

      models_query&.each do |model, query|

        if models_values[model].is_a?(Array)
          models_values[model].each do |value|
            remove_key query, value
          end
        end

        if models_values[model].is_a?(Hash)
          value = models_values[model]
          remove_key query, value
        end
      end
    end

    def self.remove_key query, value

      columns = query["columns"]&.map{ |column| column.is_a?(Hash) ? column["alias"] : column }

      value.keys.each do |key|

        next if columns.include?(key)

        next if query["parents"]&.key?(key)
        next if query["children"]&.key?(key)

        value.delete(key)
      end

      remove_keys query["parents"], value
      remove_keys query["children"], value
    end

  end

end