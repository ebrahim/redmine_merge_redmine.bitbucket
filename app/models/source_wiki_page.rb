class SourceWikiPage < ActiveRecord::Base
  include SecondDatabase
  set_table_name :wiki_pages

  def self.migrate
    all.each do |source_wiki_page|
      recursive_migrate source_wiki_page.id
    end
  end

  def self.recursive_migrate(source_wiki_page_id)
    # Return if already migrated
    if new_id = RedmineMerge::Mapper.get_new_wiki_page_id(source_wiki_page_id)
      return new_id
    end

    source_wiki_page = SourceWikiPage.find(source_wiki_page_id)
    wiki_page = WikiPage.create(source_wiki_page.attributes)
    wiki_page.wiki = Wiki.find(RedmineMerge::Mapper.get_new_wiki_id(source_wiki_page.wiki_id))
    wiki_page.parent = WikiPage.find(recursive_migrate(source_wiki_page.parent_id)) if source_wiki_page.parent_id?
    wiki_page.save()

    RedmineMerge::Mapper.add_wiki_page(source_wiki_page.id, wiki_page.id)

    return wiki_page.id
  end
end
