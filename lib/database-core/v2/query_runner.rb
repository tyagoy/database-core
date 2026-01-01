module DatabaseCore::V2

  class QueryRunner

    def self.query models_query

      models_values = {}

      models_query.each do |model, query|

        sql = Query.build(model, query)

        values = ActiveRecord::Base.connection.exec_query(sql).map(&:as_json)

        if values.present?

          setup_relation values, query["has_one"], true
          setup_relation values, query["has_many"], false
        end

        models_values[model] = values
      end

      serialize(models_values)
    end

    def self.setup_relation parents, models_query, relation

      return unless models_query.present?

      setup_relation_query(parents, models_query, relation)
      setup_relation_value(parents, models_query, relation)
    end

    def self.setup_relation_query parents, models_query, relation

      models_query.each do |model, query|

        next if query["has_one_key"].nil? && relation == true
        next if query["has_many_key"].nil? && relation == false

        foreign_key = relation ? "id" : query["has_many_key"]
        primary_key = relation ? query["has_one_key"] : "id"

        keys = parents.map{ |parent| parent[primary_key] }.uniq.compact

        next if keys.empty?

        query["in_value"] = {} if query["in_value"].nil?

        if query["in_value"][foreign_key]
          query["in_value"][foreign_key] << keys
          query["in_value"][foreign_key].flatten
        else
          query["in_value"][foreign_key] = keys
        end
      end
    end

    def self.setup_relation_value parents, models_query, relation

      models_values = query(models_query)

      parents.each do |parent|

        models_query.each do |model, query|

          next if query["has_one_key"].nil? && relation == true
          next if query["has_many_key"].nil? && relation == false

          foreign_key = relation ? "id" : query["has_many_key"]
          primary_key = relation ? query["has_one_key"] : "id"

          values = models_values[model].select{ |value| value[foreign_key] == parent[primary_key] }

          parent[model] = relation ? values.first : values
        end
      end
    end

    def self.serialize(target)

      case target
      when Integer
        target > 2**32 ? target.to_s : target
      when String
        encodings = [Encoding::US_ASCII, Encoding::UTF_8]
        encodings.include?(target.encoding) ? target : target.bytes.to_a
      when Array
        target.map { |value| serialize(value) }
      when Hash
        target.transform_values { |value| serialize(value) }
      else
        target
      end
    end

  end

end