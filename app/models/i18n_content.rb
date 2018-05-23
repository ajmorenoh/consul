class I18nContent < ActiveRecord::Base
  validates :key, uniqueness: true

  translates :value, touch: true
  globalize_accessors locales: [:en, :es, :fr, :nl, :val, :pt_br]
end
