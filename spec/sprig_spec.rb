require 'spec_helper'
require 'open-uri'

describe "Seeding an application" do
  before do
    stub_rails_root
  end

  context "with a yaml file" do
    around do |example|
      load_seeds('posts.yml', &example)
    end

    it "seeds the db" do
      sprig [Post]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Yaml title']
    end
  end

  context "with a csv file" do
    around do |example|
      load_seeds('posts.csv', &example)
    end

    it "seeds the db" do
      sprig [Post]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Csv title']
    end
  end

  context "with a json file" do
    around do |example|
      load_seeds('posts.json', &example)
    end

    it "seeds the db" do
      sprig [Post]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Json title']
    end
  end

  context "with a google spreadsheet" do
    it "seeds the db", :vcr => { :cassette_name => 'google_spreadsheet_json_posts' } do
      sprig [
        {
          :class  => Post,
          :parser => Sprig::Parser::GoogleSpreadsheetJson,
          :source => open('https://spreadsheets.google.com/feeds/list/0AjVLPMnHm86rdDVHQ2dCUS03RTN5ZUtVNzVOYVBwT0E/1/public/values?alt=json'),
        }
      ]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Google spreadsheet json title']
    end
  end

  context "with an invalid custom parser" do
    around do |example|
      load_seeds('posts.yml', &example)
    end

    it "fails with an argument error" do
      expect {
        sprig [
          {
            :class  => Post,
            :source => open('spec/fixtures/seeds/test/posts.yml'),
            :parser => Object # Not a valid parser
          }
        ]
      }.to raise_error(ArgumentError, 'Parsers must define #parse.')
    end
  end

  context "with a custom source" do
    around do |example|
      load_seeds('legacy_posts.yml', &example)
    end

    it "seeds" do
      sprig [
        {
          :class  => Post,
          :source => open('spec/fixtures/seeds/test/legacy_posts.yml')
        }
      ]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Legacy yaml title']
    end
  end

  context "with a custom source that cannot be parsed by native parsers" do
    around do |example|
      load_seeds('posts.md', &example)
    end

    it "fails with an unparsable file error" do
      expect {
        sprig [
          {
            :class  => Post,
            :source => open('spec/fixtures/seeds/test/posts.md')
          }
        ]
      }.to raise_error(Sprig::Source::ParserDeterminer::UnparsableFileError)
    end
  end

  context "with an invalid custom source" do
    it "fails with an argument error" do
      expect {
        sprig [ { :class  => Post, :source => 42 } ]
      }.to raise_error(ArgumentError, 'Data sources must act like an IO.')
    end
  end

  context "with multiple file relationships" do
    around do |example|
      load_seeds('posts.yml', 'comments.yml', &example)
    end

    it "seeds the db" do
      sprig [Post, Comment]

      Post.count.should    == 1
      Comment.count.should == 1
      Comment.first.post.should == Post.first
    end
  end

  context "with missing seed files" do
    it "raises a missing file error" do
      expect {
        sprig [Post]
      }.to raise_error(Sprig::Source::SourceDeterminer::FileNotFoundError)
    end
  end

  context "with a relationship to an undefined record" do
    around do |example|
      load_seeds('posts.yml', 'posts_missing_dependency.yml', &example)
    end

    it "raises a helpful error message" do
      expect {
        sprig [
          {
            :class  => Post,
            :source => open('spec/fixtures/seeds/test/posts_missing_dependency.yml')
          }
        ]
      }.to raise_error(
        Sprig::DependencySorter::MissingDependencyError,
        "Undefined reference to 'sprig_record(Comment, 42)'"
      )
    end
  end

  context "with a relationship to a record that didn't save" do
    around do |example|
      load_seeds('invalid_users.yml', 'posts_missing_record.yml', &example)
    end

    it "does not error, but carries on with the seeding" do
      expect {
        sprig [
          {
            :class  => Post,
            :source => open('spec/fixtures/seeds/test/posts_missing_record.yml')
          },
          {
            :class  => User,
            :source => open('spec/fixtures/seeds/test/invalid_users.yml')
          }
        ]
      }.to_not raise_error
    end
  end

  context "with multiple files for a class" do
    around do |example|
      load_seeds('posts.yml', 'legacy_posts.yml', &example)
    end

    it "seeds the db" do
      sprig [
        Post,
        {
          :class  => Post,
          :source => open('spec/fixtures/seeds/test/legacy_posts.yml')
        }
      ]

      Post.count.should == 2
      Post.pluck(:title).should=~ ['Yaml title', 'Legacy yaml title']
    end
  end

  context "from a specific environment" do
    around do |example|
      stub_rails_env 'staging'
      load_seeds('posts.yml', &example)
    end

    it "seeds the db" do
      sprig [Post]

      Post.count.should == 1
      Post.pluck(:title).should =~ ['Staging yaml title']
    end
  end

  context "with files defined as attributes" do
    around do |example|
      load_seeds('posts_with_files.yml', &example)
    end

    it "seeds the db" do
      sprig [
        {
          :class  => Post,
          :source => open('spec/fixtures/seeds/test/posts_with_files.yml')
        }
      ]

      Post.count.should == 1
      Post.pluck(:photo).should =~ ['cat.png']
    end
  end

  context "with custom seed options" do
    context "using find_existing_by" do
      context "with a single attribute" do
        around do |example|
          load_seeds('posts.yml', 'posts_find_existing_by_single.yml', &example)
        end

        context "with an existing record" do
          let!(:existing) do
            Post.create(
              :title    => "Existing title",
              :content  => "Existing content")
          end

          it "updates the existing record" do
            sprig [
              {
                :class  => Post,
                :source => open("spec/fixtures/seeds/test/posts_find_existing_by_single.yml")
              }
            ]

            Post.count.should == 1
            existing.reload.content.should == "Updated content"
          end
        end
      end

      context "with multiple attributes" do
        around do |example|
          load_seeds('posts.yml', 'posts_find_existing_by_multiple.yml', &example)
        end

        context "with an existing record" do
          let!(:existing) do
            Post.create(
              :title      => "Existing title",
              :content    => "Existing content",
              :published  => false
            )
          end

          it "updates the existing record" do
            sprig [
              {
                :class  => Post,
                :source => open("spec/fixtures/seeds/test/posts_find_existing_by_multiple.yml")
              }
            ]

            Post.count.should == 1
            existing.reload.published.should == true
          end
        end
      end
    end
  end
end
