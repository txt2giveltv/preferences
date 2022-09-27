# frozen_string_literal: true

class MigratePreferencesToVersion1 < ActiveRecord::Migration[5.1]
  def self.up
    ActiveRecord::Migrator.new(:up, "#{Rails.root}/../../generators/preferences/templates", 0).migrations.each do |migration|
      migration.migrate(:up)
    end
  end

  def self.down
    ActiveRecord::Migrator.new(:down, "#{Rails.root}/../../generators/preferences/templates", 0).migrations.each do |migration|
      migration.migrate(:down)
    end
  end
end
