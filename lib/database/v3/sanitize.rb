module Database::V3

  RULE = /[^a-zA-Z0-9_]/.freeze

  class Sanitize

    def self.target params

      params.to_s.gsub(RULE, "")
    end

    def self.array params

      ActiveRecord::Base.sanitize_sql_array(params)
    end

  end

end