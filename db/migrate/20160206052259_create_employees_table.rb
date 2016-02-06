class CreateEmployeesTable < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :first
      t.string :last
    end
  end
end
