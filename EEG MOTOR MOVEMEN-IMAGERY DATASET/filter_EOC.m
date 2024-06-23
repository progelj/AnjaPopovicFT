%clear all;
close all;
eeglab;
%% Load the data
filename = 'S001R01.edf';
filepath = 'D:\Popovic\Anja\Eyes_opened_closed';
EEG = pop_biosig(fullfile(filepath, filename));
% pop_eegplot(EEG, 1, 1, 1);
%% Define epoch parameters
epoch_length = 2;  % Length of each epoch in seconds

% Define the folder path containing the datasets
folderPath ='D:\Popovic\Anja\EEG MOTOR MOVEMEN-IMAGERY DATASET';

% Get all .edf files in the folder
edfFiles = dir(fullfile(folderPath, '*.edf'));

% Preallocate cell array to store all epochs
all_epochs = cell(1, numel(edfFiles));

% Loop through each .edf file
for fileIndex = 1:numel(edfFiles)
    
    % Load the EEG data from the file
    filename = edfFiles(fileIndex).name;
    EEG = pop_biosig(fullfile(folderPath, filename));
    pop_eegplot(EEG, 1, 1, 1);
    % Perform basic preprocessing (filtering)
    EEG = pop_eegfiltnew(EEG, 'locutoff', 1);
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 45);

    % Cut away the first 1000 samples due to the initial drift
    %EEG = eeg_eegrej( EEG, [1 1000] );

    % pop_eegplot(EEG, 1, 1, 1);
    % Resample from 160 to 80 Hz if needed
    % EEG = pop_resample(EEG, 80);

    % Ensure that the EEG structure is properly updated
    EEG = eeg_checkset( EEG );


    % Define the start and end times for each epoch
    epoch_length_points = epoch_length * EEG.srate;
    epoch_start_times = 1:epoch_length_points:(EEG.pnts - epoch_length_points + 1);
    epoch_end_times = epoch_length_points:epoch_length_points:EEG.pnts;
    if epoch_end_times(end) < EEG.pnts
        epoch_end_times = [epoch_end_times, EEG.pnts];
    end

    % Create cell array to store epochs for the current file
    epochs = cell(1, length(epoch_start_times));

    % Epoch the data
    for epoch_index = 1:length(epoch_start_times)
        % Extract data for the current epoch
        epoch_data = EEG.data(:, epoch_start_times(epoch_index):epoch_end_times(epoch_index));

        % Create a new EEG structure for the epoch
        epoch_EEG = EEG;
        epoch_EEG.data = epoch_data;
        epoch_EEG.pnts = size(epoch_data, 2);  % Update number of data points

        % Store the epoch in the cell array
        epochs{epoch_index} = epoch_EEG;
    end

    % Store epochs for the current file
    all_epochs{fileIndex} = epochs;
end

%% granger causality with the custom made functions:

order = 12;
numDatasets = length(all_epochs);
conG2_all_datasets = cell(1, numDatasets);

tic

for datasetIndex = 1:numDatasets
    
    epochCellArray = all_epochs{datasetIndex};
    numEpochs = length(epochCellArray);
    epochLabels = cell(1, numEpochs);

    % Initialize a 3D array to store connectivity matrices for all epochs
    conG2_epochs_dataset = zeros(64, 64, numEpochs);

    for ep = 1:numEpochs
        currentEEG = epochCellArray{ep};
        epochData = currentEEG.data;
        
        comment = epochCellArray{ep}.comments; 
        [~, fileName, ~] = fileparts(comment);
    
    % Determine the label based on the file name ending
    if endsWith(fileName, 'R01')
        label = 'eyes_opened';
    elseif endsWith(fileName, 'R02')
        label = 'eyes_closed';
    else
        label = 'unknown';  
    end

    epochLabels{ep}=label;

        % Determine the number of channels (electrodes)
        nrEl = size(epochData, 1);
        
        % Initialize the connectivity matrix for the current epoch
        conG2_epoch = zeros(nrEl, nrEl);
        
        % Loop through each pair of channels
        for c1 = 1:nrEl
            for c2 = c1+1:nrEl
                % Calculate Granger causality between the pair of channels
                GC = GCmodel(epochData([c1 c2], :), order);
                % Ensure non-negativity of GC values
                GC = max(GC, [0 0]);
                % Store the results in the connectivity matrix
                conG2_epoch(c1, c2) = GC(1);
                conG2_epoch(c2, c1) = GC(2);
            end
        end
        
        % Store the connectivity matrix for the current epoch
        conG2_epochs_dataset(:, :, ep) = conG2_epoch;
    end
    
    % Store the connectivity matrices for the dataset
    save(['connectivity_matrix_' num2str(datasetIndex)], 'conG2_epochs_dataset', 'epochLabels');
    
end

toc
%%
% Plot the connectivity matrix
% figure;
% imagesc(conG2_continuous);
% colorbar;
% title('Connectivity Matrix');
% xticks([1:nrEl]);

% Convert channel labels to a cell array of strings
% channelLabels = cell(1, nrEl);
% for i = 1:nrEl
  %  channelLabels{i} = currentEEG.chanlocs(i).labels;
% end

% xticklabels(channelLabels);
% xtickangle(90);
% yticks([1:nrEl]);
% yticklabels(channelLabels);
% xlabel('Influencing electrode');
% ylabel('Influenced electrode');
% axis equal;
% axis tight;
