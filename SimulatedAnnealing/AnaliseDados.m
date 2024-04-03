
result = cell2mat(TesteMCSA);
result = reshape(result, 9, 100);
result = result';
posicao = min(result(:,9));
