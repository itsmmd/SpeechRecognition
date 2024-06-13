clc;
clear;
close all;

%% Load Data

Dir = 'F:\MATLAB_Projects\Speech_Recognition\1.augment';
Data = audioDatastore(Dir, 'IncludeSubfolders', true, ...
    'FileExtensions', '.wav', 'LabelSource', 'foldernames');
Label = countEachLabel(Data);

%% Split Data into Train and Test Data
NumberTrain = 0.7;
[TrainData, TestData] = splitEachLabel(Data, NumberTrain, 'randomize');
TrainLabels = TrainData.Labels;
TestLabels = TestData.Labels;

%% Feature Extraction for Training Data
featuresTrain = [];
featureLength = 13; % تعداد ویژگی‌هایی که می‌خواهید برای هر نمونه داشته باشید
for i = 1:length(TrainData.Files)
    [audioIn, fs] = audioread(TrainData.Files{i});
    % Extract features (e.g., Mel-frequency cepstral coefficients)
    features = mfcc(audioIn, fs);
    % Take the mean across time to get a fixed size feature vector
    features = mean(features, 1);
    % Ensure the feature vector is of the expected length
    features = features(1:featureLength);
    % Add the feature vector to the list
    featuresTrain = [featuresTrain; features];
end

%% Feature Extraction for Testing Data
featuresTest = [];
for i = 1:length(TestData.Files)
    [audioIn, fs] = audioread(TestData.Files{i});
    % Extract features (e.g., Mel-frequency cepstral coefficients)
    features = mfcc(audioIn, fs);
    % Take the mean across time to get a fixed size feature vector
    features = mean(features, 1);
    % Ensure the feature vector is of the expected length
    features = features(1:featureLength);
    % Add the feature vector to the list
    featuresTest = [featuresTest; features];
end

%% Normalize Features
% Calculate the mean and standard deviation of the training features
meanTrain = mean(featuresTrain);
stdTrain = std(featuresTrain);

% Normalize training data
featuresTrainNorm = (featuresTrain - meanTrain) ./ stdTrain;

% Normalize testing data using the mean and std of the training data
featuresTestNorm = (featuresTest - meanTrain) ./ stdTrain;

%% Convert Labels to Categorical
TrainLabelsCat = categorical(TrainLabels);
TestLabelsCat = categorical(TestLabels);

%% Check the number of features and labels
assert(size(featuresTrainNorm, 1) == numel(TrainLabelsCat), 'Number of training features and labels must be equal.');
assert(size(featuresTestNorm, 1) == numel(TestLabelsCat), 'Number of testing features and labels must be equal.');

%% Neural Network Code
% Define layers
layers = [
    featureInputLayer(size(featuresTrainNorm, 2))
    fullyConnectedLayer(50)
    reluLayer
    fullyConnectedLayer(25)
    reluLayer
    fullyConnectedLayer(numel(categories(TrainLabelsCat)))
    softmaxLayer
    classificationLayer];

% Set options
options = trainingOptions('adam', ...
    'MaxEpochs', 30, ...
    'MiniBatchSize', min(27, size(featuresTrainNorm, 1)), ...
    'InitialLearnRate', 0.01, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {featuresTestNorm, TestLabelsCat}, ...
    'ValidationFrequency', 30, ...
    'Verbose', false, ...
    'Plots', 'training-progress');

% Train network
net = trainNetwork(featuresTrainNorm, TrainLabelsCat, layers, options);

% Predict using the trained network
predictedLabels = classify(net, featuresTestNorm);

% تعیین مسیر مورد نظر برای ذخیره مدل
desiredPath = 'F:\MATLAB_Projects\Speech_Recognition\3.My_Speech_Recognition';

% ایجاد مسیر اگر وجود ندارد
if ~exist(desiredPath, 'dir')
    mkdir(desiredPath);
end

% ذخیره مدل در مسیر مورد نظر
save(fullfile(desiredPath, 'trainedNetwork.mat'), 'net', 'meanTrain', 'stdTrain');
