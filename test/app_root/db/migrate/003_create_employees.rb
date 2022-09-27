# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[5.1]
  def self.up
    create_table :employees do |t|
      t.string :name, :null => false
      t.string :type
    end
  end

  def self.down
    drop_table :employees
  end
end
