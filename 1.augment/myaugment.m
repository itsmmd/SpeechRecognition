clc;
clear;
close all;

% تعداد فایل‌ها برای هر پیشوند
numFilesPerPrefix = 5;
% لیست پیشوندها
PREFIXES = {'bale', 'na', 'salam', 'khodafez', 'lotfan', 'tashakor', 'bebakhshid', 'komak', 'tavaghof', 'boro', 'chap', 'rast', 'bala', 'paein', 'shroe', 'payan', 'baz', 'baste', 'roshan', 'khamosh'};

% تعداد دفعات افزایش داده
numAugmentations = 10;
% مسیر پوشه‌های حاوی فایل‌های صوتی
Dir = 'F:\MATLAB_Projects\Speech_Recognition\0.myrecord';

% مسیر دایرکتوری جدید برای ذخیره فایل‌های افزایش یافته
NewDir = 'F:\MATLAB_Projects\Speech_Recognition\1.augment';

% ایجاد یک audioDatastore
Data = audioDatastore(Dir, 'IncludeSubfolders', true , 'FileExtensions', '.wav');

% پیمایش پوشه‌ها و فایل‌های صوتی
for i0 = 1:length(PREFIXES)
    % تغییر مسیر برای هر پیشوند
    prefixDir = fullfile(Dir, PREFIXES{i0});
    for i1 = 1:numFilesPerPrefix
        % تولید نام فایل با استفاده از پیشوند و شماره
        inputFilePath = fullfile(prefixDir, sprintf('%s%d.wav', PREFIXES{i0}, i1));
        if isfile(inputFilePath)
            % تغییر مسیر دایرکتوری خروجی به دایرکتوری جدید
            outputDirectory = fullfile(NewDir, sprintf('augmented_audio_%s', PREFIXES{i0}));
            augmentedFiles = augmentAudio(inputFilePath, numAugmentations, outputDirectory);
            disp('Augmented files created:');
            disp(augmentedFiles);
        else
            disp(['File not found: ', inputFilePath]);
        end
    end
end

% ... بقیه کد ...


function augmentedAudioFiles = augmentAudio(filePath, numAugmentations, outputDir)
    % خواندن فایل صوتی اصلی
    [audioData, fs] = audioread(filePath);
    
    % ایجاد دایرکتوری خروجی در صورت عدم وجود
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % لیست از توابع افزایش داده‌ها
    augmentationFunctions = {@changeSpeed, @addNoise, @shiftTime};
    
    augmentedAudioFiles = cell(numAugmentations, 1);
    
    for i = 1:numAugmentations
        % انتخاب تصادفی یک تابع افزایش داده‌ها
        funcIndex = randi(length(augmentationFunctions));
        augmentedAudio = augmentationFunctions{funcIndex}(audioData, fs);
        
        % ذخیره فایل صوتی جدید
        [~, name, ext] = fileparts(filePath);
        newFileName = fullfile(outputDir, [name, '_augmented_', num2str(i), '_', num2str(funcIndex), ext]);
        audiowrite(newFileName, augmentedAudio, fs);
        augmentedAudioFiles{i} = newFileName;
    end
end

% توابع افزایش داده‌ها

function augmentedAudio = changeSpeed(audioData, fs)
    % تغییر سرعت پخش (با ضریب بین 0.9 تا 1.1)
    speedFactor = 0.9 + (1.1-0.9).*rand(1,1);
    augmentedAudio = resample(audioData, round(fs*speedFactor), fs);
end



function augmentedAudio = addNoise(audioData, fs)
    % افزودن نویز سفید با سطح بین 0.001 تا 0.005
    noiseLevel = 0.001 + (0.005-0.001).*rand(1,1);
    noise = noiseLevel * randn(size(audioData));
    augmentedAudio = audioData + noise;
end

function augmentedAudio = shiftTime(audioData, fs)
    % جابجایی زمانی (با حداکثر جابجایی 0.1 ثانیه)
    shiftTime = -0.1 + (0.1-(-0.1)).*rand(1,1);
    shiftSamples = round(shiftTime * fs);
    augmentedAudio = circshift(audioData, shiftSamples);
end