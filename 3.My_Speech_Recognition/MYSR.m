clc;
clear;
close all;

% بارگذاری شبکه عصبی و مقادیر نرمال‌سازی
load('F:\MATLAB_Projects\Speech_Recognition\3.My_Speech_Recognition\trainedNetwork.mat');

% تعریف کلماتی که می‌خواهید تشخیص دهید
PREFIXES = {'bale', 'na', 'salam', 'khodafez', 'lotfan', 'tashakor', 'bebakhshid', 'komak', 'tavaghof', 'boro', 'chap', 'rast', 'bala', 'paein', 'shroe', 'payan', 'baz', 'baste', 'roshan', 'khamosh'};

% پارامترهای ضبط
fs = 44100; % نرخ نمونه‌برداری (هرتز)
nBits = 16; % تعداد بیت‌ها در هر نمونه
nChannels = 1; % تعداد کانال‌ها (1 برای مونو)

% حلقه بینهایت برای ضبط و تشخیص
while true
    choice = input('Press Enter to start recording or 1 to exit: ', 's');
    if strcmp(choice, '1')
        break;
    end
    
    % پخش صدای بوق
    beep;
    
    % ضبط یک نمونه صوتی از کاربر
    recObj = audiorecorder(fs, nBits, nChannels);
    disp('Please say one of the words after the beep.');
    recordblocking(recObj, 2); % ضبط برای 2 ثانیه
    disp('End of Recording.');
    
    % استخراج داده‌های صوتی
    audioData = getaudiodata(recObj);
    
    % پیش‌پردازش داده‌های صوتی
    audioData = mean(audioData, 2); % در صورت داشتن چندین کانال
    audioData = audioData(1:88200); % تراش دادن به اندازه ثابت
    
    % استخراج ویژگی‌ها
    features = mfcc(audioData, fs);
    features = mean(features, 1);
    features = features(1:13); % تعداد ویژگی‌هایی که می‌خواهید برای هر نمونه داشته باشید
    
    % نرمال‌سازی ویژگی‌ها
    featuresNorm = (features - meanTrain) ./ stdTrain;
    
    % تبدیل ویژگی‌ها به جدول برای استفاده در شبکه
    featuresTable = array2table(featuresNorm, 'VariableNames', {'Feature1', 'Feature2', 'Feature3', 'Feature4', 'Feature5', 'Feature6', 'Feature7', 'Feature8', 'Feature9', 'Feature10', 'Feature11', 'Feature12', 'Feature13'});
    
    % تشخیص با استفاده از شبکه عصبی
    predictedLabel = classify(net, featuresTable);
    
    % تبدیل برچسب پیش‌بینی شده به رشته
    predictedWord = char(predictedLabel);
    
    % جدا کردن برچسب بر اساس '_'
    parts = strsplit(predictedWord, '_');
    
    % نمایش بخش مورد نظر (در این مثال، بخش سوم)
    if length(parts) >= 3
        disp(['Predicted word: ' parts{3}]);
    else
        disp('The predicted label does not have three parts.');
    end
end
