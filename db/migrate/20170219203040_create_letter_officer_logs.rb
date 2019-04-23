class CreateLetterOfficerLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_letter_officer_logs do |t|
      t.string :document_number
      t.string :message
    end
  end
end
