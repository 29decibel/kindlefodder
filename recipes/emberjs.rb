require 'kindlefodder'

class Emberjs < Kindlefodder

  def get_source_files
    @start_url = "http://emberjs.com/guides/"
    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")

    sections = section_and_articles

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

  def section_and_articles
    @start_doc.css("#toc-list li.level-1").map do |section|
      section_title = section.css("> a").text
      articles = section.css("li.level-3 a").map { |link| extract_articles(link) }
      {
        title: section_title,
        articles: articles
      }
    end
  end

  def document
    # download cover image
    if !File.size?("cover.gif")
      `curl -s 'http://emberjs.com/images/about/ember-productivity-sm.png' > cover.png`
      run_shell_command "convert cover.png -type Grayscale -resize '400x300>' cover.gif"
    end
    {
      'title' => 'Emberjs Guide',
      'author' => 'emberjs',
      'cover' => 'cover.gif',
      'masthead' => nil
    }
  end


  def extract_articles(link)
    FileUtils::mkdir_p "#{output_dir}/articles"
    {
      title: link.text,
      path: save_article_and_return_path(link[:href])
    }
  end

  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    full_url = "http://emberjs.com/" + href + "/"
    puts path, full_url
    html = run_shell_command "curl -s #{full_url}"
    article_doc = Nokogiri::HTML html
    # remove line numbers
    article_doc.css("td.line-numbers").map {|lm| lm.remove}
    # get what we want
    res = article_doc.at('#content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    path
  end

end

Emberjs.generate

