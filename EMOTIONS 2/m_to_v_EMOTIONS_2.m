% Load the data
folderPath = 'D:\Popovic\Anja\EMOTIONS 2';

% Get all .mat files in the folder
matFiles = dir(fullfile(folderPath, 'connectivity_matrix_*.mat'));

% Extract the numeric values from the file names using regular expressions
fileNumbers = cellfun(@(x) str2double(regexp(x, '\d+', 'match')), {matFiles.name});

% Sort the file numbers
[~, sortedIndices] = sort(fileNumbers);

% Use the sorted indices to get the sorted files
sortedMatFiles = matFiles(sortedIndices);

% Initialize arrays to store feature vectors and class labels
featureVectors = [];
classLabels = [];

% Mapping class labels to numeric labels
classLabelMap = containers.Map({'Nevtralno', 'Gnus', 'Strah', 'Veselje'}, [1, 2, 3, 4]);

% Load each connectivity matrix and store it in the cell array
for i = 1:numel(sortedMatFiles)
    matFileName = fullfile(folderPath, sortedMatFiles(i).name);
    load(matFileName);
    
    % Extract class labels from the loaded file
    labels = epochLabels;
    
    % Map class labels to numeric values
    numericLabels = arrayfun(@(x) classLabelMap(labels{x}), 1:length(labels));
    
    % Reshape the connectivity matrix to a 2D matrix (32x32xnum_of_epochs)
    reshapedMatrix = reshape(conG2_epochs_dataset, [], size(conG2_epochs_dataset, 3));
    
    % Append reshapedMatrix to featureVectors
    featureVectors = [featureVectors; reshapedMatrix'];
    
    % Append labels for each epoch in the dataset
    classLabels = [classLabels; numericLabels'];
end

% Create a table with feature vectors and class labels
dataTable = table(featureVectors, classLabels, 'VariableNames', {'ConnectivityMatrices', 'Class'});

writetable(dataTable, 'dataTable.csv');
