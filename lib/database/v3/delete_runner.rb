module Database::V3

  class DeleteRunner

    def self.delete input

      input.each do |model, payload|

        Array.wrap(payload).each do |item|

          sql = DeleteModel.build(model, item)

          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

  end

end