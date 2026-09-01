require 'json'

module Jekyll
  class StorePageGenerator < Generator
    safe true
    priority :normal

    def generate(site)
      items = load_json(site, '_rawdata/goodprice.json')

      Jekyll.logger.info "StoreGenerator:", "#{items.size}개 착한가격업소 페이지 생성 중..."
      items.each do |c|
        next if c['slug'].to_s.strip.empty?
        site.pages << StorePage.new(site, c)
      end

      Jekyll.logger.info "StoreGenerator:", "완료 (#{items.size}개)"
    end

    private

    def load_json(site, path)
      file = File.join(site.source, path)
      return [] unless File.exist?(file)
      JSON.parse(File.read(file, encoding: 'utf-8'))
    rescue => e
      Jekyll.logger.warn "StoreGenerator:", "#{path} 로드 실패: #{e.message}"
      []
    end
  end

  class StorePage < Page
    def initialize(site, c)
      @site = site
      @base = site.source
      @dir  = "store/#{c['slug']}"
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(@base, '_layouts'), 'store.html')
      self.data.merge!(c)
      self.data['layout']      = 'store'
      self.data['title']       = build_title(c)
      self.data['description'] = build_desc(c)
    end

    private

    def build_title(c)
      loc = [c['doShort'], c['sigungu']].compact.join(' ')
      "#{c['storeName']} #{loc} 착한가격업소 - #{c['category']}"
    end

    def build_desc(c)
      loc = [c['doShort'], c['sigungu']].compact.join(' ')
      menu_str = (c['menus'] || []).map { |m| m['menu'] }.first(3).join('·')
      extra = menu_str.empty? ? '' : " 대표메뉴: #{menu_str}."
      "#{loc} #{c['storeName']}(#{c['category']}) 착한가격업소 정보.#{extra}"[0, 155]
    end
  end
end
