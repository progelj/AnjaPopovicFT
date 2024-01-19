clear all;
close all;
eeglab;
%% load the data
filename= 'TEP_011_2023.03.23_11.40.35.set';
%filename='';
filepath= 'D:\Popovic\Anja\EEG-emotion\EEG-emotion';

EEG = pop_loadset('filename', filename, 'filepath', filepath);

% Reject unwanted channels
channels_to_reject = [];  % Specify the channels you want to reject
EEG = pop_select(EEG, 'nochannel', channels_to_reject);

% Add channel location data
%EEG=pop_chanedit(EEG, 'load',{'C:\Users\Popovic\Desktop\X\Third Year\Seminar\Locs32_30_05_2017 (2).locs' 'filetype' 'autodetect'});

%% processing
% filter 1-45 hz
EEG = pop_eegfiltnew(EEG, 'locutoff',1);
EEG = pop_eegfiltnew(EEG, 'hicutoff',45);          % ==== reduces rank!
%EEG = pop_iirfilt( EEG, 1, 45, [], 0, 1);          % ==== reduces rank!
%EEG.data = bandpass(EEG.data',[1 45],EEG.srate)';  % ==== reduces rank!
%EEG.data = lowpass(EEG.data', 45, EEG.srate, 'ImpulseResponse','fir', 'Steepness',0.95 )'; % ==== reduces rank! -fir less than iir

% cut away the first 1000 samples due to the einitial drift
%EEG = eeg_eegrej( EEG, [1 1000] );

% 4. Re-reference to average 
%EEG = pop_reref( EEG, []);

% resample from 600 to 300 hz 
% EEG = pop_resample( EEG, 300);
EEG = pop_resample(EEG, 200, 0.8, 0.4); %=================
EEG = eeg_checkset( EEG );

%%
%eeglab redraw; % refresh GUI using data defined in the command mode
%fs=EEG.srate;
%nrEl = EEG.nbchan;
[OUTEEG, indices] = pop_epoch (EEG, {'Veselje', 'Gnus', 'Nevtralno', 'Strah'}, [0 2]);


%% granger causality with the custom made functions:
% GCdata = [EEG.data(elA,:); EEG.data(elB,:)];
% %[GC, A1, A2, A12 , e1, e2, e12] = GCmodel(GCdata, 20);
% [EP, A1, A2, B1, B2, E] = epmodel(GCdata, 20);
order = 12;
numDatasets = length(OUTEEG); % Assuming OUTEEG is an array of EEG datasets
conG2_all_datasets = cell(1, numDatasets);

tic

for datasetIndex = 1:numDatasets
    currentEEG = OUTEEG(datasetIndex); % Assuming OUTEEG is an array of EEG datasets
   

    numEpochs = size(currentEEG.data, 3);
    nrEl = size(currentEEG.data, 1); % Number of electrodes (channels)
    nrTimePoints = size(currentEEG.data, 2); % Number of time points
    conG2_epochs = zeros(nrEl, nrTimePoints , numEpochs);

    for epoch = 1:numEpochs
        epochData = squeeze(currentEEG.data(:, :, epoch));

       
        for c1 = 1:nrEl
            for c2 = c1+1:nrEl
                GC = GCmodel(epochData([c1 c2], :), order);
                GC = max(GC, [0 0]);
                conG2_epochs(c1, c2, epoch) = GC(1);
                conG2_epochs(c2, c1, epoch) = GC(2);
            end
        end
    end
    
    conG2_all_datasets{datasetIndex} = conG2_epochs;
end

toc 

% Plot each epoch separately
figure;
% %for epoch = 1:numEpochs
%    % subplot(1, numEpochs, epoch);
%     %imagesc(conG2_epochs(:,:,epoch));
%     colorbar;
%     title(['Epoch ' num2str(epoch)]);
%     xticks([1:nrEl]);
% 
%     xticklabels({EEG.chanlocs.labels(:)});
%     xtickangle(90);
%     yticks([1:nrEl]);
%     yticklabels({EEG.chanlocs.labels(:)});
%     xlabel('Influencing electrode');
%     ylabel('Influenced electrode');
%     axis equal;
%     axis tight;
% %end

% Adjust the title for the entire figure
%title(['Granger causality (self implemented), order=' num2str(order) ', ' EEG.setname ]);