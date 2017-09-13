# encoding: utf-8

require File.join(File.dirname(__FILE__), 'base_migration')

class CreateArticles < BaseMigration
  def up
    <<-SQL
      CREATE SEQUENCE article_id_seq;
      CREATE TABLE articles (
        id      integer PRIMARY KEY DEFAULT nextval('article_id_seq'),
        title   character varying NOT NULL,
        body    text
      );
      ALTER SEQUENCE article_id_seq OWNED BY articles.id;
    SQL
  end

  def down
    <<-SQL
      DROP TABLE articles cascade;
    SQL
  end
end
