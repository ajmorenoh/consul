class AddConfirmedAtToBallots < ActiveRecord::Migration[4.2]
  def change
    add_column :ballots, :confirmed_at, :datetime
  end
end
