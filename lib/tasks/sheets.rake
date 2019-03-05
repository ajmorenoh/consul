namespace :sheets do
  desc "Remove duplicate signatures in signature sheets"
  task :remove_duplicate_signatures do
    ActiveRecord::Base.transaction do
      DuplicateSignaturesFinder.new(Signature.for_budget(Budget.current)).all.each(&:destroy)
    end
  end
end
