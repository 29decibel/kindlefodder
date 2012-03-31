require 'kindlefodder'
require 'open-uri'

class NodejsDoc < Kindlefodder

  def get_source_files
    @start_url = "http://nodejs.org/api/"
    @start_doc = Nokogiri::HTML(open(@start_url))

    sections = extract_sections

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }

  end

  def document
    # download cover image
    if !File.size?("cover.gif")
      `curl -s 'http://nodejs.org/images/logo-light.png' > cover.png`
      run_shell_command "convert cover.png -type Grayscale -resize '400x300>' cover.gif"
    end
    {
      'title' => 'Nodejs doc',
      'author' => 'Nodejs',
      'cover' => 'cover.gif',
      'masthead' => nil,
    }
  end

  def extract_sections
    articles = (@start_doc.search('#apicontent li a').map  do |link|
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

    res = article_doc.at('#column1').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return path
  end
end

NodejsDoc.generate
