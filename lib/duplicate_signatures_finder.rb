class DuplicateSignaturesFinder
  def all
    Signature.where(id: expendables)
  end

  private

    def duplicate_sheet_and_user_ids
      Signature.select("signature_sheet_id, user_id, COUNT(*)")
        .group("signature_sheet_id, user_id")
        .where("user_id IS NOT NULL")
        .having("COUNT(*) > 1")
    end

    def duplicate_groups
      duplicate_sheet_and_user_ids.map do |duplicate|
        Signature.where(
          signature_sheet_id: duplicate.signature_sheet_id,
          user_id: duplicate.user_id
        )
      end
    end

    def expendables
      duplicate_groups.map do |signatures|
        if Vote.where(signature: signatures).any?
          signatures.where.not(id: Vote.where(signature: signatures).pluck(:signature_id))
        else
          signatures.order("created_at DESC").limit(signatures.count - 1)
        end
      end.flatten
    end
end
