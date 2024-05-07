% Criar uma figura
figure;

% Definir o layout
num_linhas = 5;
num_colunas = 5;
num_tarefas = 16;

% Definir as coordenadas e tamanhos dos quadrados
width = 2;       % Largura dos quadrados
height = 2;      % Altura dos quadrados

% Definir os números correspondentes aos quadrados
TotalNoc1 = TotalNoc(:,:);
numeros = reshape(TotalNoc1', num_linhas, num_colunas, num_tarefas);
numeros = permute(numeros,[2,1,3]);

% Loop para desenhar os quadrados e adicionar os números
for i = 1:num_linhas
    for j = 1:num_colunas
        % Calcular as coordenadas x e y do quadrado atual
        x = width*(j - 1);
        y = height*(num_linhas - i);
        
        % Desenhar o quadrado
        rectangle('Position', [x y width height], 'FaceColor', 'none');
        
        % Adicionar o número no centro do quadrado
        text(x + width/2, y + height/2, num2str(nonzeros(numeros(i, j,:))), 'HorizontalAlignment', 'center');
    end
end


text(-0.8, -0.8, num2str(SoluOb(1)),'HorizontalAlignment', 'left');
%text(1.2, -0.8, num2str(SoluOb(2)),'HorizontalAlignment', 'left');
text(-0.8, -0.4, {'Comunication'},'HorizontalAlignment', 'left');
%text(1.2, -0.4, {'Balance'},'HorizontalAlignment', 'left');

% Configurar o eixo para mostrar todos os quadrados
axis([-1 num_colunas*width -1 num_linhas*height]);

% Remover os eixos
axis off;
