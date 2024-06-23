close all;
eeglab;
%% Load the data
filename = 'ReRef_InGnus_002_eeg pruned with ICA.set';
filepath = 'D:\Popovic\Anja\EMOTIONS 2';
EEG = pop_loadset(fullfile(filepath, filename));
 %pop_eegplot(EEG, 1, 1, 1);
%% Preprocessing

% Load the data
folderPath = 'D:\Popovic\Anja\EMOTIONS 2';

% Get all .set files in the folder
setFiles = dir(fullfile(folderPath, '*.set'));

% Initialize variables to store preprocessed data
preprocessedData = cell(1, numel(setFiles));

% Loop through each .set file
for fileIndex = 1:numel(setFiles)
    % Load the EEG data from the file
    filename = setFiles(fileIndex).name;
    EEG = pop_loadset(fullfile(folderPath, filename));
    
    % Perform preprocessing steps
    % For example, resample to 250 Hz
    EEG = pop_resample(EEG, 250);
    
    % Store preprocessed EEG data
    preprocessedData{fileIndex} = EEG;
end

% Save preprocessed data to a .mat file
save('preprocessed_data.mat', 'preprocessedData');

%% Bivariate Autoregressive Model Prediction Error

% Define the maximum order to test
ordmax = 50;
% Initialize array to store prediction errors
E_order = zeros(ordmax, 2);

% Loop over different orders
for order = 1:ordmax
    % Compute Granger causality and error prediction for the current order
    [~, ~, ~, ~, e1, e2, ~] = GCmodel(EEG.data([elA elB], :), order);
    
    % Compute prediction error (variance of the error)
    E_order(order, 1) = var(e1);
    E_order(order, 2) = var(e2);
end

% Plot prediction errors
figure(20);
semilogy(E_order);
grid on;
xlabel('Order');
ylabel('Prediction Error (Variance)');
title('Bivariate Autoregressive Model Prediction Error');
legend('Prediction Error for Electrode A', 'Prediction Error for Electrode B');

% Choose the order based on the plot or any other criterion
% chosen_order = 10;

%% granger causality with the custom made functions:

order = 10;
numDatasets = length(preprocessedData);
conG2_all_datasets = cell(1, numDatasets);

tic

for datasetIndex = 1:numDatasets
    epochCellArray = preprocessedData{datasetIndex};
  
    numEpochs = size(epochCellArray.data, 3);
    % Initialize a 3D array to store connectivity matrices for all epochs
    conG2_epochs_dataset = zeros(32, 32, numEpochs);
    epochLabelsIndex = cell(1, numEpochs);
    epochLabels = cell(1, numEpochs);

    for ep = 1:numEpochs

        epochData = squeeze(epochCellArray.data(:, :, ep));
        % currentEEG = epochCellArray(ep);
        % epochData = currentEEG.data;
        % Determine the number of channels (electrodes)
        nrEl = size(epochData, 1);
        
        % Initialize the connectivity matrix for the current epoch
        conG2_epoch = zeros(nrEl, nrEl);
        % Event type label extraction
        epochLabels{ep} = epochCellArray.event.type;
        
        % Loop through each pair of channels
        for c1 = 1:nrEl
            for c2 = c1+1:nrEl
                % Calculate Granger causality between the pair of channels
                GC = GCmodel(epochData([c1 c2], 76:end), order);
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
%% ---check how causality changes with respect to the order---
% ordmax = 20;
% elA = find(strcmp({EEG.chanlocs(:).labels},'C2')); 
% elB = find(strcmp({EEG.chanlocs(:).labels},'FTT7h')); 
% prepapre vectors to store results
% GC = zeros(ordmax, 2); % Granger causality of B to A (1) and A to B (2);

% for order = 1:ordmax
    % Compute Granger causality for the current order
    % [~, ~, ~, ~, e1, e2, e12] = GCmodel(EEG.data([elA elB], :), order);

    % Compute Granger causality metrics
    % GC(order, 1) = log(var(e1) / var(e12(1,:)));
    % GC(order, 2) = log(var(e2) / var(e12(2,:)));
% end

% Plot Granger causality
% figure(21);
% plot(GC);
% grid on;
% legend(['GC ' EEG.chanlocs(elB).labels ' to ' EEG.chanlocs(elA).labels], ...
      % ['GC ' EEG.chanlocs(elA).labels ' to ' EEG.chanlocs(elB).labels]);
% xlabel('Order');
% ylabel('Granger Causality');
% title('Granger Causality vs. Order');

% Choose the order based on the graph where the causality becomes stable
%chosen_order = 20;  % This value can be chosen based on the graph or any other criterion

%% Plot the connectivity matrix

% figure;
% imagesc(conG2_continuous);
% colorbar;
% title('Connectivity Matrix');
% xticks(1:nrEl);

% Convert channel labels to a cell array of strings
% channelLabels = cell(1, nrEl);
% for i = 1:nrEl
  %   channelLabels{i} = currentEEG.chanlocs(i).labels;
% end

% xticklabels(channelLabels);
% xtickangle(90);
% yticks(1:nrEl);
% yticklabels(channelLabels);
% xlabel('Influencing electrode');
% ylabel('Influenced electrode');
% axis equal;
% axis tight;
