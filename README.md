1. Descompactar .zip
2. Abrir pasta MCTOR no Matlab
3. Executar comando mctor_gui() a partir da pasta MCTOR/

Aba "Single"
É possível executar de maneira convencional, carregando um arquivo .tgff que contém os grafos das aplicações

Arquivos TGFF
Clicando no botão "Load TGFF file", abrirá uma janela para selecionar o arquivo TGFF. Há exemplos de arquivos no caminho: MCTOR/tgff/. O arquivo "simple1" contém os grafos para 1 aplicação. O arquivo "simple2" contém os grafos para 2 aplicações.
Para gerar um arquivo TGFF contendo N aplicações, basta criar/modificar um arquivo .tgffopt (veja MCTOR/tgff/tgff_v3_1/examples/simple.tgffopt) e alterar o parâmetro "tg_cnt". Depois disso, execute na linha de comando MCTOR/tgff/tgff_v3_1/tgff3_1.exe <caminho para o arquivo .tgffopt>. Esse comando irá gerar um arquivo .tgff, que pode ser aberto pela interface GUI através do botão "Load TGFF file"

Aba "Batch"
Aqui é possível realizar N chamadas ao PlatEMO para combinações de parâmetros, a partir dos grafos carregados na aba "Single". Ao clicar no botão "RUN", uma tabela contendo as combinações de parâmetros é exibida e o usuário pode acompanhar o status da execução pela coluna "Status". Uma vez que todos os testes encerraram, basta clicar no botão "Export results" e os resultados da execução batch atual são salvos por meio de um arquivo .mat na pasta MCTOR/batch/

Versões utilizadas:
MATLAB R2023a
PlatEMO v4.1