%clear all;
close all;
eeglab;

%% Granger causality with the custom made functions: 

% Path to the data 
mainFolder = 'D:\Popovic\Anja\Preprocessed_EEG\Preprocessed_EEG';

% List all .mat files in the main folder
matFiles = dir(fullfile(mainFolder, '*.mat'));

% Load labels from label.mat file
labelData = load(fullfile(mainFolder, 'label.mat'));
labels = labelData.label;

% Parameters for connectivity calculation
order = 12; % Granger causality model order

% Loop through each .mat file
for fileIndex = 1:numel(matFiles)
    % Get the file name
    fileName = matFiles(fileIndex).name;
    
    % Load the .mat file
    filePath = fullfile(mainFolder, fileName);
    data = load(filePath);
    
    % Extract the 15 tables from the loaded data
    tables = struct2cell(data);
    
    % Initialize cell arrays to store connectivity matrices and labels for each table
    connectivity_matrices_per_table = cell(1, numel(tables));
    labels_per_table = cell(1, numel(tables));
    
    % Loop through each table in the current dataset
    for tableIndex = 1:numel(tables)

        % Process each table to calculate connectivity matrix
        currentTable = tables{tableIndex};
        
        % Calculate Granger causality for the current table
        nrEl = 62; % Number of electrodes
        conG2_epoch = zeros(nrEl, nrEl);
        
        % Loop through each pair of channels
        for c1 = 1:nrEl
            for c2 = c1+1:nrEl
                % Calculate Granger causality between the pair of channels
                GC = GCmodel(currentTable([c1 c2], :), order);
                % Ensure non-negativity of GC values
                GC = max(GC, [0 0]);
                % Store the results in the connectivity matrix
                conG2_epoch(c1, c2) = GC(1);
                conG2_epoch(c2, c1) = GC(2);
            end
        end
        
        % Store the connectivity matrix for the current table
        connectivity_matrix = conG2_epoch;
        
        % Store the corresponding label for the current table
        label = labels(tableIndex);

        % Save connectivity matrix and label for the current table
        save([fileName(1:end-4) '_table_' num2str(tableIndex)], 'connectivity_matrix', 'label');
    end
end