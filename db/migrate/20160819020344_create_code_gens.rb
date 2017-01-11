# -*- encoding : utf-8 -*-
class CreateCodeGens < ActiveRecord::Migration
  def change
    create_table :code_gens do |t|
      t.string :table_name
      t.string :package_name
      t.string :project_name

      t.timestamps null: false
    end
  end
end
