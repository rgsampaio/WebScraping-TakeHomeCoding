require 'mechanize'
require 'json'

class Scraper
    def initialize
        @agent = Mechanize.new #cria um objeto da classe mechanize

        @agent.request_headers = {
            'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36'
        } #'engana' o site fingindo ser um navegador real

        @agent.get 'https://infosimples.com/vagas/desafio/commercia/product.html' #faz request HTTP GET para o site

        @doc = @agent.page.parser #traz uma árvore de elementos do HTML

        @content = {
            title: '#product_title',
            brand: 'div.brand',
            categories: '.current-category > a',
            description: 'div.proddet > p',
            skus: '.card',
            skus_name: '.prod-nome',
            skus_current_price: '.prod-pnow',
            skus_old_price: '.prod-pold',
            product_properties: '.pure-table.pure-table-bordered',
            reviews: '.analisebox',
            reviews_name: '.analiseusername',
            reviews_date: '.analisedate',
            reviews_score: '.analisestars',
            reviews_text: 'p',
            reviews_average_score: '#comments > h4'
        }
    end
    
    def title
        @doc.css(@content[:title]).text
    end

    def brand
        @doc.css(@content[:brand]).text
    end

    def categories
        @doc.css(@content[:categories]).map(&:text)
    end

    def description
        @doc.css(@content[:description]).text.strip
    end

    def skus
        skus_array = []

        @doc.css(@content[:skus]).each do |skus|
            name = skus.css(@content[:skus_name]).text.strip 

            price_string = skus.css(@content[:skus_current_price]).text
            price_number = price_string.gsub(/[^\d,\.]/, '').gsub(',', '.') #elimina tudo que não for número, virgula ou ponto
            current_price = price_number.empty? ? nil : price_number.to_f 

            old_price_string = skus.css(@content[:skus_old_price]).text
            old_price_number = old_price_string.gsub(/[^\d,\.]/, '').gsub(',', '.')
            old_price = old_price_number.empty? ? nil : old_price_number.to_f

            available = !skus['class'].to_s.include?('not-avaliable') #retorna true se a classe 'not-avaliable' NÃO estiver presente no elemento .card

            skus_array << {
                name: name,
                current_price: current_price,
                old_price: old_price,
                available: available
            }
        end

        skus_array
    end

    def properties
        properties_array = []

        @doc.css(@content[:product_properties]).each do |table|
            table.css('tr').each do |tr|
                next if tr.ancestors('thead').any? #pega todos os valores da tabela exceto o que está dentro da tag thead

                tds = tr.css('td')
                    label = tds.css('b').first&.text
                    value = tds.last.text

                properties_array << {
                    label: label,
                    value: value
                }
            end
        end

        properties_array
    end

    def reviews
        reviews_array = []

        @doc.css(@content[:reviews]).each do |review|
            name = review.css(@content[:reviews_name]).text
            date = review.css(@content[:reviews_date]).text
            score_string = review.css(@content[:reviews_score]).text
            score = score_string.count("★")
            text = review.css(@content[:reviews_text]).text

            reviews_array << {
                name: name,
                date: date,
                score: score,
                text: text
            }
        end
        
        reviews_array
    end

    def reviews_average_score
        score_string = @doc.css(@content[:reviews_average_score]).text
        reviews_average_score = score_string[/[\d.]+/].to_f
    end

    def execute
        @scraped_data = {
            title: title,
            brand: brand,
            categories: categories,
            description: description,
            skus: skus,
            properties: properties,
            reviews: reviews,
            reviews_average_score: reviews_average_score,
            url: @agent.page.uri.to_s
        }

        json_data = JSON.pretty_generate(@scraped_data)
        File.write(('produto.json'), json_data, mode: 'w')
    end
end