require 'kindlefodder'
require 'open-uri'

class PhonegapDoc < Kindlefodder

  def get_source_files
    @start_url = "http://docs.phonegap.com/en/1.6.1/"
    @start_doc = Nokogiri::HTML(`curl -s #{@start_url}`)

    sections = extract_sections

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }

  end

  def document
    {
      'title' => 'Phonegap doc',
      'author' => 'Phonegap',
      'cover' => '',
      'masthead' => nil,
    }
  end

  def extract_sections
    # temp solution
    # the storage page contains non UTF-8 chars
    articles = (@start_doc.search('#sidebar li a').select{|a| a.text!='Storage'}.map  do |link|
      {
        title: link.text,
        path:  save_article_and_return_path(link['href'])
      }
    end)
    [{
      title:'All',
      articles:articles
    }]
  end

  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    full_url = "#{@start_url}#{href}"

    html = run_shell_command "curl -s #{full_url}"

    article_doc = Nokogiri::HTML html

    res = article_doc.at('#content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return path
  end
end

PhonegapDoc.generate
