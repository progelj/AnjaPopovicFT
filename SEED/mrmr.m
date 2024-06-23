% Load data from CSV file
data = readtable('dataTable_big_data.csv');

% Extract predictor variables (X) and response variable (Y)
X = table2array(data(:, 1:end-1));
Y = data(:, end);

% Extract the response variable column from the table
Y_column = data{:, end}; 

% Convert the response variable column into a categorical array
Y_categorical = categorical(Y_column); 

% Apply fscmrmr function
[idx, scores] = fscmrmr(X, Y_categorical);

%% Load channel location information into your EEG dataset
EEG=pop_chanedit(EEG, 'load',{'D:\Popovic\Anja\SEED\channels.locs' 'filetype' 'autodetect'});
%% Save channelocs in a separate file
chanloc = EEG.chanlocs;
save('chanlocs.mat', 'chanloc');
%%
scores_matrix = zeros(62);
scores_matrix(idx) = scores;
save('scores_matrix.mat', 'scores_matrix');
%% Plot Feature Scores
figure;
electrodeNames = {'Fp1','Fpz','Fp2','AF3','AF4','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2','P4','P6','P8','PO7','PO5','PO3','POz','PO4','PO6','PO8','CB1','O1','Oz','O2','CB2'};

imagesc(scores_matrix);
title('Feature Scores', 'FontSize', 25);
ax = gca;
ax.XAxis.FontSize = 11;
ax.YAxis.FontSize = 11;
ax.XAxis.FontWeight= 'bold';
ax.YAxis.FontWeight= 'bold';
xticklabels(electrodeNames);
 
xtickangle(90);
xticks([1:62]);
yticks([1:62]);
yticklabels(electrodeNames);
 
%%
% Visualize the results
figure;
bar(scores(idx));
xlabel('Predictor Rank','FontSize', 25);
ylabel('Predictor Importance Score','FontSize',25);
title('MRMR-based Feature Ranking','FontSize',25);
ax = gca;
ax.XAxis.FontSize = 23;
ax.YAxis.FontSize = 23;

xlim([0 15]);
  %predictor_names = data.Properties.VariableNames(1:end-1);
  %xticklabels(predictor_names);
  %xtickangle(45); % Rotate x-axis labels for better readability

%%  Apply the plotEegConnectionMap function
plotEegConnectionMap(chanloc, scores_matrix);

%%
save('trainedModel.mat', 'trainedModel');