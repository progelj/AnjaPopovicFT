% Load the data
folderPath = 'D:\Popovic\Anja\SEED';

% Get all .mat files in the folder
matFiles = dir(fullfile(folderPath, '*.mat'));

% Initialize arrays to store feature matrices and class labels
featureMatrices = {};
classLabels = [];

% Load each connectivity matrix and store it in the cell array
for i = 1:numel(matFiles)
    matFileName = fullfile(folderPath, matFiles(i).name);
    load(matFileName);
    
    % Extract class label from the loaded file
    labels = label; % 'label' is the variable storing class labels
    
    % Map class label to numeric value
    numericLabel = labels + 2; % Convert 1, 0, -1 to 3, 2, 1
    
    % Append the connectivity matrix to featureMatrices
    featureMatrices{end+1} = connectivity_matrix;
    
    % Append label for the matrix
    classLabels = [classLabels; numericLabel];
end

% Create a table with feature matrices and class labels
dataTable = table(featureMatrices', classLabels, 'VariableNames', {'ConnectivityMatrices', 'Class'});

% Write the table to a CSV file
writetable(dataTable, 'dataTable_big_data.csv');
