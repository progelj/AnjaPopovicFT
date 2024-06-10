% Load Data from CSV
data = readtable('dataTable_big_data.csv');

% Extract predictor variables (X) and response variable (Y)
X = table2array(data(:, 1:end-1));
Y = data(:, end);

% Extract the response variable column from the table
Y_column = data{:, end}; 

% Convert the response variable column into a categorical array
Y_categorical = categorical(Y_column, [1 2 3], {'-1', '0', '1'}); 

[trainInd, testInd, ~] = dividerand(size(X, 1), 0.7, 0.3, 0);
Xn = X';

XTest = Xn(:, testInd);
XTrain = Xn(:, trainInd);
Y_arr = table2array(Y);
YTest = categorical(Y_arr(testInd), [1 2 3], {'-1', '0', '1'});
YTrain = categorical(Y_arr(trainInd), [1 2 3], {'-1', '0', '1'});

XTest_2D = reshape(XTest, [62, 62, 1, size(XTest, 2)]);
XTrain_2D = reshape(XTrain, [62, 62, 1, size(XTrain, 2)]);

layers = [
    imageInputLayer([62 62 1])
    fullyConnectedLayer(100)
    leakyReluLayer
    dropoutLayer(0.5)
    fullyConnectedLayer(5)
    geluLayer
    dropoutLayer(0.5)
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer
];

options = trainingOptions('sgdm', ...
    'Shuffle', 'every-epoch', ...
    'MaxEpochs', 200, ...
    'ValidationData', {XTest_2D, YTest'}, ...
    'MiniBatchSize', 50, ...
    'Verbose', false, ...
    'Plots', 'training-progress' ...
);

[net, info] = trainNetwork(XTrain_2D, YTrain', layers, options);
%%
filePath = fullfile('./', '*_table_*.mat'); 
matFiles = dir(filePath);

% Initialize arrays to hold all the data and labels
XTestData = [];
YTestData = [];

for i = 1:length(matFiles)
    splitFileName = matFiles(i).name;
    fullFileName = fullfile(matFiles(i).folder, splitFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    data = load(fullFileName);
 
    matrices = data.connectivity_matrix; 
    labels = data.label; 
    
    XTestData = cat(4, XTestData, matrices);
    YTestData = [YTestData; labels];
end

YTestData = categorical(YTestData, [1 2 3], {'-1', '0', '1'});

numTestSamples = size(XTestData, 4);
accumulatedGradientMap = zeros(62, 62);

for i = 1:numTestSamples
    testEpoch = XTestData(:, :, :, i);
    gemap = gradientMap(net, testEpoch, 'GradientExplanation');
    accumulatedGradientMap = accumulatedGradientMap + double(gemap); 
end

averageGradientMap = accumulatedGradientMap / numTestSamples;
%%
% Plot the average gradient map
electrodeNames = {'Fp1','Fpz','Fp2','AF3','AF4','F7','F5','F3','F1','Fz','F2','F4','F6','F8','FT7','FC5','FC3','FC1','FCz','FC2','FC4','FC6','FT8','T7','C5','C3','C1','Cz','C2','C4','C6','T8','TP7','CP5','CP3','CP1','CPz','CP2','CP4','CP6','TP8','P7','P5','P3','P1','Pz','P2','P4','P6','P8','PO7','PO5','PO3','POz','PO4','PO6','PO8','CB1','O1','Oz','O2','CB2'};
imagesc(averageGradientMap);
colorbar;
title('Average Gradient Map');
set(gca, 'XTick', 1:62, 'XTickLabel', electrodeNames, 'XTickLabelRotation', 90);
set(gca, 'YTick', 1:62, 'YTickLabel', electrodeNames);
% Save the average gradient map
save('averageGradientMap.mat', 'averageGradientMap');
%%
plotEegConnectionMap(chanloc, double(averageGradientMap));

% Optional: Save the trained network and training information
%save(['./results/net_' num2str(testInd) '.mat'], 'net');
%%
histogramValues = reshape(averageGradientMap, 1, []);
histogramBins = linspace(min(histogramValues), max(histogramValues), 100);
histogramCounts = histcounts(histogramValues, histogramBins);

% Plot the histogram
figure;
bar(histogramBins(1:end-1), histogramCounts);
xlabel('Gradient Map Value');
ylabel('Frequency');
title('Histogram of Gradient Map Values');
%%
% Define the threshold
threshold = 100;

% Scale the gradient map values
scaledGradientMap = averageGradientMap;
scaledGradientMap(scaledGradientMap <= threshold) = ...
    scaledGradientMap(scaledGradientMap <= threshold) / max(scaledGradientMap(:));

% Apply a nonlinear scaling for values above the threshold
scaledGradientMap(scaledGradientMap > threshold) = ...
    log(scaledGradientMap(scaledGradientMap > threshold));

% Plot the gradient map with scaled arrows
figure;
imagesc(scaledGradientMap);
colorbar;
title('Scaled Gradient Map');

set(gca, 'XTick', 1:62, 'XTickLabel', electrodeNames, 'XTickLabelRotation', 90);
 set(gca, 'YTick', 1:62, 'YTickLabel', electrodeNames);

% Save the scaled gradient map
% save('scaledGradientMap.mat', 'scaledGradientMap');

%%
plotEegConnectionMap(chanloc, double(scaledGradientMap));