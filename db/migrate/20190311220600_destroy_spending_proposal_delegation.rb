class DestroySpendingProposalDelegation < ActiveRecord::Migration
  def change
    remove_column :users, :representative_id
    drop_table :forums
    remove_column :votes, :delegated
  end
end
