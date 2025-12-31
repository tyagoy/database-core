module Database::V1

  class QueryRunner

    def self.query tables_query

      tables_values = QueryRunner.tables_query tables_query

      tables_values.each do |table, values|

        query = tables_query[table]
        next if query.nil?

        QueryRunner.values_remove_keys values, query
      end

      tables_values
    end

    def self.tables_query tables_query

      tables_values = {}

      tables_query.each do |table, query|

        sql = Query.build table, query

        values = ActiveRecord::Base.connection.exec_query(sql).map(&:as_json)

        QueryRunner.tables_has_many values, query
        QueryRunner.tables_has_one values, query

        tables_values[table] = values
      end

      tables_values
    end

    def self.tables_has_many parents, query

      has_many = query["has_many"]
      return if has_many.nil?

      QueryRunner.setup_has_many parents, has_many
      tables_values = QueryRunner.tables_query has_many

      parents.each do |parent|

        tables_values.each do |table, values|

          query = has_many[table]
          next if query.nil?
          has_many_key = query["has_many_key"]
          next if has_many_key.nil?
          key_value = parent["id"]
          next if key_value.nil?

          values = values.deep_dup.select{ |value| value[has_many_key] == key_value }
          QueryRunner.values_remove_keys values, query
          parent[table] = values
        end
      end
    end

    def self.tables_has_one parents, query

      has_one = query["has_one"]
      return if has_one.nil?

      QueryRunner.setup_has_one parents, has_one
      tables_values = QueryRunner.tables_query has_one

      parents.each do |parent|

        tables_values.each do |table, values|

          query = has_one[table]
          next if query.nil?
          has_one_key = query["has_one_key"]
          next if has_one_key.nil?
          key_value = parent[has_one_key]
          next if key_value.nil?

          values = values.deep_dup.select{ |value| value["id"] == key_value }
          QueryRunner.values_remove_keys values, query
          parent[table] = values[0]
        end
      end
    end

    def self.setup_has_many values, tables_query

      return if values.empty?

      tables_query.each do |_, query|

        has_many_key = query["has_many_key"]

        next if has_many_key.nil?

        unless query["in_value"].nil?
          if query["in_value"].key? has_many_key
            query["in_value"][has_many_key] << values.map{ |value| value["id"] }.compact.uniq
          end
        end

        if query["in_value"].nil?
          query["in_value"] = {}
          query["in_value"][has_many_key] = values.map{ |value| value["id"] }.compact.uniq
        end
      end
    end

    def self.setup_has_one values, tables_query

      return if values.empty?

      tables_query.each do |_, query|

        has_one_key = query["has_one_key"]

        next if has_one_key.nil?

        unless query["in_value"].nil?
          if query["in_value"].key? "id"
            query["in_value"]["id"] << values.map{ |value| value[has_one_key] }.compact.uniq
          end
        end

        if query["in_value"].nil?
          query["in_value"] = {}
          query["in_value"]["id"] = values.map{ |value| value[has_one_key] }.compact.uniq
        end
      end
    end

    def self.values_remove_keys values, query

      columns = query["columns"]
      return if columns.nil?

      keys = []

      Query.build_keys keys, query

      keys.each do |key|
        unless columns.include? key
          values.each do |value|
            value.delete key
          end
        end
      end
    end

  end

end