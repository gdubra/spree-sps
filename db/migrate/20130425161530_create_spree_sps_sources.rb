class CreateSpreeSpsSources < ActiveRecord::Migration
  def change
    create_table :spree_sps_sources do |t|
      t.text :sps_tx_code
      t.date :sps_tx_date
      t.text :sps_response
      t.text :cc_owner
      t.integer :installments

      t.timestamps
    end
  end
end
