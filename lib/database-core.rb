# frozen_string_literal: true

require_relative "database-core/version"

Dir[File.join(__dir__, "database/**/*.rb")].sort.each do |file|
  require file
end

Dir[File.join(__dir__, "database-core/**/*.rb")].sort.each do |file|
  require file
end
