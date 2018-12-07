# coding: utf-8
# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: "admin", email: "admin@consul.dev", password: "12345678",
                       password_confirmation: "12345678", confirmed_at: Time.current,
                       terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting["official_level_1_name"] = "Empleados públicos"
Setting["official_level_2_name"] = "Organización Municipal"
Setting["official_level_3_name"] = "Directores generales"
Setting["official_level_4_name"] = "Concejales"
Setting["official_level_5_name"] = "Alcaldesa"

Setting["max_ratio_anon_votes_on_debates"] = 50

Setting["max_votes_for_debate_edit"] = 1000

Setting["max_votes_for_proposal_edit"] = 1000

Setting["comments_body_max_length"] = 1000

Setting["proposal_code_prefix"] = "MAD"

Setting["votes_for_proposal_success"] = 53726

Setting["months_to_archive_proposals"] = 12

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting["email_domain_for_officials"] = ""

# Code to be included at the top (inside <head>) of every page (useful for tracking)
Setting["html.per_page_code_head"] = ""

# Code to be included at the top (inside <body>) of every page
Setting["html.per_page_code_body"] = ""

Setting["twitter_handle"] = "abriendomadrid"
Setting["twitter_hashtag"] = "#decidemadrid"
Setting["facebook_handle"] = "Abriendo-Madrid-1475577616080350"
Setting["youtube_handle"] = "channel/UCFmaChI9quIY7lwHplnacfg"
Setting["telegram_handle"] = nil
Setting["instagram_handle"] = "decidemadrid"
Setting["blog_url"] = "https://diario.madrid.es/decidemadrid/"
Setting["transparency_url"] = "http://transparencia.madrid.es/"
Setting["opendata_url"] = "http://datos.madrid.es/"

Setting["url"] = "https://decide.madrid.es" # Public-facing URL of the app.

# Consul installation's organization name
Setting["org_name"] = "Decide Madrid"

Setting["meta_title"] = nil
Setting["meta_description"] = nil
Setting["meta_keywords"] = nil

Setting["process.debates"] = true
Setting["process.proposals"] = true
Setting["process.polls"] = true
Setting["process.budgets"] = true
Setting["process.legislation"] = true

Setting["feature.featured_proposals"] = nil
Setting["feature.twitter_login"] = true
Setting["feature.facebook_login"] = true
Setting["feature.google_login"] = true
Setting["feature.public_stats"] = true
Setting["feature.signature_sheets"] = true
Setting["feature.user.recommendations"] = true
Setting["feature.user.recommendations_on_debates"] = true
Setting["feature.user.recommendations_on_proposals"] = true
Setting["feature.user.skip_verification"] = true
Setting["feature.community"] = true
Setting["feature.map"] = nil
Setting["feature.allow_images"] = true
Setting["feature.allow_attached_documents"] = true
Setting["feature.guides"] = true
Setting["feature.help_page"] = true
Setting["feature.captcha"] = nil

Setting["proposal_notification_minimum_interval_in_days"] = 3
Setting["direct_message_max_per_day"] = 3 # For proposal notifications

Setting["mailer_from_name"] = "CONSUL"
Setting["mailer_from_address"] = "noreply@consul.dev"

Setting["verification_offices_url"] = "http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD"
Setting["min_age_to_participate"] = 16

Setting["featured_proposals_number"] = 3

Setting["map.latitude"] = 40.4332002
Setting["map.longitude"] = -3.7009591
Setting["map.zoom"] = 10

Setting["related_content_score_threshold"] = -0.3
Setting["homepage.widgets.feeds.proposals"] = true
Setting["homepage.widgets.feeds.debates"] = true
Setting["homepage.widgets.feeds.processes"] = true

Setting["hot_score_period_in_days"] = 31

Setting["proposals.successful_proposal_id"] = nil
Setting["proposals.poll_short_title"] = nil
Setting["proposals.poll_description"] = nil
Setting["proposals.poll_link"] = nil
Setting["proposals.email_short_title"] = nil
Setting["proposals.email_description"] = nil
Setting["proposals.poster_short_title"] = nil
Setting["proposals.poster_description"] = nil

Setting["dashboard.emails"] = nil

Setting["captcha.max_failed_login_attempts"] = 5

# Default custom pages
load Rails.root.join("db", "pages.rb")
