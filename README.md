# WebScraping-TakeHomeCoding
##Web scraper desenvolvido para extrair dados de uma página de produto fictícia.

Página fictícia: https://infosimples.com/vagas/desafio/commercia/product.html
![Camada 1](https://github.com/user-attachments/assets/e6eba670-0458-45c4-a55a-6f7e140cac01)

###🛠️ Funcionamento
####O scraper coleta informações de uma página de produto e salva os dados em um arquivo JSON com estrutura organizada.
###Estrutura do JSON gerado:

-title → Nome do produto (string)
-brand → Marca do produto (string)
-categories → Categorias relacionadas (string)
-description → Descrição detalhada (string)
-skus → Variações do produto, como cor ou tamanho (array<Object>)
-properties → Características e especificações técnicas (array<Object>)
-reviews → Comentários e avaliações de clientes (array<Object>)
-reviews_average_score → Nota média das avaliações (float)
-url → Endereço da página do produto (string)
