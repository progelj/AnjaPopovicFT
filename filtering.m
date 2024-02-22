%clear all;
close all;
eeglab;

%% Load the data
filename = 'S001R01.edf';
filepath = 'D:\Popovic\Anja\new_data';
EEG = pop_biosig(fullfile(filepath, filename));

%% Preprocessing
%pop_eegplot(EEG, 1, 1, 1);

% Perform basic preprocessing (filtering)
EEG = pop_eegfiltnew(EEG, 'locutoff', 1);
EEG = pop_eegfiltnew(EEG, 'hicutoff', 45);

% cut away the first 1000 samples due to the einitial drift
EEG = eeg_eegrej( EEG, [1 1000] );

% Resample from 160 to 80 Hz
EEG = pop_resample(EEG, 80)%, 0.8, 0.4);

EEG = eeg_checkset( EEG );

%pop_eegplot(EEG, 1, 1, 1);
% Add a label to the plot
%text(0, 0.9, 'Filtered Data', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'green');

%% granger causality with the custom made functions:
order = 12;
numDatasets = length(EEG); 
conG2_all_datasets = cell(1, numDatasets);

tic

for datasetIndex = 1%:numDatasets
    currentEEG = EEG(datasetIndex); 

    nrEl = size(currentEEG.data, 1); % Number of electrodes (channels)

    conG2_continuous = zeros(nrEl, nrEl);

    for c1 = 1:nrEl
        for c2 = c1+1:nrEl
            GC = GCmodel(currentEEG.data([c1 c2], :), order);
            GC = max(GC, [0 0]);
            conG2_continuous(c1, c2) = GC(1);
            conG2_continuous(c2, c1) = GC(2);
        end
    end
end

toc
%%
% Plot the connectivity matrix
figure;
imagesc(conG2_continuous);
colorbar;
title('Connectivity Matrix');
xticks([1:nrEl]);

% Convert channel labels to a cell array of strings
channelLabels = cell(1, nrEl);
for i = 1:nrEl
    channelLabels{i} = currentEEG.chanlocs(i).labels;
end

xticklabels(channelLabels);
xtickangle(90);
yticks([1:nrEl]);
yticklabels(channelLabels);
xlabel('Influencing electrode');
ylabel('Influenced electrode');
axis equal;
axis tight;
