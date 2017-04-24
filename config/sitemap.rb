# not use compression
class SitemapGenerator::FileAdapter
  def gzip(stream, data); stream.write(data); stream.close end
end
SitemapGenerator::Sitemap.namer = SitemapGenerator::SimpleNamer.new(:sitemap, extension: '.xml')

# default host
SitemapGenerator::Sitemap.default_host = Setting["url"]

# sitemap generator
SitemapGenerator::Sitemap.create do
  pages = Dir.entries(File.join(Rails.root,"app","views","pages"))
  pages.each do |page|
    page_name = page.split(".").first
    add page_name if page_name.present?
  end

  add more_info_path
  add how_to_use_path
  add faq_path
  add participation_facts_path
  add participation_world_path
  add budgets_welcome_path

  add debates_path, priority: 0.7, changefreq: "daily"
  Debate.find_each do |debate|
    add debate_path(debate), lastmod: debate.updated_at
  end

  add proposals_path, priority: 0.7, changefreq: "daily"
  Proposal.find_each do |proposal|
    add proposal_path(proposal), lastmod: proposal.updated_at
  end

  add budgets_path, priority: 0.7, changefreq: "daily"
  Budget.find_each do |budget|
    add budget_path(budget), lastmod: budget.updated_at
  end

  add polls_path, priority: 0.7, changefreq: "daily"
  Poll.find_each do |poll|
    add poll_path(poll), lastmod: poll.starts_at
  end
end
