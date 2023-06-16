function [] = parseTGFF(pathFile)

    fid = fopen(pathFile); % Opening the file
    raw = fileread(pathFile); % Reading the contents
    str = char(raw'); % Transformation
    fclose(fid); % Closing the file
    data = jsondecode(str(1,:)); % Using the jsondecode function to parse JSON from string
end