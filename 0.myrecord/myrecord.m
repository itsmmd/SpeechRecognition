clear 
close all

% پارامترهای ضبط
fs = 44100; % نرخ نمونه‌برداری (هرتز)
nBits = 16; % تعداد بیت‌ها در هر نمونه
nChannels = 1; % تعداد کانال‌ها (1 برای مونو)

% پیشوندهای نام فایل
prefixes = {'bale', 'na', 'salam', 'khodafez', 'lotfan', 'tashakor', 'bebakhshid', 'komak', 'tavaghof', 'boro', 'chap', 'rast', 'bala', 'paein', 'shroe', 'payan', 'baz', 'baste', 'roshan', 'khamosh'};

% دریافت شماره دسته از کاربر
disp('Please enter a number for the desired prefix to record:');
for k = 1:length(prefixes)
    disp([num2str(k), ': ', prefixes{k}]);
end
selectedPrefixNumber = input('Number: ');

% اطمینان از ورودی صحیح
if selectedPrefixNumber < 1 || selectedPrefixNumber > length(prefixes)
    disp('Error: Invalid number entered.');
    return;
end

% انتخاب پیشوند بر اساس شماره ورودی
selectedPrefix = prefixes{selectedPrefixNumber};

% ایجاد پوشه برای دسته انتخاب شده
mkdir(selectedPrefix);

% حلقه برای ضبط پنج صدا
for i = 1:5
    % انتظار برای فشار دادن کلید اینتر توسط کاربر
    input('Press Enter to start recording.');

    % ایجاد شیء ضبط صدا
    recObj = audiorecorder(fs, nBits, nChannels);

    % نمایش پیام برای شروع ضبط
    disp(['Start speaking for recording number ', num2str(i)])

    % شروع ضبط (مدت زمان ضبط به ثانیه)
    recordblocking(recObj, 2);

    % نمایش پیام برای پایان ضبط
    disp('End of Recording.');

    % پخش صدای ضبط شده
    play(recObj);

    % دریافت داده‌های صوتی به عنوان یک آرایه
    audioData = getaudiodata(recObj);

    % ذخیره صدای ضبط شده در یک متغیر با نام منحصر به فرد
    eval([selectedPrefix, '_audioData_', num2str(i), ' = audioData;']);

    % تعیین نام فایل با مسیر پوشه
    filename = fullfile(selectedPrefix, [selectedPrefix, num2str(i), '.wav']);
    
    % ذخیره صدای ضبط شده در فایل WAV در پوشه مربوطه
    audiowrite(filename, audioData, fs);

    % نمایش پیامی مبنی بر ذخیره موفقیت‌آمیز
    disp(['Audio recorded and saved to ', filename]);
end

% نمایش شکل موج صدای ضبط شده برای آخرین ضبط
figure;
plot(audioData);
title(['Recorded Audio for ', selectedPrefix]);
xlabel('Sample Number');
ylabel('Amplitude');
