class CreatePositionsTable < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :title
      t.string :department
      t.money :regular
      t.money :retro
      t.money :other
      t.money :overtime
      t.money :injury
      t.money :detail
      t.money :quinn
      t.money :total
      t.integer :zip
      t.date :year
    end
  end
end
